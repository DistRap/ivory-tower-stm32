{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}

module Ivory.OS.FreeRTOS.Tower.STM32
  ( compileTowerSTM32FreeRTOS
  , module Ivory.BSP.STM32.MCU
  ) where

import Prelude ()
import Prelude.Compat

import Control.Monad (forM_)
import Data.List (nub)
import qualified Data.Map as Map
import System.FilePath

import Ivory.Language
import Ivory.Artifact
import Ivory.HW
import qualified Ivory.Stdlib as I
import qualified Ivory.Tower.AST as AST
import Ivory.Compile.C.CmdlineFrontend (runCompiler)
import Ivory.Tower.Backend
import Ivory.Tower.Types.ThreadCode
import Ivory.Tower.Types.Unique

import qualified Ivory.OS.FreeRTOS as FreeRTOS
import Ivory.Tower.Types.Dependencies
import Ivory.Tower (Tower)
import Ivory.Tower.Monad.Tower (runTower_)
import Ivory.Tower.Options
import Ivory.Tower.Types.Emitter

import           Ivory.OS.FreeRTOS.Tower.System
import           Ivory.OS.FreeRTOS.Tower.Monitor
import           Ivory.OS.FreeRTOS.Tower.Time (time_module)
import qualified Ivory.OS.FreeRTOS.Tower.STM32.Build as STM32

import Ivory.BSP.STM32.VectorTable (reset_handler)
import Ivory.BSP.STM32.ClockConfig
import Ivory.BSP.STM32.ClockInit (init_clocks)
import Ivory.BSP.STM32.MCU
import Data.STM32


data STM32FreeRTOSBackend = STM32FreeRTOSBackend

instance TowerBackend STM32FreeRTOSBackend where
  newtype TowerBackendCallback STM32FreeRTOSBackend a = STM32FreeRTOSCallback (forall s. AST.Handler -> AST.Thread -> (Def ('[ConstRef s a] ':-> ()), ModuleDef))
  newtype TowerBackendEmitter STM32FreeRTOSBackend = STM32FreeRTOSEmitter (Maybe (AST.Monitor -> AST.Thread -> EmitterCode))
  data TowerBackendHandler STM32FreeRTOSBackend a = STM32FreeRTOSHandler AST.Handler (forall s. AST.Monitor -> AST.Thread -> (Def ('[ConstRef s a] ':-> ()), ThreadCode))
  newtype TowerBackendMonitor STM32FreeRTOSBackend = STM32FreeRTOSMonitor (AST.Tower -> TowerBackendOutput STM32FreeRTOSBackend)
  data TowerBackendOutput STM32FreeRTOSBackend = STM32FreeRTOSOutput
    { compatoutput_threads :: Map.Map AST.Thread ThreadCode
    , compatoutput_monitors :: Map.Map AST.Monitor ModuleDef
    }

  callbackImpl _ ast f = STM32FreeRTOSCallback $ \ h t ->
    let p = proc (callbackProcName ast (AST.handler_name h) t) $ \ r -> body $ noReturn $ f r
    in (p, incl p)

  emitterImpl _ _ [] = (Emitter $ const $ return (), STM32FreeRTOSEmitter Nothing)
  emitterImpl _ ast handlers =
    ( Emitter $ call_ $ trampolineProc ast $ const $ return ()
    , STM32FreeRTOSEmitter $ Just $ \ mon thd -> emitterCode ast thd [ fst $ h mon thd | STM32FreeRTOSHandler _ h <- handlers ]
    )

  handlerImpl _ ast emitters callbacks = STM32FreeRTOSHandler ast $ \ mon thd ->
    let ems = [ e mon thd | STM32FreeRTOSEmitter (Just e) <- emitters ]
        (cbs, cbdefs) = unzip [ c ast thd | STM32FreeRTOSCallback c <- callbacks ]
        runner = handlerProc cbs ems thd mon ast
    in (runner, ThreadCode
      { threadcode_user = sequence_ cbdefs
      , threadcode_emitter = mapM_ emittercode_user ems
      , threadcode_gen = mapM_ emittercode_gen ems >> private (incl runner)
      })

  monitorImpl _ ast handlers moddef = STM32FreeRTOSMonitor $ \ twr -> STM32FreeRTOSOutput
    { compatoutput_threads = Map.fromListWith mappend
        [ (thd, snd $ h ast thd)
        -- handlers are reversed to match old output for convenient diffs
        | SomeHandler (STM32FreeRTOSHandler hast h) <- reverse handlers
        , thd <- AST.handlerThreads twr hast
        ]
    , compatoutput_monitors = Map.singleton ast moddef
    }

  towerImpl _ ast monitors = case mconcat monitors of STM32FreeRTOSMonitor f -> f ast

