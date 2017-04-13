--
-- Types.hs -- Interrupt types for STM32F042
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32F042.Interrupt where

import Ivory.BSP.ARMv7M.Exception
import Ivory.BSP.STM32.Interrupt

-- https://github.com/szczys/stm32f0-discovery-basic-template/blob/master/Device/startup_stm32f0xx.s

data Interrupt
  = WWDG                -- Window WatchDog Interrupt
  | PVD_VDDIO2                 -- PVD through EXTI Line detection Interrupt
  | RTC            -- RTC Wakeup interrupt through the EXTI line
  | FLASH               -- FLASH global Interrupt
  | RCC_CRS                 -- RCC global Interrupt
  | EXTI0_1             -- EXTI Line[0:1] Interrupt
  | EXTI2_3             -- EXTI Line[2:3] Interrupt
  | EXTI4_15            -- EXTI Line[4:15] Interrupt
  | TSC               -- EXTI Line3 Interrupt
  | DMA1_Channel1               -- EXTI Line4 Interrupt
  | DMA1_Channel2_3        -- DMA1 Stream 0 global Interrupt
  | DMA1_Channel4_5        -- DMA1 Stream 1 global Interrupt
  | ADC1        -- DMA1 Stream 2 global Interrupt
  | TIM1_BRK_UP_TRG_COM        -- DMA1 Stream 3 global Interrupt
  | TIM1_CC        -- DMA1 Stream 4 global Interrupt
  | TIM2        -- DMA1 Stream 5 global Interrupt
  | TIM3        -- DMA1 Stream 6 global Interrupt
  | NULL1                -- ADC1, ADC2 and ADC3 global Interrupts
  | NULL2                -- ADC1, ADC2 and ADC3 global Interrupts
  | TIM14
  | NULL3
  | TIM16
  | TIM17
  | I2C1
  | NULL4
  | SPI1
  | SPI2
  | USART1
  | USART2
  | NULL5
  | CEC_CAN
  | USB
  deriving (Eq, Show, Enum)


instance STM32Interrupt Interrupt where
  interruptIRQn = IRQn . fromIntegral . fromEnum
  interruptTable _ = map Just (enumFrom WWDG)
  interruptHandlerName i = (show i) ++ "_IRQHandler"
