{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.ChangeOperatorControl where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

changeOperatorControlMsgId :: Uint8
changeOperatorControlMsgId = 5

changeOperatorControlCrcExtra :: Uint8
changeOperatorControlCrcExtra = 217

changeOperatorControlModule :: Module
changeOperatorControlModule = package "mavlink_change_operator_control_msg" $ do
  depend packModule
  incl changeOperatorControlUnpack
  defStruct (Proxy :: Proxy "change_operator_control_msg")

[ivory|
struct change_operator_control_msg
  { target_system :: Stored Uint8
  ; control_request :: Stored Uint8
  ; version :: Stored Uint8
  ; passkey :: Array 25 (Stored Uint8)
  }
|]

mkChangeOperatorControlSender :: SizedMavlinkSender 28
                       -> Def ('[ ConstRef s (Struct "change_operator_control_msg") ] :-> ())
mkChangeOperatorControlSender sender =
  proc ("mavlink_change_operator_control_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    changeOperatorControlPack (senderMacro sender) msg

instance MavlinkSendable "change_operator_control_msg" 28 where
  mkSender = mkChangeOperatorControlSender

changeOperatorControlPack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 28
                  -> ConstRef s1 (Struct "change_operator_control_msg")
                  -> Ivory eff ()
changeOperatorControlPack sender msg = do
  arr <- local (iarray [] :: Init (Array 28 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> target_system)
  call_ pack buf 1 =<< deref (msg ~> control_request)
  call_ pack buf 2 =<< deref (msg ~> version)
  arrayPack buf 3 (msg ~> passkey)
  sender changeOperatorControlMsgId (constRef arr) changeOperatorControlCrcExtra
  retVoid

instance MavlinkUnpackableMsg "change_operator_control_msg" where
    unpackMsg = ( changeOperatorControlUnpack , changeOperatorControlMsgId )

changeOperatorControlUnpack :: Def ('[ Ref s1 (Struct "change_operator_control_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
changeOperatorControlUnpack = proc "mavlink_change_operator_control_unpack" $ \ msg buf -> body $ do
  store (msg ~> target_system) =<< call unpack buf 0
  store (msg ~> control_request) =<< call unpack buf 1
  store (msg ~> version) =<< call unpack buf 2
  arrayUnpack buf 3 (msg ~> passkey)

