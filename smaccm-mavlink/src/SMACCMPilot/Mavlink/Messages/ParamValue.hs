{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.ParamValue where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

paramValueMsgId :: Uint8
paramValueMsgId = 22

paramValueCrcExtra :: Uint8
paramValueCrcExtra = 220

paramValueModule :: Module
paramValueModule = package "mavlink_param_value_msg" $ do
  depend packModule
  incl paramValueUnpack
  defStruct (Proxy :: Proxy "param_value_msg")

[ivory|
struct param_value_msg
  { param_value :: Stored IFloat
  ; param_count :: Stored Uint16
  ; param_index :: Stored Uint16
  ; param_type :: Stored Uint8
  ; param_id :: Array 16 (Stored Uint8)
  }
|]

mkParamValueSender :: SizedMavlinkSender 25
                       -> Def ('[ ConstRef s (Struct "param_value_msg") ] :-> ())
mkParamValueSender sender =
  proc ("mavlink_param_value_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    paramValuePack (senderMacro sender) msg

instance MavlinkSendable "param_value_msg" 25 where
  mkSender = mkParamValueSender

paramValuePack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 25
                  -> ConstRef s1 (Struct "param_value_msg")
                  -> Ivory eff ()
paramValuePack sender msg = do
  arr <- local (iarray [] :: Init (Array 25 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> param_value)
  call_ pack buf 4 =<< deref (msg ~> param_count)
  call_ pack buf 6 =<< deref (msg ~> param_index)
  call_ pack buf 24 =<< deref (msg ~> param_type)
  arrayPack buf 8 (msg ~> param_id)
  sender paramValueMsgId (constRef arr) paramValueCrcExtra
  retVoid

instance MavlinkUnpackableMsg "param_value_msg" where
    unpackMsg = ( paramValueUnpack , paramValueMsgId )

paramValueUnpack :: Def ('[ Ref s1 (Struct "param_value_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
paramValueUnpack = proc "mavlink_param_value_unpack" $ \ msg buf -> body $ do
  store (msg ~> param_value) =<< call unpack buf 0
  store (msg ~> param_count) =<< call unpack buf 4
  store (msg ~> param_index) =<< call unpack buf 6
  store (msg ~> param_type) =<< call unpack buf 24
  arrayUnpack buf 8 (msg ~> param_id)

