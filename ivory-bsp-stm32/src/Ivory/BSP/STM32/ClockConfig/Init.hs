{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
-- {-# LANGUAGE RecordWildCards #-}

module Ivory.BSP.STM32.ClockConfig.Init
  ( init_clocks
  ) where

import Ivory.Language
import Ivory.Stdlib
import Ivory.HW

import Ivory.BSP.STM32.ClockConfig
import qualified Ivory.BSP.STM32.ClockConfig.InitF3 as F3
import qualified Ivory.BSP.STM32.ClockConfig.InitF4 as F4

init_clocks :: ClockConfig -> Def('[]':->())
init_clocks cc@ClockConfig{clockconfig_pll=PLLMFactor{}} = F3.init_clocks cc
init_clocks cc@ClockConfig{clockconfig_pll=PLLFactor{}} = F4.init_clocks cc
