{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.MissionCount where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

missionCountMsgId :: Uint8
missionCountMsgId = 44

missionCountCrcExtra :: Uint8
missionCountCrcExtra = 221

missionCountModule :: Module
missionCountModule = package "mavlink_mission_count_msg" $ do
  depend packModule
  incl missionCountUnpack
  defStruct (Proxy :: Proxy "mission_count_msg")

[ivory|
struct mission_count_msg
  { count :: Stored Uint16
  ; target_system :: Stored Uint8
  ; target_component :: Stored Uint8
  }
|]

mkMissionCountSender :: SizedMavlinkSender 4
                       -> Def ('[ ConstRef s (Struct "mission_count_msg") ] :-> ())
mkMissionCountSender sender =
  proc ("mavlink_mission_count_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    missionCountPack (senderMacro sender) msg

instance MavlinkSendable "mission_count_msg" 4 where
  mkSender = mkMissionCountSender

missionCountPack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 4
                  -> ConstRef s1 (Struct "mission_count_msg")
                  -> Ivory eff ()
missionCountPack sender msg = do
  arr <- local (iarray [] :: Init (Array 4 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> count)
  call_ pack buf 2 =<< deref (msg ~> target_system)
  call_ pack buf 3 =<< deref (msg ~> target_component)
  sender missionCountMsgId (constRef arr) missionCountCrcExtra
  retVoid

instance MavlinkUnpackableMsg "mission_count_msg" where
    unpackMsg = ( missionCountUnpack , missionCountMsgId )

missionCountUnpack :: Def ('[ Ref s1 (Struct "mission_count_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
missionCountUnpack = proc "mavlink_mission_count_unpack" $ \ msg buf -> body $ do
  store (msg ~> count) =<< call unpack buf 0
  store (msg ~> target_system) =<< call unpack buf 2
  store (msg ~> target_component) =<< call unpack buf 3

