{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE Rank2Types #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE RecordWildCards #-}
--
-- SYSCFG.hs --- the portion of the SYSCFG (System Config) peripehral common
-- to the entire STM32 series (was prev based on F405, its possible some of
-- these are wrong for other chips! but i think i got it right.)
--
-- Copyright (C) 2017, Richard Marko
-- All Rights Reserved.
--
--
-- XXX: doesn't seem to work properly, probably masking is wrong

module Ivory.BSP.STM32.Peripheral.SYSCFG
  ( SYSCFG(..)
  , mkSysCfg
  , toEXTIPort
  , setEXTICR
  , module Ivory.BSP.STM32.Peripheral.SYSCFG.Regs
  , module Ivory.BSP.STM32.Peripheral.SYSCFG.RegTypes
  ) where

import Ivory.Language

import Ivory.HW
import Ivory.BSP.STM32.Peripheral.GPIOF4
import Ivory.BSP.STM32.Peripheral.SYSCFG.Regs
import Ivory.BSP.STM32.Peripheral.SYSCFG.RegTypes


data SYSCFG =
  SYSCFG
    { syscfgRegMEMRMP       :: BitDataReg SYSCFG_MEMRMP
    , syscfgRegEXTICR1      :: BitDataReg SYSCFG_EXTICR1
    , syscfgRegEXTICR2      :: BitDataReg SYSCFG_EXTICR2
    , syscfgRegEXTICR3      :: BitDataReg SYSCFG_EXTICR3
    , syscfgRegEXTICR4      :: BitDataReg SYSCFG_EXTICR4
    , syscfgRCCEnable       :: forall eff . Ivory eff ()
    , syscfgRCCDisable      :: forall eff . Ivory eff ()
    }

mkSysCfg :: Integer
         -> (forall eff . Ivory eff ())
         -> (forall eff . Ivory eff ())
         -> SYSCFG
mkSysCfg base rccen rccdis = SYSCFG
  { syscfgRegMEMRMP     = mkBitDataRegNamed (base + 0x00) "syscfg_memrmp"
  -- FIXME: add pmc
  , syscfgRegEXTICR1    = mkBitDataRegNamed (base + 0x08) "syscfg_exticr1"
  , syscfgRegEXTICR2    = mkBitDataRegNamed (base + 0x0C) "syscfg_exticr2"
  , syscfgRegEXTICR3    = mkBitDataRegNamed (base + 0x10) "syscfg_exticr3"
  , syscfgRegEXTICR4    = mkBitDataRegNamed (base + 0x14) "syscfg_exticr4"
  , syscfgRCCEnable     = rccen
  , syscfgRCCDisable    = rccdis
  }

toEXTIPort :: GPIOPin -> EXTIPort
toEXTIPort pin = cvt (gpioPortNumber $ gpioPinPort pin)
  where
  cvt 0 = exti_portA
  cvt 1 = exti_portB
  cvt 2 = exti_portC
  cvt 3 = exti_portD
  cvt 4 = exti_portE
  cvt 5 = exti_portF
  cvt 6 = exti_portG
  cvt 7 = exti_portH
  cvt 8 = exti_portI
  cvt p = error $ "No EXTI mapping for pin " ++ (show p)

setEXTICR :: GPIOPin -> SYSCFG -> Ivory eff ()
setEXTICR pin SYSCFG{..} = do
  modifyReg reg $ setField regfield val
  where
  reg = syscfgRegEXTICR1
  regfield = syscfg_exticr1_exti1 -- according to pin num
  --num = gpioPinNumber pin
  val = toEXTIPort pin
