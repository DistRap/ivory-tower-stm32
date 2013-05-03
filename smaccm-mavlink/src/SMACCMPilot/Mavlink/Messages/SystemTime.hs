{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.SystemTime where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

systemTimeMsgId :: Uint8
systemTimeMsgId = 2

systemTimeCrcExtra :: Uint8
systemTimeCrcExtra = 137

systemTimeModule :: Module
systemTimeModule = package "mavlink_system_time_msg" $ do
  depend packModule
  incl systemTimeUnpack
  defStruct (Proxy :: Proxy "system_time_msg")

[ivory|
struct system_time_msg
  { time_unix_usec :: Stored Uint64
  ; time_boot_ms :: Stored Uint32
  }
|]

mkSystemTimeSender :: SizedMavlinkSender 12
                       -> Def ('[ ConstRef s (Struct "system_time_msg") ] :-> ())
mkSystemTimeSender sender =
  proc ("mavlink_system_time_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    systemTimePack (senderMacro sender) msg

instance MavlinkSendable "system_time_msg" 12 where
  mkSender = mkSystemTimeSender

systemTimePack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 12
                  -> ConstRef s1 (Struct "system_time_msg")
                  -> Ivory eff ()
systemTimePack sender msg = do
  arr <- local (iarray [] :: Init (Array 12 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_unix_usec)
  call_ pack buf 8 =<< deref (msg ~> time_boot_ms)
  sender systemTimeMsgId (constRef arr) systemTimeCrcExtra
  retVoid

instance MavlinkUnpackableMsg "system_time_msg" where
    unpackMsg = ( systemTimeUnpack , systemTimeMsgId )

systemTimeUnpack :: Def ('[ Ref s1 (Struct "system_time_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
systemTimeUnpack = proc "mavlink_system_time_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_unix_usec) =<< call unpack buf 0
  store (msg ~> time_boot_ms) =<< call unpack buf 8

