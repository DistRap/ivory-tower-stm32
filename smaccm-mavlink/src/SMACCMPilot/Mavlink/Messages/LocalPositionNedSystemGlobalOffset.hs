{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.LocalPositionNedSystemGlobalOffset where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

localPositionNedSystemGlobalOffsetMsgId :: Uint8
localPositionNedSystemGlobalOffsetMsgId = 89

localPositionNedSystemGlobalOffsetCrcExtra :: Uint8
localPositionNedSystemGlobalOffsetCrcExtra = 231

localPositionNedSystemGlobalOffsetModule :: Module
localPositionNedSystemGlobalOffsetModule = package "mavlink_local_position_ned_system_global_offset_msg" $ do
  depend packModule
  incl localPositionNedSystemGlobalOffsetUnpack
  defStruct (Proxy :: Proxy "local_position_ned_system_global_offset_msg")

[ivory|
struct local_position_ned_system_global_offset_msg
  { time_boot_ms :: Stored Uint32
  ; x :: Stored IFloat
  ; y :: Stored IFloat
  ; z :: Stored IFloat
  ; roll :: Stored IFloat
  ; pitch :: Stored IFloat
  ; yaw :: Stored IFloat
  }
|]

mkLocalPositionNedSystemGlobalOffsetSender :: SizedMavlinkSender 28
                       -> Def ('[ ConstRef s (Struct "local_position_ned_system_global_offset_msg") ] :-> ())
mkLocalPositionNedSystemGlobalOffsetSender sender =
  proc ("mavlink_local_position_ned_system_global_offset_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    localPositionNedSystemGlobalOffsetPack (senderMacro sender) msg

instance MavlinkSendable "local_position_ned_system_global_offset_msg" 28 where
  mkSender = mkLocalPositionNedSystemGlobalOffsetSender

localPositionNedSystemGlobalOffsetPack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 28
                  -> ConstRef s1 (Struct "local_position_ned_system_global_offset_msg")
                  -> Ivory eff ()
localPositionNedSystemGlobalOffsetPack sender msg = do
  arr <- local (iarray [] :: Init (Array 28 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_boot_ms)
  call_ pack buf 4 =<< deref (msg ~> x)
  call_ pack buf 8 =<< deref (msg ~> y)
  call_ pack buf 12 =<< deref (msg ~> z)
  call_ pack buf 16 =<< deref (msg ~> roll)
  call_ pack buf 20 =<< deref (msg ~> pitch)
  call_ pack buf 24 =<< deref (msg ~> yaw)
  sender localPositionNedSystemGlobalOffsetMsgId (constRef arr) localPositionNedSystemGlobalOffsetCrcExtra
  retVoid

instance MavlinkUnpackableMsg "local_position_ned_system_global_offset_msg" where
    unpackMsg = ( localPositionNedSystemGlobalOffsetUnpack , localPositionNedSystemGlobalOffsetMsgId )

localPositionNedSystemGlobalOffsetUnpack :: Def ('[ Ref s1 (Struct "local_position_ned_system_global_offset_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
localPositionNedSystemGlobalOffsetUnpack = proc "mavlink_local_position_ned_system_global_offset_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_boot_ms) =<< call unpack buf 0
  store (msg ~> x) =<< call unpack buf 4
  store (msg ~> y) =<< call unpack buf 8
  store (msg ~> z) =<< call unpack buf 12
  store (msg ~> roll) =<< call unpack buf 16
  store (msg ~> pitch) =<< call unpack buf 20
  store (msg ~> yaw) =<< call unpack buf 24

