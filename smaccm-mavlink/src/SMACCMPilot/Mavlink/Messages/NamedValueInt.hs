{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE MultiParamTypeClasses #-}

-- Autogenerated Mavlink v1.0 implementation: see smavlink_ivory.py

module SMACCMPilot.Mavlink.Messages.NamedValueInt where

import SMACCMPilot.Mavlink.Pack
import SMACCMPilot.Mavlink.Unpack
import SMACCMPilot.Mavlink.Send

import Ivory.Language

namedValueIntMsgId :: Uint8
namedValueIntMsgId = 252

namedValueIntCrcExtra :: Uint8
namedValueIntCrcExtra = 44

namedValueIntModule :: Module
namedValueIntModule = package "mavlink_named_value_int_msg" $ do
  depend packModule
  incl namedValueIntUnpack
  defStruct (Proxy :: Proxy "named_value_int_msg")

[ivory|
struct named_value_int_msg
  { time_boot_ms :: Stored Uint32
  ; value :: Stored Sint32
  ; name :: Array 10 (Stored Uint8)
  }
|]

mkNamedValueIntSender :: SizedMavlinkSender 18
                       -> Def ('[ ConstRef s (Struct "named_value_int_msg") ] :-> ())
mkNamedValueIntSender sender =
  proc ("mavlink_named_value_int_msg_send" ++ (senderName sender)) $ \msg -> body $ do
    namedValueIntPack (senderMacro sender) msg

instance MavlinkSendable "named_value_int_msg" 18 where
  mkSender = mkNamedValueIntSender

namedValueIntPack :: (eff `AllocsIn` s, eff `Returns` ())
                  => SenderMacro eff s 18
                  -> ConstRef s1 (Struct "named_value_int_msg")
                  -> Ivory eff ()
namedValueIntPack sender msg = do
  arr <- local (iarray [] :: Init (Array 18 (Stored Uint8)))
  let buf = toCArray arr
  call_ pack buf 0 =<< deref (msg ~> time_boot_ms)
  call_ pack buf 4 =<< deref (msg ~> value)
  arrayPack buf 8 (msg ~> name)
  sender namedValueIntMsgId (constRef arr) namedValueIntCrcExtra
  retVoid

instance MavlinkUnpackableMsg "named_value_int_msg" where
    unpackMsg = ( namedValueIntUnpack , namedValueIntMsgId )

namedValueIntUnpack :: Def ('[ Ref s1 (Struct "named_value_int_msg")
                             , ConstRef s2 (CArray (Stored Uint8))
                             ] :-> () )
namedValueIntUnpack = proc "mavlink_named_value_int_unpack" $ \ msg buf -> body $ do
  store (msg ~> time_boot_ms) =<< call unpack buf 0
  store (msg ~> value) =<< call unpack buf 4
  arrayUnpack buf 8 (msg ~> name)

