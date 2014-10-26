{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}

module Ivory.Tower.Codegen.Monitor
  ( generateMonitorCode
  , monitorInitProc
  , monitorLockProc
  , monitorUnlockProc
  , monitorStateModName
  , monitorGenModName
  ) where

import Ivory.Tower.Types.MonitorCode

import qualified Ivory.Tower.AST as AST

import Ivory.Language

monitorStateModName :: AST.Monitor -> String
monitorStateModName mon = "tower_state_monitor_" ++ AST.monitorName mon

monitorGenModName :: AST.Monitor -> String
monitorGenModName mon = "tower_gen_monitor_" ++ AST.monitorName mon

generateMonitorCode :: MonitorCode
                    -> AST.Monitor
                    -> [Module]
generateMonitorCode mc mon =
  [ package (monitorStateModName mon) (monitorcode_moddef mc)
  , package (monitorGenModName mon) gen_pkg
  ]
  where
  gen_pkg = do
    incl (monitorInitProc mon)
    incl (monitorLockProc mon)
    incl (monitorUnlockProc mon)

monitorLockName :: AST.Monitor -> String
monitorLockName mon = "lock_"  ++ AST.monitorName mon

monitorInitProc :: AST.Monitor -> Def('[]:->())
monitorInitProc mon = proc n $ body $
  comment ("init " ++ monitorLockName mon)
  where
  n = "monitor_init_" ++ AST.monitorName mon

monitorUnlockProc :: AST.Monitor -> Def('[]:->())
monitorUnlockProc mon = proc n $ body $
  comment ("give " ++ monitorLockName mon) -- XXX fill in with proper code
  where
  n = "monitor_unlock_" ++ AST.monitorName mon

monitorLockProc :: AST.Monitor -> Def('[]:->())
monitorLockProc mon = proc n $ body $
  comment ("take " ++ monitorLockName mon) -- XXX fill in with proper code
  where
  n = "monitor_lock_" ++ AST.monitorName mon