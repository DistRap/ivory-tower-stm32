{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
--
-- Regs.hs --- EXTI (Extended interrupts and events controller) registers,
-- (this is based on STM32F042 so it might won't fit for entire family, needs work
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32.Peripheral.EXTI.Regs where

import Ivory.Language

-- Interrupt mask register --------------------------------------------------------

[ivory|
 bitdata EXTI_IMR :: Bits 32 = exti_imr
  { _                              :: Bits 10
  , exti_imr_data                  :: Bits 22
  }

-- Event mask register ------------------------------------------------------------

 bitdata EXTI_EMR :: Bits 32 = exti_emr
  { _                              :: Bits 10
  , exti_emr_data                  :: Bits 22
  }

-- Rising trigger selection register ----------------------------------------------
-- XXX: some of these are reserved but seems to depend on family

 bitdata EXTI_RTSR :: Bits 32 = exti_rtsr
  { _                              :: Bits 10
  , exti_rtsr_data                 :: Bits 22
  }

-- Falling trigger selection register ----------------------------------------------
-- XXX: some of these are reserved but seems to depend on family

 bitdata EXTI_FTSR :: Bits 32 = exti_ftsr
  { _                              :: Bits 10
  , exti_ftsr_data                 :: Bits 22
  }

-- Software intrrupt event register ----------------------------------------------
-- XXX: some of these are reserved but seems to depend on family

 bitdata EXTI_SWIER :: Bits 32 = exti_swier
  { _                              :: Bits 10
  , exti_swier_data                :: Bits 22
  }

-- Pending register ----------------------------------------------
-- XXX: some of these are reserved but seems to depend on family

 bitdata EXTI_PR :: Bits 32 = exti_pr
  { _                              :: Bits 10
  , exti_pr_data                   :: Bits 22
  }
|]
