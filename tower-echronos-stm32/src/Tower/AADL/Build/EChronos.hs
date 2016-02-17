{-# LANGUAGE QuasiQuotes       #-}
{-# LANGUAGE TypeOperators     #-}
{-# LANGUAGE DataKinds         #-}
{-# LANGUAGE OverloadedStrings #-}
-- Create Ramses build script.
--
-- (c) 2015 Galois, Inc.
--

module Tower.AADL.Build.EChronos where

import System.FilePath

import Ivory.Artifact
import Ivory.Language
import Ivory.Tower
import Ivory.HW

import Tower.AADL.Config (AADLConfig(..))
import Tower.AADL.Build.Common

import Ivory.BSP.ARMv7M.SysTick
import Ivory.BSP.STM32.Config
import Ivory.BSP.STM32.ClockConfig
import Ivory.BSP.STM32.ClockConfig.Init

--------------------------------------------------------------------------------
-- Ramses build

-- Ramses Makefile ------------------------------------------------------------
ramsesMakefile :: AADLConfig -> [MkStmt]
ramsesMakefile c =
  [ include    aadlFilesMk
  , includeOpt "../RAMSES_PATH.mk"
  , "RAMSES_PATH" ?= "./"
  , "SMACCM_PATH" ?= "./"
  , export $"RAMSES_DIR" === "$(RAMSES_PATH)/ramses_resource"
  , export $"AADL2RTOS_CONFIG_DIR" === "$(RAMSES_PATH)/aadl2rtos_resource"
  , Target ".PHONY" ["all", "tower-clean"] []
  , Target ".tag.ramses" []
    ["java -jar $(RAMSES_PATH)/ramses.jar -g rtos -i $(AADL2RTOS_CONFIG_DIR) \
          \-o . -l trace -s sys.impl -m SMACCM_SYS.aadl,$(AADL_LIST)"
    ,"touch .tag.ramses"
    ]
  , Target "tower-clean" []
    [ rm aadlFilesMk
    , rm "*.aadl"
    , rm (configSrcsDir c)
    , rm (configHdrDir  c)
    , rm ".tag.ramses"
    ]
  ]
  where
  rm s = "-rm -rf " ++ s

--------------------------------------------------------------------------------
echronosMakefileName :: FilePath
echronosMakefileName = "Makefile"

echronosMakefile :: [MkStmt]
echronosMakefile =
  [ "SHELL"       =: "/bin/bash"
  , "ROOT"        =: "$(shell pwd)"
  , "SRC"         =: "$(ROOT)/."
  , "EXE"         =: "sys"
  , "AS"          =: "arm-none-eabi-as -mthumb -g3 -mlittle-endian -mcpu=cortex-m4 \\\n\
               \      -mfloat-abi=hard -mfpu=fpv4-sp-d16 -I$(SRC) -I$(SRC)/include"
  , "CC"          =: "arm-none-eabi-gcc"
  , "CFLAGS"      =: "-Os -g3 -Wall -Werror              \\\n\
           \          -std=gnu99                         \\\n\
           \          -Wno-parentheses                   \\\n\
           \          -Wno-unused-function               \\\n\
           \          -Wno-unused-variable               \\\n\
           \          -Wno-main                          \\\n\
           \          -mlittle-endian                    \\\n\
           \          -mthumb -mcpu=cortex-m4            \\\n\
           \          -mfloat-abi=hard -mfpu=fpv4-sp-d16 \\\n\
           \          -I$(SRC)                           \\\n\
           \          -I$(SRC)/include                   \\\n\
           \          -I$(SRC)/lib/include               \\\n\
           \          -I$(SRC)/gen                       \\\n\
           \          -I$(SRC)/echronos_gen"
  , "LDSCRIPT"    =: "$(SRC)/echronos_gen/default.ld"
  , "LDFLAGS"     =: "-Wl,--script=$(LDSCRIPT)           \\\n\
          \           -nostartfiles                      \\\n\
          \           -mlittle-endian                    \\\n\
          \           -mthumb -mcpu=cortex-m4            \\\n\
          \           -mfloat-abi=hard -mfpu=fpv4-sp-d16"
  , "LDLIBS"      =: "-lm"
  , "LD"          =: "arm-none-eabi-gcc"
  , "SOURCES_GCC" =: "$(wildcard $(SRC)/src/*.c)                \\\n\
      \               $(wildcard $(SRC)/lib/src/*.c)            \\\n\
      \               $(wildcard $(SRC)/gen/*.c)                \\\n\
      \               $(wildcard $(SRC)/echronos_gen/*.c)"
  , "SOURCES_AS"  =: "$(wildcard $(SRC)/src/*.s)                \\\n\
       \              $(wildcard $(SRC)/gen/*.s)                \\\n\
       \              $(wildcard $(SRC)/echronos_gen/*.s)"
  , "OBJECTS_GCC" =: "$(SOURCES_GCC:.c=.o)"
  , "OBJECTS_AS"  =: "$(SOURCES_AS:.s=.o)"
  , "VPATH"       =: "$(SRC)"
  , Target "$(EXE)" ["$(OBJECTS_GCC)", "$(OBJECTS_AS)"]
    ["@echo building executable from assembly files: $(OBJECTS_AS) and .c files: $(OBJECTS_GCC)"
    ,"@echo linking executable"
    ,"$(LD) $(LDFLAGS) -o $@ $^ $(LDLIBS)"]
  , Target ".PHONY" ["echronos-clean"] []
  , Target "echronos-clean" []
    ["@echo remove all the object files"
    ,"rm -f *.o"
    ,"@echo remove the executable, if any"
    ,"rm -f $(SYS)"]
  ]

makefile :: [MkStmt]
makefile = [ Comment "Make sure 'all' is the first target by putting it before any includes"
           , Target "all" ["generate"]
             [ "# This sub-make is here to deal with $(EXE) depending on"
             , "# files that have to be generated first. This requires us"
             , "# to do the build in two phases."
             , "make $(EXE)" ]
           , includeOpt ramsesMakefileName
           , Comment "We assume ECHRONOS_LOCATION and PRJ are set in PRJ_CMD.mk \\\n\
                     \ECHRONOS_LOCATION should be the path to the echronos install where\\\n\
                     \the setenv script and packages can be found. For example, the top of\\\n\
                     \your echronos repository. PRJ should point to the prj tool."
           , includeOpt "../PRJ_CMD.mk"
           , "PRJ" ?= "prj"
           , "ECHRONOS_LOCATION" ?= "$(shell which prj)"
           , Target ".PHONY" ["generate", "clean"] []
           , Target "generate" [".tag.echronos", ".tag.ramses"] []
           , Target ".tag.echronos" [".tag.ramses"]
             [ "pushd $(ECHRONOS_LOCATION) && source setenv && popd &&  \\\n\
             \  $(PRJ) --output echronos_gen                            \\\n\
             \         --search-path $(ECHRONOS_LOCATION)/packages      \\\n\
             \         --no-project                                     \\\n\
             \         gen                                              \\\n\
             \         sys_impl.prx"
             , "touch .tag.echronos"
             ]
           , Target "clean" ["echronos-clean", "tower-clean"]
             [ "rm -f .tag.echronos" ]
           , include    ("gen" </> echronosMakefileName) ]

echronosArtifacts :: AADLConfig -> [Located Artifact]
echronosArtifacts cfg = map Root ls ++ hw_artifacts
  where
  ls :: [Artifact]
  ls = artifactString
         ramsesMakefileName
         (renderMkStmts (ramsesMakefile cfg))
     : osSpecific
  osSpecific =
      [ artifactString
          makefileName
          (renderMkStmts makefile)
      , artifactPath
          "gen"
          (artifactString
            echronosMakefileName
            (renderMkStmts echronosMakefile)) ]

defaultEChronosOS :: STM32Config -> OSSpecific STM32Config e
defaultEChronosOS cfg =
  OSSpecific
    { osSpecificName      = "eChronos"
    , osSpecificConfig    = cfg
    , osSpecificArtifacts = const echronosArtifacts
    , osSpecificSrcDir    = const id
    , osSpecificTower     = eChronosModules cfg
    }

----------------------------------------------------------------------------
-- eChronos requires a custom main() function ------------------------------
----------------------------------------------------------------------------
mainProc :: STM32Config -> Def ('[] :-> ())
mainProc cfg = proc "main" $ body $ do

  -- XXX: We premultiply by 8 here because Mike's clock init code divides by 8.
  -- His code assumes the systick clock source is always AHB/8. That is his code
  -- sets bit 2 of the STK_CTRL register is always 0.
  let rate = 8*fromIntegral (clockSysClkHz (stm32config_clock cfg))
  call_ (init_clocks (stm32config_clock cfg))
  call_ clock_set_cpu_rate_in_hz rate
  result <- call initialize_periodic_dispatcher
  ifte_ (iNot result)
    (do call_ debug_println "Unable to initialize periodic dispatcher."
        call_ fatal (-1))
    (return ())

  call_ debug_println "Starting RTOS"
  call_ rtos_start
  forever (return ())

eChronosModules :: STM32Config -> Tower e ()
eChronosModules cfg = do
  towerModule  towerDepModule
  towerDepends towerDepModule
  towerModule  (mainMod cfg)
  towerDepends (mainMod cfg)
  towerModule  timeModule
  towerDepends timeModule

initialize_periodic_dispatcher :: Def('[] :-> IBool)
initialize_periodic_dispatcher =
  importProc "initialize_periodic_dispatcher" "smaccm_decls.h"

clock_set_cpu_rate_in_hz  :: Def('[Sint64] :-> ())
clock_set_cpu_rate_in_hz  =
  importProc "clock_set_cpu_rate_in_hz" "clock_driver.h"

debug_println :: Def('[IString] :-> ())
debug_println = importProc "debug_println" "debug.h"

debug_printhex8 :: Def('[Uint8] :-> ())
debug_printhex8 = importProc "debug_printhex8" "debug.h"

debug_print :: Def('[IString] :-> ())
debug_print = importProc "debug_print" "debug.h"

type RTosErrorId = Uint8

fatal :: Def('[RTosErrorId] :-> ())
fatal = proc "fatal" $ \error_id -> body $ do
  call_ debug_print "FATAL ERROR: "
  call_ debug_printhex8 error_id
  call_ debug_println ""
  forever (return ())

rtos_start :: Def ('[] :-> ())
rtos_start = importProc "rtos_start" "rtos-kochab.h"

[ivory|
import (stdio.h, printf) void printf(string x, uint8_t y)
|]

inclSysTick :: STM32Config -> ModuleDef
inclSysTick cfg = do
  let config = SysTickConfig
        { sysTickProcessorHz   = clockSysClkHz (stm32config_clock cfg)
        , sysTickClockFactor   = Processor
        , sysTickInterruptMode = Interrupt
        }
  let storedInterval = area "stored_interval" (Just (ival 0))
      elapsedTicks = area "elapsed_ticks" (Just (ival 0))
  private $ do
    defMemArea storedInterval
    defMemArea elapsedTicks
  incl (clock_set_interval_in_us config (addrOf storedInterval))
  incl (clock_set_interval_in_ms config (addrOf storedInterval))
  incl (clock_start_timer (addrOf elapsedTicks))
  incl (clock_get_time (addrOf storedInterval) (addrOf elapsedTicks))
  incl (clock_irq_callback (addrOf elapsedTicks))
  incl clock_init

mainMod :: STM32Config -> Module
mainMod cfg = package "main" $ do
  incl (init_clocks (stm32config_clock cfg))
  hw_moduledef
  incl debug_println
  incl debug_print
  incl debug_printhex8
  incl fatal
  incl (mainProc cfg)
--  inclSysTick cfg
  incl initialize_periodic_dispatcher
  incl rtos_start
  incl clock_set_cpu_rate_in_hz

towerDepModule :: Module
towerDepModule = package "towerDeps" $ do
  incl printf

-- Tower's time function

timeModule :: Module
timeModule = package "tower_time" $ do
  -- T.moddef
  incl getTimeProc
  incl clock_get_time
  where
  getTimeProc :: Def('[]:->ITime)
  getTimeProc = proc "tower_get_time" $ body $ do
    t <- call clock_get_time
    ret t
  -- XXX: This is really Uint64 not ITime aka Sint64
  clock_get_time :: Def('[]:->ITime)
  clock_get_time = importProc "clock_get_time" "clock_driver.h"
