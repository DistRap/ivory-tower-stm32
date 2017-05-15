
module Ivory.BSP.STM32F405.SYSCFG
  ( syscfg
  ) where


import Ivory.BSP.STM32.Peripheral.SYSCFG

import Ivory.Language
import Ivory.HW

import Ivory.BSP.STM32F405.RCC
import Ivory.BSP.STM32F405.MemoryMap

syscfg :: SYSCFG
syscfg = mkSysCfg syscfg_periph_base rccenable rccdisable
  where
  rccenable  = modifyReg regRCC_APB2ENR $ setBit rcc_apb2en_syscfg
  rccdisable = modifyReg regRCC_APB2ENR $ setBit rcc_apb2en_syscfg
