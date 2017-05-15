{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
--
-- EXTI.hs --- the portion of the EXTI (Extended interrupts and events controller) registers
--
-- Copyright (C) 2017, Richard Marko
-- All Rights Reserved.
--

module Ivory.BSP.STM32.Peripheral.EXTI
  ( EXTI(..)
  , mkEXTI
  , module Ivory.BSP.STM32.Peripheral.EXTI.Regs
  ) where

import Ivory.HW
import Ivory.BSP.STM32.Peripheral.EXTI.Regs

data EXTI =
  EXTI
    { extiRegIMR   :: BitDataReg EXTI_IMR
    , extiRegEMR   :: BitDataReg EXTI_EMR
    , extiRegRTSR  :: BitDataReg EXTI_RTSR
    , extiRegFTSR  :: BitDataReg EXTI_FTSR
    , extiRegSWIER :: BitDataReg EXTI_SWIER
    , extiRegPR    :: BitDataReg EXTI_PR
    }

mkEXTI :: Integer -> EXTI
mkEXTI periph_base = EXTI
  { extiRegIMR   = mkBitDataRegNamed (periph_base + 0x00) "exti_imr"
  , extiRegEMR   = mkBitDataRegNamed (periph_base + 0x04) "exti_emr"
  , extiRegRTSR  = mkBitDataRegNamed (periph_base + 0x08) "exti_rtsr"
  , extiRegFTSR  = mkBitDataRegNamed (periph_base + 0x0C) "exti_ftsr"
  , extiRegSWIER = mkBitDataRegNamed (periph_base + 0x10) "exti_swier"
  , extiRegPR    = mkBitDataRegNamed (periph_base + 0x14) "exti_pr"
  }
