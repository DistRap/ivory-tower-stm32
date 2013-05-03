{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.Setpoint6dof where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

setpoint6dofMsgId :: Uint8
setpoint6dofMsgId = 149

setpoint6dofCrcExtra :: Uint8
setpoint6dofCrcExtra = 15

setpoint6dofModule :: Module
setpoint6dofModule = package "mavlink_setpoint_6dof_msg" $ do
  depend packModule
  incl setpoint6dofUnpack
  defStruct (Proxy :: Proxy "setpoint_6dof_msg")

[ivory|
struct setpoint_6dof_msg
  { trans_x :: Stored IFloat
  ; trans_y :: Stored IFloat
  ; trans_z :: Stored IFloat
  ; rot_x :: Stored IFloat
  ; rot_y :: Stored IFloat
  ; rot_z :: Stored IFloat
  ; target_system :: Stored Uint8
  }
|]

mkSetpoint6dofSender :: SizedMavlinkSender 25
                       -> Def ('[ ConstRef s (Struct "setpoint_6dof_msg") ] :-> ())
mkSetpoint6dofSender sender =
  proc ("mavlink_setpoint_6dof_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    setpoint6dofPack (senderMacro sender) msg

instance MavlinkSendable "setpoint_6dof_msg" 25 where
  mkSender = mkSetpoint6dofSender

setpoint6dofPack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 25
                  -> ConstRef s1 (Struct "setpoint_6dof_msg")
                  -> Ivory eff ()
setpoint6dofPack sender msg = do
  arr <- local (iarray [] :: Init (Array 25 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> trans_x)
  call_ pack buf 4 =<< deref (msg ~> trans_y)
  call_ pack buf 8 =<< deref (msg ~> trans_z)
  call_ pack buf 12 =<< deref (msg ~> rot_x)
  call_ pack buf 16 =<< deref (msg ~> rot_y)
  call_ pack buf 20 =<< deref (msg ~> rot_z)
  call_ pack buf 24 =<< deref (msg ~> target_system)
  sender setpoint6dofMsgId (constRef arr) setpoint6dofCrcExtra
  retVoid

instance MavlinkUnpackableMsg "setpoint_6dof_msg" where
    unpackMsg = ( setpoint6dofUnpack , setpoint6dofMsgId )

setpoint6dofUnpack :: Def ('[ Ref s1 (Struct "setpoint_6dof_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
setpoint6dofUnpack = proc "mavlink_setpoint_6dof_unpack" $ \ msg buf -> body $ do
  store (msg ~> trans_x) =<< call unpack buf 0
  store (msg ~> trans_y) =<< call unpack buf 4
  store (msg ~> trans_z) =<< call unpack buf 8
  store (msg ~> rot_x) =<< call unpack buf 12
  store (msg ~> rot_y) =<< call unpack buf 16
  store (msg ~> rot_z) =<< call unpack buf 20
  store (msg ~> target_system) =<< call unpack buf 24

