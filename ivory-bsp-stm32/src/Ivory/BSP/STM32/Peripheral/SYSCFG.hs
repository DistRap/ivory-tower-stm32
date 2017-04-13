{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
--
-- RCC.hs --- the portion of the RCC (Reset and Clock Control) peripehral common
-- to the entire STM32 series (was prev based on F405, its possible some of
-- these are wrong for other chips! but i think i got it right.)
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32.Peripheral.SYSCFG
  ( SYSCFG(..)
  , syscfg
  , module Ivory.BSP.STM32.Peripheral.SYSCFG.Regs
  ) where

import Ivory.HW
import Ivory.BSP.STM32F042.MemoryMap (syscfg_periph_base)
import Ivory.BSP.STM32.Peripheral.SYSCFG.Regs

data SYSCFG =
  SYSCFG
    { syscfg_cfgr1        :: BitDataReg SYSCFG_CFGR1
    }

syscfg :: SYSCFG
syscfg = SYSCFG
  { syscfg_cfgr1      = mkBitDataRegNamed (syscfg_periph_base + 0x00) "syscfg_cfgr1"
  }
