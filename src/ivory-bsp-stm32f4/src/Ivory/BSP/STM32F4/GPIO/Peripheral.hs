{-# LANGUAGE FlexibleContexts #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE ConstraintKinds #-}
{-# LANGUAGE ExistentialQuantification #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE Rank2Types #-}
--
-- GPIO.hs --- GPIO Peripheral driver.
-- Defines peripheral types, instances, and public API.
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32F4.GPIO.Peripheral where

import Ivory.Language

import Ivory.HW

import Ivory.BSP.STM32F4.GPIO.RegTypes
import Ivory.BSP.STM32F4.GPIO.Regs
import Ivory.BSP.STM32F4.RCC
import Ivory.BSP.STM32F4.MemoryMap

-- | A GPIO port, defined as the set of registers that operate on all
-- the pins for that port.
data GPIOPort = GPIOPort
  { gpioPortMODER       :: BitDataReg GPIO_MODER
  , gpioPortOTYPER      :: BitDataReg GPIO_OTYPER
  , gpioPortOSPEEDR     :: BitDataReg GPIO_OSPEEDR
  , gpioPortPUPDR       :: BitDataReg GPIO_PUPDR
  , gpioPortIDR         :: BitDataReg GPIO_IDR
  , gpioPortBSRR        :: BitDataReg GPIO_BSRR
  , gpioPortAFRL        :: BitDataReg GPIO_AFRL
  , gpioPortAFRH        :: BitDataReg GPIO_AFRH
  , gpioPortRCCEnable   :: forall eff . Ivory eff ()
  , gpioPortRCCDisable  :: forall eff . Ivory eff ()
  , gpioPortName        :: String
  }

-- | Create a GPIO port given the base register address.
mkGPIOPort :: Integer -> BitDataField RCC_AHB1ENR Bit -> String -> GPIOPort
mkGPIOPort base rccfield n =
  GPIOPort
    { gpioPortMODER          = reg 0x00 "mode"
    , gpioPortOTYPER         = reg 0x04 "otype"
    , gpioPortOSPEEDR        = reg 0x08 "ospeed"
    , gpioPortPUPDR          = reg 0x0C "pupd"
    , gpioPortIDR            = reg 0x10 "idr"
    , gpioPortBSRR           = reg 0x18 "bsrr"
    , gpioPortAFRL           = reg 0x20 "afrl"
    , gpioPortAFRH           = reg 0x24 "afrh"
    , gpioPortRCCEnable      = rccEnable  rccreg rccfield
    , gpioPortRCCDisable     = rccDisable rccreg rccfield
    , gpioPortName           = n
    }
  where
  reg :: (IvoryIOReg (BitDataRep d)) => Integer -> String -> BitDataReg d
  reg offs name = mkBitDataRegNamed (base + offs) (n ++ "->" ++ name)

  rccreg = regRCC_AHB1ENR -- All GPIO are in AHB1.

gpioA :: GPIOPort
gpioA = mkGPIOPort gpioa_periph_base rcc_ahb1en_gpioa "gpioA"

gpioB :: GPIOPort
gpioB = mkGPIOPort gpiob_periph_base rcc_ahb1en_gpiob "gpioB"

gpioC :: GPIOPort
gpioC = mkGPIOPort gpioc_periph_base rcc_ahb1en_gpioc "gpioC"

gpioD :: GPIOPort
gpioD = mkGPIOPort gpiod_periph_base rcc_ahb1en_gpiod "gpioD"

gpioE :: GPIOPort
gpioE = mkGPIOPort gpioe_periph_base rcc_ahb1en_gpioe "gpioE"

gpioF :: GPIOPort
gpioF = mkGPIOPort gpiof_periph_base rcc_ahb1en_gpiof "gpioF"

gpioG :: GPIOPort
gpioG = mkGPIOPort gpiog_periph_base rcc_ahb1en_gpiog "gpioG"

gpioH :: GPIOPort
gpioH = mkGPIOPort gpioh_periph_base rcc_ahb1en_gpioh "gpioH"

gpioI :: GPIOPort
gpioI = mkGPIOPort gpioi_periph_base rcc_ahb1en_gpioi "gpioI"

instance RCCDevice GPIOPort where
  rccDeviceEnable  d = gpioPortRCCEnable  d
  rccDeviceDisable d = gpioPortRCCDisable d

-- | A GPIO alternate function register and bit field.
data GPIOPinAFR = AFRL (BitDataField GPIO_AFRL GPIO_AF)
                | AFRH (BitDataField GPIO_AFRH GPIO_AF)

-- | A GPIO pin, defined as the accessor functions to manipulate the
-- bits in the registers for the port the pin belongs to.
data GPIOPin = GPIOPin
  { gpioPinPort         :: GPIOPort
  , gpioPinNumber       :: Int
  , gpioPinMode_F       :: BitDataField GPIO_MODER GPIO_Mode
  , gpioPinOutputType_F :: BitDataField GPIO_OTYPER GPIO_OutputType
  , gpioPinSpeed_F      :: BitDataField GPIO_OSPEEDR GPIO_Speed
  , gpioPinPUPD_F       :: BitDataField GPIO_PUPDR GPIO_PUPD
  , gpioPinIDR_F        :: BitDataField GPIO_IDR Bit
  , gpioPinSetBSRR_F    :: BitDataField GPIO_BSRR Bit
  , gpioPinClearBSRR_F  :: BitDataField GPIO_BSRR Bit
  , gpioPinAFR_F        :: GPIOPinAFR
  }

-- | Enable the GPIO port for a pin in the RCC.
pinEnable :: GPIOPin -> Ivory eff ()
pinEnable = rccDeviceEnable . gpioPinPort

setRegF :: (BitData a, BitData b, IvoryIOReg (BitDataRep a),
            SafeCast (BitDataRep b) (BitDataRep a))
        => (GPIOPort -> BitDataReg a)
        -> (GPIOPin  -> BitDataField a b)
        -> GPIOPin
        -> b
        -> Ivory eff ()
setRegF reg field pin val =
  modifyReg (reg $ gpioPinPort pin) $
    setField (field pin) val

pinSetMode :: GPIOPin -> GPIO_Mode -> Ivory eff ()
pinSetMode = setRegF gpioPortMODER gpioPinMode_F

pinSetOutputType :: GPIOPin -> GPIO_OutputType -> Ivory eff ()
pinSetOutputType = setRegF gpioPortOTYPER gpioPinOutputType_F

pinSetSpeed :: GPIOPin -> GPIO_Speed -> Ivory eff ()
pinSetSpeed = setRegF gpioPortOSPEEDR gpioPinSpeed_F

pinSetPUPD :: GPIOPin -> GPIO_PUPD -> Ivory eff ()
pinSetPUPD = setRegF gpioPortPUPDR gpioPinPUPD_F

pinSetAF :: GPIOPin -> GPIO_AF -> Ivory eff ()
pinSetAF pin af =
  case gpioPinAFR_F pin of
    AFRL field -> setRegF gpioPortAFRL (const field) pin af
    AFRH field -> setRegF gpioPortAFRH (const field) pin af

pinSet :: GPIOPin -> Ivory eff ()
pinSet pin =
  modifyReg (gpioPortBSRR $ gpioPinPort pin) $
    setBit (gpioPinSetBSRR_F pin)

pinClear :: GPIOPin -> Ivory eff ()
pinClear pin =
  modifyReg (gpioPortBSRR $ gpioPinPort pin) $
    setBit (gpioPinClearBSRR_F pin)

pinRead :: GPIOPin -> Ivory eff IBool
pinRead pin = do
  r <- getReg (gpioPortIDR $ gpioPinPort pin)
  return (bitToBool (r #. gpioPinIDR_F pin))

