
--
-- MemoryMap.hs -- Memory map (addresses) for STM32F042
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32F042.MemoryMap where

import Ivory.BSP.STM32.MemoryMap hiding (rcc_periphs_base, flash_r_periphs_base)

flash_base, ccmdataram_base, sram1_base :: Integer
flash_base      = 0x08000000
ccmdataram_base = 0x10000000
sram1_base      = 0x20000000
--sram2_base      = 0x2001C000 -- not on F0, FIXME

--bkpsram_base :: Integer
--bkpsram_base = 0x40024000

--ahb2_periph_base = periph_base + 0x08000000
--ahb3_periph_base = periph_base + 0x10000000

--- APB1 Peripherals
tim2_periph_base :: Integer
tim2_periph_base = apb1_periph_base + 0x0000
tim3_periph_base :: Integer
tim3_periph_base = apb1_periph_base + 0x0400
tim6_periph_base :: Integer
tim6_periph_base = apb1_periph_base + 0x1000
tim14_periph_base :: Integer
tim14_periph_base = apb1_periph_base + 0x2000
rtc_periph_base :: Integer
rtc_periph_base = apb1_periph_base + 0x2800
wwdg_periph_base :: Integer
wwdg_periph_base = apb1_periph_base + 0x2C00
iwdg_periph_base :: Integer
iwdg_periph_base = apb1_periph_base + 0x3000
--i2s2ext_periph_base :: Integer
--i2s2ext_periph_base = apb1_periph_base + 0x3400
spi2_periph_base :: Integer
spi2_periph_base = apb1_periph_base + 0x3800
--spi3_periph_base :: Integer
--spi3_periph_base = apb1_periph_base + 0x3C00
--i2s3ext_periph_base :: Integer
--i2s3ext_periph_base = apb1_periph_base + 0x4000
uart2_periph_base :: Integer
uart2_periph_base = apb1_periph_base + 0x4400
--uart3_periph_base :: Integer
--uart3_periph_base = apb1_periph_base + 0x4800
--uart4_periph_base :: Integer
--uart4_periph_base = apb1_periph_base + 0x4C00
--uart5_periph_base :: Integer
--uart5_periph_base = apb1_periph_base + 0x5000
i2c1_periph_base :: Integer
i2c1_periph_base = apb1_periph_base + 0x5400
i2c2_periph_base :: Integer
i2c2_periph_base = apb1_periph_base + 0x5800
--i2c3_periph_base :: Integer
--i2c3_periph_base = apb1_periph_base + 0x5C00
can1_periph_base :: Integer
can1_periph_base = apb1_periph_base + 0x6400
--can2_periph_base :: Integer
--can2_periph_base = apb1_periph_base + 0x6800
--pwr_periph_base :: Integer
--pwr_periph_base = apb1_periph_base + 0x7000
--dac_periph_base :: Integer
--dac_periph_base = apb1_periph_base + 0x7400

-- APB2 Peripherals
syscfg_periph_base :: Integer
syscfg_periph_base = apb2_periph_base + 0x0000
exti_periph_base :: Integer
exti_periph_base = apb2_periph_base + 0x0400
adc1_periph_base :: Integer
adc1_periph_base = apb2_periph_base + 0x2400
tim1_periph_base :: Integer
tim1_periph_base = apb2_periph_base + 0x2C00
spi1_periph_base :: Integer
spi1_periph_base = apb2_periph_base + 0x3000
uart1_periph_base :: Integer
uart1_periph_base = apb2_periph_base + 0x3800
tim16_periph_base :: Integer
tim16_periph_base = apb2_periph_base + 0x4400
tim17_periph_base :: Integer
tim17_periph_base = apb2_periph_base + 0x4800

-- AHB2 Peripherals
gpioa_periph_base :: Integer
gpioa_periph_base = ahb2_periph_base + 0x0000
gpiob_periph_base :: Integer
gpiob_periph_base = ahb2_periph_base + 0x0400
gpioc_periph_base :: Integer
gpioc_periph_base = ahb2_periph_base + 0x0800
gpiof_periph_base :: Integer
gpiof_periph_base = ahb2_periph_base + 0x1400

crc_periph_base :: Integer
crc_periph_base = ahb1_periph_base + 0x3000
-- skipping rcc_periph_base and flash_r_periph_base:
-- These are the same across the whole STM32 line, so we
-- declare them in Ivory.BSP.STM32.MemoryMap
rcc_periph_base = ahb1_periph_base + 0x1000
flash_r_periph_base = ahb1_periph_base + 0x2000

-- dma1_periph_base :: Integer
-- dma1_periph_base = ahb1_periph_base + 0x6000
-- dma2_periph_base :: Integer
-- dma2_periph_base = ahb1_periph_base + 0x6400
-- eth_periph_base :: Integer
-- eth_periph_base = ahb1_periph_base + 0x8000

-- AHB2 peripherals
-- dcmi_periph_base :: Integer
-- dcmi_periph_base = ahb2_periph_base + 0x50000
-- cryp_periph_base :: Integer
-- cryp_periph_base = ahb2_periph_base + 0x60000
-- hash_periph_base :: Integer
-- hash_periph_base = ahb2_periph_base + 0x60400
-- rng_periph_base :: Integer
-- rng_periph_base = ahb2_periph_base + 0x60800
