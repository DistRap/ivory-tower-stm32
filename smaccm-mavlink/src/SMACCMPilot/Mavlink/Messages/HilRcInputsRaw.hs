{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.HilRcInputsRaw where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

hilRcInputsRawMsgId :: Uint8
hilRcInputsRawMsgId = 92

hilRcInputsRawCrcExtra :: Uint8
hilRcInputsRawCrcExtra = 54

hilRcInputsRawModule :: Module
hilRcInputsRawModule = package "mavlink_hil_rc_inputs_raw_msg" $ do
  depend packModule
  incl hilRcInputsRawUnpack
  defStruct (Proxy :: Proxy "hil_rc_inputs_raw_msg")

[ivory|
struct hil_rc_inputs_raw_msg
  { time_usec :: Stored Uint64
  ; chan1_raw :: Stored Uint16
  ; chan2_raw :: Stored Uint16
  ; chan3_raw :: Stored Uint16
  ; chan4_raw :: Stored Uint16
  ; chan5_raw :: Stored Uint16
  ; chan6_raw :: Stored Uint16
  ; chan7_raw :: Stored Uint16
  ; chan8_raw :: Stored Uint16
  ; chan9_raw :: Stored Uint16
  ; chan10_raw :: Stored Uint16
  ; chan11_raw :: Stored Uint16
  ; chan12_raw :: Stored Uint16
  ; rssi :: Stored Uint8
  }
|]

mkHilRcInputsRawSender :: SizedMavlinkSender 33
                       -> Def ('[ ConstRef s (Struct "hil_rc_inputs_raw_msg") ] :-> ())
mkHilRcInputsRawSender sender =
  proc ("mavlink_hil_rc_inputs_raw_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    hilRcInputsRawPack (senderMacro sender) msg

instance MavlinkSendable "hil_rc_inputs_raw_msg" 33 where
  mkSender = mkHilRcInputsRawSender

hilRcInputsRawPack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 33
                  -> ConstRef s1 (Struct "hil_rc_inputs_raw_msg")
                  -> Ivory eff ()
hilRcInputsRawPack sender msg = do
  arr <- local (iarray [] :: Init (Array 33 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_usec)
  call_ pack buf 8 =<< deref (msg ~> chan1_raw)
  call_ pack buf 10 =<< deref (msg ~> chan2_raw)
  call_ pack buf 12 =<< deref (msg ~> chan3_raw)
  call_ pack buf 14 =<< deref (msg ~> chan4_raw)
  call_ pack buf 16 =<< deref (msg ~> chan5_raw)
  call_ pack buf 18 =<< deref (msg ~> chan6_raw)
  call_ pack buf 20 =<< deref (msg ~> chan7_raw)
  call_ pack buf 22 =<< deref (msg ~> chan8_raw)
  call_ pack buf 24 =<< deref (msg ~> chan9_raw)
  call_ pack buf 26 =<< deref (msg ~> chan10_raw)
  call_ pack buf 28 =<< deref (msg ~> chan11_raw)
  call_ pack buf 30 =<< deref (msg ~> chan12_raw)
  call_ pack buf 32 =<< deref (msg ~> rssi)
  sender hilRcInputsRawMsgId (constRef arr) hilRcInputsRawCrcExtra
  retVoid

instance MavlinkUnpackableMsg "hil_rc_inputs_raw_msg" where
    unpackMsg = ( hilRcInputsRawUnpack , hilRcInputsRawMsgId )

hilRcInputsRawUnpack :: Def ('[ Ref s1 (Struct "hil_rc_inputs_raw_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
hilRcInputsRawUnpack = proc "mavlink_hil_rc_inputs_raw_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_usec) =<< call unpack buf 0
  store (msg ~> chan1_raw) =<< call unpack buf 8
  store (msg ~> chan2_raw) =<< call unpack buf 10
  store (msg ~> chan3_raw) =<< call unpack buf 12
  store (msg ~> chan4_raw) =<< call unpack buf 14
  store (msg ~> chan5_raw) =<< call unpack buf 16
  store (msg ~> chan6_raw) =<< call unpack buf 18
  store (msg ~> chan7_raw) =<< call unpack buf 20
  store (msg ~> chan8_raw) =<< call unpack buf 22
  store (msg ~> chan9_raw) =<< call unpack buf 24
  store (msg ~> chan10_raw) =<< call unpack buf 26
  store (msg ~> chan11_raw) =<< call unpack buf 28
  store (msg ~> chan12_raw) =<< call unpack buf 30
  store (msg ~> rssi) =<< call unpack buf 32

