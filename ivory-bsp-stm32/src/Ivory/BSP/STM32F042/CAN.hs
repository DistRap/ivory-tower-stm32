module Ivory.BSP.STM32F042.CAN
  ( can1
  , canFilters
  ) where

import Ivory.Language
import Ivory.HW

import Ivory.BSP.STM32.Peripheral.CAN
import Ivory.BSP.STM32.Peripheral.SYSCFG
import Ivory.BSP.STM32F042.Interrupt
import Ivory.BSP.STM32F042.MemoryMap
import Ivory.BSP.STM32F042.RCC

canFilters :: CANPeriphFilters
canFilters = mkCANPeriphFilters can1_periph_base
          (rccEnable rcc_apb1en_can1)
          (rccDisable rcc_apb1en_can1)

can1 :: CANPeriph
can1 = mkCANPeriph can1_periph_base
          (rccEnable rcc_apb1en_can1)
          (rccDisable rcc_apb1en_can1)
          CEC_CAN CEC_CAN CEC_CAN CEC_CAN
          "can1"

rccEnable :: BitDataField RCC_APB1ENR Bit -> Ivory eff ()
rccEnable field = do
  modifyReg regRCC_APB2ENR $ setBit rcc_apb2en_syscfg
  modifyReg regRCC_AHB1ENR $ setBit rcc_ahb1en_gpioa
  modifyReg regRCC_AHB1ENR $ setBit rcc_ahb1en_gpiob
  modifyReg (syscfg_cfgr1 syscfg) $ setBit syscfg_cfgr1_pa11_pa12_rmp
  modifyReg regRCC_APB1ENR $ setBit field

rccDisable :: BitDataField RCC_APB1ENR Bit -> Ivory eff ()
rccDisable field = modifyReg regRCC_APB1ENR $ clearBit field
