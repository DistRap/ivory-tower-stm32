{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE Rank2Types #-}

module SMACCMPilot.Mavlink.Messages
  ( mavlinkMessageModules
  , messageLensCRCs
  ) where

import Data.Word (Word8)
import Ivory.Language

import qualified SMACCMPilot.Mavlink.Messages.Heartbeat
import qualified SMACCMPilot.Mavlink.Messages.SysStatus
import qualified SMACCMPilot.Mavlink.Messages.SystemTime
import qualified SMACCMPilot.Mavlink.Messages.Ping
import qualified SMACCMPilot.Mavlink.Messages.ChangeOperatorControl
import qualified SMACCMPilot.Mavlink.Messages.ChangeOperatorControlAck
import qualified SMACCMPilot.Mavlink.Messages.AuthKey
import qualified SMACCMPilot.Mavlink.Messages.SetMode
import qualified SMACCMPilot.Mavlink.Messages.ParamRequestRead
import qualified SMACCMPilot.Mavlink.Messages.ParamRequestList
import qualified SMACCMPilot.Mavlink.Messages.ParamValue
import qualified SMACCMPilot.Mavlink.Messages.ParamSet
import qualified SMACCMPilot.Mavlink.Messages.GpsRawInt
import qualified SMACCMPilot.Mavlink.Messages.GpsStatus
import qualified SMACCMPilot.Mavlink.Messages.ScaledImu
import qualified SMACCMPilot.Mavlink.Messages.RawImu
import qualified SMACCMPilot.Mavlink.Messages.RawPressure
import qualified SMACCMPilot.Mavlink.Messages.ScaledPressure
import qualified SMACCMPilot.Mavlink.Messages.Attitude
import qualified SMACCMPilot.Mavlink.Messages.AttitudeQuaternion
import qualified SMACCMPilot.Mavlink.Messages.LocalPositionNed
import qualified SMACCMPilot.Mavlink.Messages.GlobalPositionInt
import qualified SMACCMPilot.Mavlink.Messages.RcChannelsScaled
import qualified SMACCMPilot.Mavlink.Messages.RcChannelsRaw
import qualified SMACCMPilot.Mavlink.Messages.ServoOutputRaw
import qualified SMACCMPilot.Mavlink.Messages.MissionRequestPartialList
import qualified SMACCMPilot.Mavlink.Messages.MissionWritePartialList
import qualified SMACCMPilot.Mavlink.Messages.MissionItem
import qualified SMACCMPilot.Mavlink.Messages.MissionRequest
import qualified SMACCMPilot.Mavlink.Messages.MissionSetCurrent
import qualified SMACCMPilot.Mavlink.Messages.MissionCurrent
import qualified SMACCMPilot.Mavlink.Messages.MissionRequestList
import qualified SMACCMPilot.Mavlink.Messages.MissionCount
import qualified SMACCMPilot.Mavlink.Messages.MissionClearAll
import qualified SMACCMPilot.Mavlink.Messages.MissionItemReached
import qualified SMACCMPilot.Mavlink.Messages.MissionAck
import qualified SMACCMPilot.Mavlink.Messages.SetGpsGlobalOrigin
import qualified SMACCMPilot.Mavlink.Messages.GpsGlobalOrigin
import qualified SMACCMPilot.Mavlink.Messages.SetLocalPositionSetpoint
import qualified SMACCMPilot.Mavlink.Messages.LocalPositionSetpoint
import qualified SMACCMPilot.Mavlink.Messages.GlobalPositionSetpointInt
import qualified SMACCMPilot.Mavlink.Messages.SetGlobalPositionSetpointInt
import qualified SMACCMPilot.Mavlink.Messages.SafetySetAllowedArea
import qualified SMACCMPilot.Mavlink.Messages.SafetyAllowedArea
import qualified SMACCMPilot.Mavlink.Messages.SetRollPitchYawThrust
import qualified SMACCMPilot.Mavlink.Messages.SetRollPitchYawSpeedThrust
import qualified SMACCMPilot.Mavlink.Messages.RollPitchYawThrustSetpoint
import qualified SMACCMPilot.Mavlink.Messages.RollPitchYawSpeedThrustSetpoint
import qualified SMACCMPilot.Mavlink.Messages.SetQuadMotorsSetpoint
import qualified SMACCMPilot.Mavlink.Messages.SetQuadSwarmRollPitchYawThrust
import qualified SMACCMPilot.Mavlink.Messages.NavControllerOutput
import qualified SMACCMPilot.Mavlink.Messages.SetQuadSwarmLedRollPitchYawThrust
import qualified SMACCMPilot.Mavlink.Messages.StateCorrection
import qualified SMACCMPilot.Mavlink.Messages.RequestDataStream
import qualified SMACCMPilot.Mavlink.Messages.DataStream
import qualified SMACCMPilot.Mavlink.Messages.ManualControl
import qualified SMACCMPilot.Mavlink.Messages.RcChannelsOverride
import qualified SMACCMPilot.Mavlink.Messages.VfrHud
import qualified SMACCMPilot.Mavlink.Messages.CommandLong
import qualified SMACCMPilot.Mavlink.Messages.CommandAck
import qualified SMACCMPilot.Mavlink.Messages.RollPitchYawRatesThrustSetpoint
import qualified SMACCMPilot.Mavlink.Messages.ManualSetpoint
import qualified SMACCMPilot.Mavlink.Messages.LocalPositionNedSystemGlobalOffset
import qualified SMACCMPilot.Mavlink.Messages.HilState
import qualified SMACCMPilot.Mavlink.Messages.HilControls
import qualified SMACCMPilot.Mavlink.Messages.HilRcInputsRaw
import qualified SMACCMPilot.Mavlink.Messages.OpticalFlow
import qualified SMACCMPilot.Mavlink.Messages.GlobalVisionPositionEstimate
import qualified SMACCMPilot.Mavlink.Messages.VisionPositionEstimate
import qualified SMACCMPilot.Mavlink.Messages.VisionSpeedEstimate
import qualified SMACCMPilot.Mavlink.Messages.ViconPositionEstimate
import qualified SMACCMPilot.Mavlink.Messages.HighresImu
import qualified SMACCMPilot.Mavlink.Messages.FileTransferStart
import qualified SMACCMPilot.Mavlink.Messages.FileTransferDirList
import qualified SMACCMPilot.Mavlink.Messages.FileTransferRes
import qualified SMACCMPilot.Mavlink.Messages.BatteryStatus
import qualified SMACCMPilot.Mavlink.Messages.Setpoint8dof
import qualified SMACCMPilot.Mavlink.Messages.Setpoint6dof
import qualified SMACCMPilot.Mavlink.Messages.MemoryVect
import qualified SMACCMPilot.Mavlink.Messages.DebugVect
import qualified SMACCMPilot.Mavlink.Messages.NamedValueFloat
import qualified SMACCMPilot.Mavlink.Messages.NamedValueInt
import qualified SMACCMPilot.Mavlink.Messages.Statustext
import qualified SMACCMPilot.Mavlink.Messages.Debug

mavlinkMessageModules :: [Module]
mavlinkMessageModules =
  [ SMACCMPilot.Mavlink.Messages.Heartbeat.heartbeatModule
  , SMACCMPilot.Mavlink.Messages.SysStatus.sysStatusModule
  , SMACCMPilot.Mavlink.Messages.SystemTime.systemTimeModule
  , SMACCMPilot.Mavlink.Messages.Ping.pingModule
  , SMACCMPilot.Mavlink.Messages.ChangeOperatorControl.changeOperatorControlModule
  , SMACCMPilot.Mavlink.Messages.ChangeOperatorControlAck.changeOperatorControlAckModule
  , SMACCMPilot.Mavlink.Messages.AuthKey.authKeyModule
  , SMACCMPilot.Mavlink.Messages.SetMode.setModeModule
  , SMACCMPilot.Mavlink.Messages.ParamRequestRead.paramRequestReadModule
  , SMACCMPilot.Mavlink.Messages.ParamRequestList.paramRequestListModule
  , SMACCMPilot.Mavlink.Messages.ParamValue.paramValueModule
  , SMACCMPilot.Mavlink.Messages.ParamSet.paramSetModule
  , SMACCMPilot.Mavlink.Messages.GpsRawInt.gpsRawIntModule
  , SMACCMPilot.Mavlink.Messages.GpsStatus.gpsStatusModule
  , SMACCMPilot.Mavlink.Messages.ScaledImu.scaledImuModule
  , SMACCMPilot.Mavlink.Messages.RawImu.rawImuModule
  , SMACCMPilot.Mavlink.Messages.RawPressure.rawPressureModule
  , SMACCMPilot.Mavlink.Messages.ScaledPressure.scaledPressureModule
  , SMACCMPilot.Mavlink.Messages.Attitude.attitudeModule
  , SMACCMPilot.Mavlink.Messages.AttitudeQuaternion.attitudeQuaternionModule
  , SMACCMPilot.Mavlink.Messages.LocalPositionNed.localPositionNedModule
  , SMACCMPilot.Mavlink.Messages.GlobalPositionInt.globalPositionIntModule
  , SMACCMPilot.Mavlink.Messages.RcChannelsScaled.rcChannelsScaledModule
  , SMACCMPilot.Mavlink.Messages.RcChannelsRaw.rcChannelsRawModule
  , SMACCMPilot.Mavlink.Messages.ServoOutputRaw.servoOutputRawModule
  , SMACCMPilot.Mavlink.Messages.MissionRequestPartialList.missionRequestPartialListModule
  , SMACCMPilot.Mavlink.Messages.MissionWritePartialList.missionWritePartialListModule
  , SMACCMPilot.Mavlink.Messages.MissionItem.missionItemModule
  , SMACCMPilot.Mavlink.Messages.MissionRequest.missionRequestModule
  , SMACCMPilot.Mavlink.Messages.MissionSetCurrent.missionSetCurrentModule
  , SMACCMPilot.Mavlink.Messages.MissionCurrent.missionCurrentModule
  , SMACCMPilot.Mavlink.Messages.MissionRequestList.missionRequestListModule
  , SMACCMPilot.Mavlink.Messages.MissionCount.missionCountModule
  , SMACCMPilot.Mavlink.Messages.MissionClearAll.missionClearAllModule
  , SMACCMPilot.Mavlink.Messages.MissionItemReached.missionItemReachedModule
  , SMACCMPilot.Mavlink.Messages.MissionAck.missionAckModule
  , SMACCMPilot.Mavlink.Messages.SetGpsGlobalOrigin.setGpsGlobalOriginModule
  , SMACCMPilot.Mavlink.Messages.GpsGlobalOrigin.gpsGlobalOriginModule
  , SMACCMPilot.Mavlink.Messages.SetLocalPositionSetpoint.setLocalPositionSetpointModule
  , SMACCMPilot.Mavlink.Messages.LocalPositionSetpoint.localPositionSetpointModule
  , SMACCMPilot.Mavlink.Messages.GlobalPositionSetpointInt.globalPositionSetpointIntModule
  , SMACCMPilot.Mavlink.Messages.SetGlobalPositionSetpointInt.setGlobalPositionSetpointIntModule
  , SMACCMPilot.Mavlink.Messages.SafetySetAllowedArea.safetySetAllowedAreaModule
  , SMACCMPilot.Mavlink.Messages.SafetyAllowedArea.safetyAllowedAreaModule
  , SMACCMPilot.Mavlink.Messages.SetRollPitchYawThrust.setRollPitchYawThrustModule
  , SMACCMPilot.Mavlink.Messages.SetRollPitchYawSpeedThrust.setRollPitchYawSpeedThrustModule
  , SMACCMPilot.Mavlink.Messages.RollPitchYawThrustSetpoint.rollPitchYawThrustSetpointModule
  , SMACCMPilot.Mavlink.Messages.RollPitchYawSpeedThrustSetpoint.rollPitchYawSpeedThrustSetpointModule
  , SMACCMPilot.Mavlink.Messages.SetQuadMotorsSetpoint.setQuadMotorsSetpointModule
  , SMACCMPilot.Mavlink.Messages.SetQuadSwarmRollPitchYawThrust.setQuadSwarmRollPitchYawThrustModule
  , SMACCMPilot.Mavlink.Messages.NavControllerOutput.navControllerOutputModule
  , SMACCMPilot.Mavlink.Messages.SetQuadSwarmLedRollPitchYawThrust.setQuadSwarmLedRollPitchYawThrustModule
  , SMACCMPilot.Mavlink.Messages.StateCorrection.stateCorrectionModule
  , SMACCMPilot.Mavlink.Messages.RequestDataStream.requestDataStreamModule
  , SMACCMPilot.Mavlink.Messages.DataStream.dataStreamModule
  , SMACCMPilot.Mavlink.Messages.ManualControl.manualControlModule
  , SMACCMPilot.Mavlink.Messages.RcChannelsOverride.rcChannelsOverrideModule
  , SMACCMPilot.Mavlink.Messages.VfrHud.vfrHudModule
  , SMACCMPilot.Mavlink.Messages.CommandLong.commandLongModule
  , SMACCMPilot.Mavlink.Messages.CommandAck.commandAckModule
  , SMACCMPilot.Mavlink.Messages.RollPitchYawRatesThrustSetpoint.rollPitchYawRatesThrustSetpointModule
  , SMACCMPilot.Mavlink.Messages.ManualSetpoint.manualSetpointModule
  , SMACCMPilot.Mavlink.Messages.LocalPositionNedSystemGlobalOffset.localPositionNedSystemGlobalOffsetModule
  , SMACCMPilot.Mavlink.Messages.HilState.hilStateModule
  , SMACCMPilot.Mavlink.Messages.HilControls.hilControlsModule
  , SMACCMPilot.Mavlink.Messages.HilRcInputsRaw.hilRcInputsRawModule
  , SMACCMPilot.Mavlink.Messages.OpticalFlow.opticalFlowModule
  , SMACCMPilot.Mavlink.Messages.GlobalVisionPositionEstimate.globalVisionPositionEstimateModule
  , SMACCMPilot.Mavlink.Messages.VisionPositionEstimate.visionPositionEstimateModule
  , SMACCMPilot.Mavlink.Messages.VisionSpeedEstimate.visionSpeedEstimateModule
  , SMACCMPilot.Mavlink.Messages.ViconPositionEstimate.viconPositionEstimateModule
  , SMACCMPilot.Mavlink.Messages.HighresImu.highresImuModule
  , SMACCMPilot.Mavlink.Messages.FileTransferStart.fileTransferStartModule
  , SMACCMPilot.Mavlink.Messages.FileTransferDirList.fileTransferDirListModule
  , SMACCMPilot.Mavlink.Messages.FileTransferRes.fileTransferResModule
  , SMACCMPilot.Mavlink.Messages.BatteryStatus.batteryStatusModule
  , SMACCMPilot.Mavlink.Messages.Setpoint8dof.setpoint8dofModule
  , SMACCMPilot.Mavlink.Messages.Setpoint6dof.setpoint6dofModule
  , SMACCMPilot.Mavlink.Messages.MemoryVect.memoryVectModule
  , SMACCMPilot.Mavlink.Messages.DebugVect.debugVectModule
  , SMACCMPilot.Mavlink.Messages.NamedValueFloat.namedValueFloatModule
  , SMACCMPilot.Mavlink.Messages.NamedValueInt.namedValueIntModule
  , SMACCMPilot.Mavlink.Messages.Statustext.statustextModule
  , SMACCMPilot.Mavlink.Messages.Debug.debugModule
  ]


messageLensCRCs :: [(Word8, (Word8, Word8))]
messageLensCRCs =
  [ (0, (9, 50))
  , (1, (31, 124))
  , (2, (12, 137))
  , (4, (14, 237))
  , (5, (28, 217))
  , (6, (3, 104))
  , (7, (32, 119))
  , (11, (6, 89))
  , (20, (20, 214))
  , (21, (2, 159))
  , (22, (25, 220))
  , (23, (23, 168))
  , (24, (30, 24))
  , (25, (101, 23))
  , (26, (22, 170))
  , (27, (26, 144))
  , (28, (16, 67))
  , (29, (14, 115))
  , (30, (28, 39))
  , (31, (32, 246))
  , (32, (28, 185))
  , (33, (28, 104))
  , (34, (22, 237))
  , (35, (22, 244))
  , (36, (21, 222))
  , (37, (6, 212))
  , (38, (6, 9))
  , (39, (37, 254))
  , (40, (4, 230))
  , (41, (4, 28))
  , (42, (2, 28))
  , (43, (2, 132))
  , (44, (4, 221))
  , (45, (2, 232))
  , (46, (2, 11))
  , (47, (3, 153))
  , (48, (13, 41))
  , (49, (12, 39))
  , (50, (19, 214))
  , (51, (17, 223))
  , (52, (15, 141))
  , (53, (15, 33))
  , (54, (27, 15))
  , (55, (25, 3))
  , (56, (18, 100))
  , (57, (18, 24))
  , (58, (20, 239))
  , (59, (20, 238))
  , (60, (9, 30))
  , (61, (34, 240))
  , (62, (26, 183))
  , (63, (46, 130))
  , (64, (36, 130))
  , (66, (6, 148))
  , (67, (4, 21))
  , (69, (11, 243))
  , (70, (18, 124))
  , (74, (20, 20))
  , (76, (33, 152))
  , (77, (3, 143))
  , (80, (20, 127))
  , (81, (22, 106))
  , (89, (28, 231))
  , (90, (56, 183))
  , (91, (42, 63))
  , (92, (33, 54))
  , (100, (26, 175))
  , (101, (32, 102))
  , (102, (32, 158))
  , (103, (20, 208))
  , (104, (32, 56))
  , (105, (62, 93))
  , (110, (254, 235))
  , (111, (249, 93))
  , (112, (9, 124))
  , (147, (16, 42))
  , (148, (33, 241))
  , (149, (25, 15))
  , (249, (36, 204))
  , (250, (30, 49))
  , (251, (18, 170))
  , (252, (18, 44))
  , (253, (51, 83))
  , (254, (9, 46))
  ]