instance Semigroup (TowerBackendMonitor STM32FreeRTOSBackend) where
  (<>) (STM32FreeRTOSMonitor a) (STM32FreeRTOSMonitor b) = STM32FreeRTOSMonitor $ \twr -> a twr <> b twr

instance Monoid (TowerBackendMonitor STM32FreeRTOSBackend) where
  mempty = STM32FreeRTOSMonitor $ \_twr -> mempty

instance Semigroup (TowerBackendOutput STM32FreeRTOSBackend) where
  (<>) a b = STM32FreeRTOSOutput
    { compatoutput_threads = Map.unionWith mappend (compatoutput_threads a) (compatoutput_threads b)
    , compatoutput_monitors = Map.unionWith (>>) (compatoutput_monitors a) (compatoutput_monitors b)
    }

instance Monoid (TowerBackendOutput STM32FreeRTOSBackend) where
  mempty = STM32FreeRTOSOutput mempty mempty

data EmitterCode = EmitterCode
  { emittercode_init :: forall eff. Ivory eff ()
  , emittercode_deliver :: forall eff. Ivory eff ()
  , emittercode_user :: ModuleDef
  , emittercode_gen :: ModuleDef
  }

emitterCode :: (IvoryArea a, IvoryZero a)
            => AST.Emitter
            -> AST.Thread
            -> (forall s. [Def ('[ConstRef s a] ':-> ())])
            -> EmitterCode
