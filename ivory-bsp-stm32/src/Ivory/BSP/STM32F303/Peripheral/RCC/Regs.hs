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

module Ivory.BSP.STM32F303.Peripheral.RCC.Regs where

import Ivory.Language

import Ivory.BSP.STM32F303.Peripheral.RCC.RegTypes

-- Control Register ------------------------------------------------------------

[ivory|
 bitdata RCC_CR :: Bits 32 = rcc_cr
  { _                 :: Bits 4
  , rcc_cr_plli2s_rdy :: Bit
  , rcc_cr_plli2s_on  :: Bit
  , rcc_cr_pll_rdy    :: Bit
  , rcc_cr_pll_on     :: Bit
  , _                 :: Bits 4
  , rcc_cr_css_on     :: Bit
  , rcc_cr_hse_byp    :: Bit
  , rcc_cr_hse_rdy    :: Bit
  , rcc_cr_hse_on     :: Bit
  , rcc_cr_hsical     :: Bits 8
  , rcc_cr_hsitrim    :: Bits 5
  , _                 :: Bit
  , rcc_cr_hsi_rdy    :: Bit
  , rcc_cr_hsi_on     :: Bit
  }
|]

[ivory|
 bitdata RCC_CR2 :: Bits 32 = rcc_cr2
  { _                 :: Bits 14
  , rcc_cr2_hsi48_rdy :: Bit
  , rcc_cr2_hsi48_on  :: Bit
  , _                 :: Bits 16
  }
|]

-- Clock Configuration Register ------------------------------------------------

[ivory|
 bitdata RCC_CFGR :: Bits 32 = rcc_cfgr
  { rcc_cfgr_pllnodiv     :: Bit
  , rcc_cfgr_mcopre       :: RCC_MCOPre --- XXX: bit 28 is shared with MCOF
  , _                     :: Bit
  , rcc_cfgr_mco          :: RCC_MCO
  , rcc_cfgr_i2ssrc       :: Bit
  , rcc_cfgr_usbpre       :: Bit
  , rcc_cfgr_pllmul       :: RCC_PLLMUL
  , rcc_cfgr_pllxtpre     :: Bit
  , rcc_cfgr_pllsrc       :: RCC_PLLSRC
  , _                     :: Bit
  , rcc_cfgr_ppre2        :: RCC_PPREx
  , rcc_cfgr_ppre1        :: RCC_PPREx
  , rcc_cfgr_hpre         :: RCC_HPRE
  , rcc_cfgr_sws          :: RCC_SYSCLK
  , rcc_cfgr_sw           :: RCC_SYSCLK
  }
|]

-- Clock Configuration Register ------------------------------------------------

[ivory|
 bitdata RCC_CIR :: Bits 32 = rcc_cir
  { _                    :: Bits 8
  , rcc_cir_cssc         :: Bit
  , _                    :: Bit
  , rcc_cir_plli2s_rdyc  :: Bit
  , rcc_cir_pll_rdyc     :: Bit
  , rcc_cir_hse_rdyc     :: Bit
  , rcc_cir_hsi_rdyc     :: Bit
  , rcc_cir_lse_rdyc     :: Bit
  , rcc_cir_lsi_rdyc     :: Bit
  , _                    :: Bits 2
  , rcc_cir_plli2s_rdyie :: Bit
  , rcc_cir_pll_rdyie    :: Bit
  , rcc_cir_hse_rdyie    :: Bit
  , rcc_cir_hsi_rdyie    :: Bit
  , rcc_cir_lse_rdyie    :: Bit
  , rcc_cir_lsi_rdyie    :: Bit
  , rcc_cir_cssf         :: Bit
  , _                    :: Bit
  , rcc_cir_plli2s_rdyf  :: Bit
  , rcc_cir_pll_rdyf     :: Bit
  , rcc_cir_hse_rdyf     :: Bit
  , rcc_cir_hsi_rdyf     :: Bit
  , rcc_cir_lse_rdyf     :: Bit
  , rcc_cir_lsi_rdyf     :: Bit
  }
|]

-- APB Peripheral Clock Enable Register: Limited to just essential PWR
-- peripheral
-- Be sure to create a full device specific register! and check that your device
-- actually does use the same bit for PWR as this states.

[ivory|
 bitdata RCC_APB1ENR :: Bits 32 = rcc_apb1enr
  { _                    :: Bits 3
  , rcc_apb1en_pwr       :: Bit
  , _                    :: Bits 28
  }
|]
