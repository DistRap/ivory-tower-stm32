{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}

module Ivory.OS.FreeRTOS.BinarySemaphore where

import Prelude hiding (take)
import Ivory.Language

-- Dirty tricks:
-- an xSemaphoreHandle is actually a void*, but we don't have a void*
-- in Ivory. So, we keep around a uint8_t* to instansiate it as an area
-- and then, because we must pass areas by refs, end up passing uint8_t**
-- to every freertos wrapper function that needs the xSemaphoreHandle.
-- the wrapper functions will deref the argument onceand cast the remaining
-- uint8_t* to a xSemaphoreHandle to use it.

newtype BinarySemaphore =
  BinarySemaphore (Ptr Global (Stored Uint8))
  deriving (IvoryType, IvoryVar, IvoryStore, IvoryZeroVal)
type BinarySemaphoreHandle = Ref Global (Stored BinarySemaphore)

semaphoreWrapperHeader :: String
semaphoreWrapperHeader = "freertos_semaphore_wrapper.h"

moddef :: ModuleDef
moddef = do
  incl create
  incl take
  incl give
  incl giveFromISR

create :: Def ('[ BinarySemaphoreHandle ] :-> ())
create = importProc "ivory_freertos_semaphore_create_binary" semaphoreWrapperHeader

take :: Def ('[ BinarySemaphoreHandle ] :-> ())
take = importProc "ivory_freertos_semaphore_takeblocking" semaphoreWrapperHeader

give :: Def('[ BinarySemaphoreHandle ] :-> ())
give = importProc "ivory_freertos_semaphore_give" semaphoreWrapperHeader

giveFromISR :: Def('[ BinarySemaphoreHandle ] :-> ())
giveFromISR = importProc "ivory_freertos_semaphore_give_from_isr" semaphoreWrapperHeader

