
module Ivory.BSP.STM32F405.EXTI
  ( exti
  ) where


import Ivory.BSP.STM32.Peripheral.EXTI
import Ivory.BSP.STM32F405.MemoryMap

exti :: EXTI
exti = mkEXTI exti_periph_base
