{-# LANGUAGE RecordWildCards #-}

module Ivory.BSP.STM32.ClockConfig where

import Ivory.Tower.Config

data ClockSource = External Integer | Internal deriving (Eq, Show)

data PLLFactor = PLLFactor
  { pll_m :: Integer
  , pll_n :: Integer
  , pll_p :: Integer
  , pll_q :: Integer
  }
 |  PLLMFactor
  { pllm_m :: Integer -- HSE divider
  , pllm_n :: Integer -- PLLMUL
  } deriving (Eq, Show)

data ClockConfig =
  ClockConfig
    { clockconfig_source        :: ClockSource
    , clockconfig_pll           :: PLLFactor
    , clockconfig_hclk_divider  :: Integer    -- HPRE
    , clockconfig_pclk1_divider :: Integer    -- PPRE1
    , clockconfig_pclk2_divider :: Integer    -- PPRE2
    } deriving (Eq, Show)

clockSourceHz :: ClockSource -> Integer
clockSourceHz (External rate) = rate
clockSourceHz Internal        = 8 * 1000 * 1000

clockSysClkHz :: ClockConfig -> Integer
clockSysClkHz
  ClockConfig{clockconfig_source=csource, clockconfig_pll=PLLFactor{..}}
    = ((source `div` pll_m) * pll_n) `div` pll_p
  where
  source = clockSourceHz csource
clockSysClkHz
  ClockConfig{clockconfig_source=csource, clockconfig_pll=PLLMFactor{..}}
    = ((source `div` pllm_m) * pllm_n)
  where
  source = clockSourceHz csource

clockPLL48ClkHz :: ClockConfig -> Integer
clockPLL48ClkHz
  ClockConfig{clockconfig_source=csource, clockconfig_pll=PLLFactor{..}}
    = ((source `div` pll_m) * pll_n) `div` pll_q
  where
  source = clockSourceHz csource
clockPLL48ClkHz
  ClockConfig{clockconfig_source=csource, clockconfig_pll=PLLMFactor{..}}
    = 48 * 1000 * 1000  -- XXX: there's no PLL48CLK on F3, hack this for now
  where
  source = clockSourceHz csource

clockHClkHz :: ClockConfig -> Integer
clockHClkHz cc = clockSysClkHz cc `div` (clockconfig_hclk_divider cc)

clockPClk1Hz :: ClockConfig -> Integer
clockPClk1Hz cc = clockHClkHz cc `div` (clockconfig_pclk1_divider cc)

clockPClk2Hz :: ClockConfig -> Integer
clockPClk2Hz cc = clockHClkHz cc `div` (clockconfig_pclk2_divider cc)

data PClk = PClk1 | PClk2

clockPClkHz :: PClk -> ClockConfig -> Integer
clockPClkHz PClk1 = clockPClk1Hz
clockPClkHz PClk2 = clockPClk2Hz

-- XXX: maybe make this a more general version?
externalXtalPLL :: Integer -> Integer -> PLLFactor -> ClockConfig
externalXtalPLL xtal_mhz sysclk_mhz pllconf = ClockConfig
  { clockconfig_source = External (xtal_mhz * 1000 * 1000)
  , clockconfig_pll    = pllconf
  , clockconfig_hclk_divider = 1
  , clockconfig_pclk1_divider = 4 -- APB1 div 4
  , clockconfig_pclk2_divider = 2 -- APB2 div 2
  }

internalXtal :: Integer -> PLLFactor -> ClockConfig
internalXtal sysclk_mhz pllconf = ClockConfig
  { clockconfig_source = Internal
  , clockconfig_pll = pllconf
  , clockconfig_hclk_divider = 1
  , clockconfig_pclk1_divider = 1 -- APB1 div 1
  , clockconfig_pclk2_divider = 2 -- APB2 div 2
  }

externalXtal :: Integer -> Integer -> ClockConfig
externalXtal xtal_mhz sysclk_mhz = externalXtalPLL xtal_mhz sysclk_mhz
    PLLFactor
      { pll_m = xtal_mhz  -- 8
      , pll_n = sysclk_mhz * p
      , pll_p = p
      , pll_q = 7
      }
  where p = 2

internalXtalF0 sysclk_mhz = internalXtal sysclk_mhz
    PLLMFactor
      { pllm_m = 2 -- HSE div 1 or 2
      , pllm_n = 12 -- PLLMUL
      }

externalXtalF0 xtal_mhz sysclk_mhz = externalXtalPLL xtal_mhz sysclk_mhz
    PLLMFactor
      { pllm_m = 1 -- HSE div 1 or 2
      , pllm_n = 9 -- PLLMUL
      }

externalXtalF3 xtal_mhz sysclk_mhz = externalXtalPLL xtal_mhz sysclk_mhz
    PLLMFactor
      { pllm_m = 1 -- HSE div 1 or 2
      , pllm_n = 9 -- PLLMUL
      }

clockConfigParser :: ConfigParser ClockConfig
clockConfigParser = do
  xtal_mhz   <- subsection "xtalMHz" integer
  sysclk_mhz <- subsection "sysclkMHz" (integer `withDefault` 168)
  return (externalXtal xtal_mhz sysclk_mhz)
