{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
--
-- Regs.hs --- RCC (Reset and Clock Control) registers, for entire STM32 series
-- (was prev based on F405, its possible some of these are wrong for other
-- chips! but i think i got it right.)
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32.Peripheral.SYSCFG.Regs where

import Ivory.Language

-- Control Register ------------------------------------------------------------

[ivory|
 bitdata SYSCFG_CFGR1 :: Bits 32 = syscfg_cfgr
  { _                              :: Bits 27
  , syscfg_cfgr1_pa11_pa12_rmp     :: Bit
  , _                              :: Bits 4
  }
|]
