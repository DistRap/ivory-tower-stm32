{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE QuasiQuotes #-}

module SMACCMPilot.Flight.Sensors.Task
  ( sensorsTask
  ) where

import Ivory.Language
import Ivory.Tower
import qualified Ivory.OS.FreeRTOS as OS

import qualified SMACCMPilot.Flight.Types.Sensors as S

import SMACCMPilot.Util.IvoryHelpers
import SMACCMPilot.Util.Periodic

sensorsTask :: Source (Struct "sensors_result")
              -> String -> Task
sensorsTask s uniquename =
  withSource "sensors" s $ \sensorSource ->
  let tDef = proc ("sensorTaskDef" ++ uniquename) $ body $ do
        s_result <- local (istruct [ S.valid .= ival false ])
        source sensorSource (constRef s_result)
        call_ sensors_begin -- time consuming: boots up and calibrates sensors
        periodic 10 $ do
          call_ sensors_update
          call_ sensors_getstate s_result
          source sensorSource (constRef s_result)

      mDefs = do
        depend S.sensorsTypeModule
        depend OS.taskModule
        inclHeader "sensors_capture"
        incl tDef
        private $ do
          incl sensors_begin
          incl sensors_update
          incl sensors_getstate

  in task tDef mDefs


sensors_begin :: Def ('[] :-> ())
sensors_begin = externProc "sensors_begin"

sensors_update :: Def ('[] :-> ())
sensors_update = externProc "sensors_update"

sensors_getstate :: Def ('[Ref s (Struct "sensors_result")] :-> ())
sensors_getstate = externProc "sensors_getstate"