emitterCode ast thr sinks = EmitterCode
  { emittercode_init = store (addrOf messageCount) 0
  , emittercode_deliver = do
      mc <- deref (addrOf messageCount)
      forM_ (zip messages [0..]) $ \ (m, index) ->
        I.when (fromInteger index <? mc) $
          forM_ sinks $ \ p ->
            call_ p (constRef (addrOf m))

  , emittercode_user = do
      private $ incl trampoline
  , emittercode_gen = do
      incl eproc
      private $ do
        mapM_ defMemArea messages
        defMemArea messageCount
  }
  where
  max_messages = AST.emitter_bound ast - 1
  messageCount :: MemArea ('Stored Uint32)
  messageCount = area (e_per_thread "message_count") Nothing

  messages = [ area (e_per_thread ("message_" ++ show d)) Nothing
             | d <- [0..max_messages] ]

  messageAt idx = foldl aux dflt (zip messages [0..])
    where
    dflt = addrOf (messages !! 0) -- Should be impossible.
    aux basecase (msg, midx) =
      (fromInteger midx ==? idx) ? (addrOf msg, basecase)

  trampoline = trampolineProc ast $ call_ eproc

  eproc = voidProc (e_per_thread "emit")  $ \ msg -> body $ do
               mc <- deref (addrOf messageCount)
               I.when (mc <=? fromInteger max_messages) $ do
                 store (addrOf messageCount) (mc + 1)
                 storedmsg <- assign (messageAt mc)
                 refCopy storedmsg msg

  e_per_thread suffix =
    emitterProcName ast ++ "_" ++ AST.threadName thr ++ "_" ++ suffix

trampolineProc :: IvoryArea a
               => AST.Emitter
               -> (forall eff. ConstRef s a -> Ivory eff ())
               -> Def ('[ConstRef s a] ':-> ())
trampolineProc ast f = proc (emitterProcName ast) $ \ r -> body $ f r

handlerProc :: (IvoryArea a, IvoryZero a)
            => [Def ('[ConstRef s a] ':-> ())]
            -> [EmitterCode]
            -> AST.Thread -> AST.Monitor -> AST.Handler
            -> Def ('[ConstRef s a] ':-> ())
handlerProc callbacks emitters t m h =
  proc (handlerProcName h t) $ \ msg -> body $ do
    comment "init emitters"
    mapM_ emittercode_init emitters
    comment "take monitor lock"
    call_ (monitorLockProc m)
    comment "run callbacks"
    forM_ callbacks $ \ cb -> call_ cb msg
    comment "release monitor lock"
    call_ (monitorUnlockProc m)
    comment "deliver emitters"
    mapM_ emittercode_deliver emitters

emitterProcName :: AST.Emitter -> String
emitterProcName e = showUnique (AST.emitter_name e)

callbackProcName :: Unique -> Unique -> AST.Thread -> String
callbackProcName callbackname _handlername tast
  =  showUnique callbackname
  ++ "_"
  ++ AST.threadName tast


--------

compileTowerSTM32FreeRTOS :: (e -> STM32Config) -> (TOpts -> IO e) -> Tower e () -> IO ()
compileTowerSTM32FreeRTOS toConf getEnv twr = do
  (copts, topts) <- towerGetOpts
  env <- getEnv topts

  let conf = toConf env
      namedMCU = confMCU conf
      cc = confClocks conf
      (ast, o, deps, sigs) = runTower_ compatBackend twr env

      mods = dependencies_modules deps
          ++ threadModules deps sigs (thread_codes o) ast
          ++ monitorModules deps (Map.toList (compatoutput_monitors o))
          ++ stm32Modules (snd namedMCU) cc ast

      givenArtifacts = dependencies_artifacts deps
      as = stm32Artifacts namedMCU cc ast mods givenArtifacts
  runCompiler mods (as ++ givenArtifacts) copts
  where
  compatBackend = STM32FreeRTOSBackend

  thread_codes o = Map.toList
                 $ Map.insertWith mappend (AST.InitThread AST.Init) mempty
                 $ compatoutput_threads o


stm32Modules :: MCU -> ClockConfig -> AST.Tower -> [Module]
stm32Modules mcu cc ast = systemModules ast ++ [ main_module, time_module ]
  where
  main_module :: Module
  main_module = package "stm32_main" $ do
    incl reset_handler_proc
    hw_moduledef
    private $ do
      incl (init_clocks (mcuFamily mcu) cc)
      incl init_relocate
      incl init_libc
      incl main_proc

  reset_handler_proc :: Def('[]':->())
  reset_handler_proc = proc reset_handler $ body $ do
    call_ init_relocate
    call_ (init_clocks (mcuFamily mcu) cc)
    call_ init_libc
    call_ main_proc

  init_relocate :: Def('[]':->())
  init_relocate = importProc "init_relocate" "stm32_freertos_init.h"
  init_libc :: Def('[]':->())
  init_libc = importProc "init_libc" "stm32_freertos_init.h"
  main_proc :: Def('[]':->())
  main_proc = importProc "main" "stm32_freertos_init.h"


stm32Artifacts :: NamedMCU -> ClockConfig -> AST.Tower -> [Module] -> [Located Artifact] -> [Located Artifact]
stm32Artifacts nmcu@(name, mcu) cc ast ms gcas = (systemArtifacts ast ms) ++ as
  where
  coreStr = freertosCore (shortName name) (mcuFamily mcu)
  as = [ STM32.makefile mcu makeobjs ] ++ STM32.artifacts nmcu
    ++ FreeRTOS.kernel coreStr fconfig ++ FreeRTOS.wrapper
    ++ hw_artifacts

  makeobjs = nub $ FreeRTOS.objects coreStr
          ++ [ moduleName m ++ ".o" | m <- ms ]
          ++ [ replaceExtension f ".o"
             | Src a <- gcas
             , let f = artifactFileName a
             , takeExtension f == ".c"
             ]

  numThreads :: Integer
  numThreads = fromIntegral $ length (AST.towerThreads ast)

  taskStackSize = stackSizeByRam (mcuRam mcu)

  fconfig = FreeRTOS.defaultConfig
    { FreeRTOS.max_priorities = numThreads + 1
    -- Task stack is allocated from FreeRTOS heap.
    -- This used to be half of the mcuRam but now
    -- uses a hopefully better heuristic
    , FreeRTOS.total_heap_size = taskStackSize * (numThreads + 1) * 2
    , FreeRTOS.cpu_clock_hz = clockSysClkHz cc
    , FreeRTOS.task_stack_size = taskStackSize
    }

-- just a guess, use smaller stack size on devices
-- with less memory
stackSizeByRam :: (Ord a, Num a, Num p) => a -> p
stackSizeByRam ram | ram <= 10 * 1024 = 768
stackSizeByRam ram | ram <= 32 * 1024 = 1024
stackSizeByRam ram | ram <= 64 * 1024 = 2048
stackSizeByRam _   | otherwise        = 2560
