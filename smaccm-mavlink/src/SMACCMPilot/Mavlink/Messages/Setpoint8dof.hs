{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.Setpoint8dof where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

setpoint8dofMsgId :: Uint8
setpoint8dofMsgId = 148

setpoint8dofCrcExtra :: Uint8
setpoint8dofCrcExtra = 241

setpoint8dofModule :: Module
setpoint8dofModule = package "mavlink_setpoint_8dof_msg" $ do
  depend packModule
  incl setpoint8dofUnpack
  defStruct (Proxy :: Proxy "setpoint_8dof_msg")

[ivory|
struct setpoint_8dof_msg
  { val1 :: Stored IFloat
  ; val2 :: Stored IFloat
  ; val3 :: Stored IFloat
  ; val4 :: Stored IFloat
  ; val5 :: Stored IFloat
  ; val6 :: Stored IFloat
  ; val7 :: Stored IFloat
  ; val8 :: Stored IFloat
  ; target_system :: Stored Uint8
  }
|]

mkSetpoint8dofSender :: SizedMavlinkSender 33
                       -> Def ('[ ConstRef s (Struct "setpoint_8dof_msg") ] :-> ())
mkSetpoint8dofSender sender =
  proc ("mavlink_setpoint_8dof_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    setpoint8dofPack (senderMacro sender) msg

instance MavlinkSendable "setpoint_8dof_msg" 33 where
  mkSender = mkSetpoint8dofSender

setpoint8dofPack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 33
                  -> ConstRef s1 (Struct "setpoint_8dof_msg")
                  -> Ivory eff ()
setpoint8dofPack sender msg = do
  arr <- local (iarray [] :: Init (Array 33 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> val1)
  call_ pack buf 4 =<< deref (msg ~> val2)
  call_ pack buf 8 =<< deref (msg ~> val3)
  call_ pack buf 12 =<< deref (msg ~> val4)
  call_ pack buf 16 =<< deref (msg ~> val5)
  call_ pack buf 20 =<< deref (msg ~> val6)
  call_ pack buf 24 =<< deref (msg ~> val7)
  call_ pack buf 28 =<< deref (msg ~> val8)
  call_ pack buf 32 =<< deref (msg ~> target_system)
  sender setpoint8dofMsgId (constRef arr) setpoint8dofCrcExtra
  retVoid

instance MavlinkUnpackableMsg "setpoint_8dof_msg" where
    unpackMsg = ( setpoint8dofUnpack , setpoint8dofMsgId )

setpoint8dofUnpack :: Def ('[ Ref s1 (Struct "setpoint_8dof_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
setpoint8dofUnpack = proc "mavlink_setpoint_8dof_unpack" $ \ msg buf -> body $ do
  store (msg ~> val1) =<< call unpack buf 0
  store (msg ~> val2) =<< call unpack buf 4
  store (msg ~> val3) =<< call unpack buf 8
  store (msg ~> val4) =<< call unpack buf 12
  store (msg ~> val5) =<< call unpack buf 16
  store (msg ~> val6) =<< call unpack buf 20
  store (msg ~> val7) =<< call unpack buf 24
  store (msg ~> val8) =<< call unpack buf 28
  store (msg ~> target_system) =<< call unpack buf 32

