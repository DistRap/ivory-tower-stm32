{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
--
-- RegTypes.hs --- SYSCFG register types
--
-- Copyright (C) 2015, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32.Peripheral.SYSCFG.RegTypes where

import Ivory.Language

[ivory|
  bitdata EXTIPort :: Bits 4
    = exti_portA as 0
    | exti_portB as 1
    | exti_portC as 2
    | exti_portD as 3
    | exti_portE as 4
    | exti_portF as 5
    | exti_portG as 6
    | exti_portH as 7
    | exti_portI as 8

  bitdata MEMMode :: Bits 2
    = memmode_main_flash    as 0
    | memmode_system_flash  as 1
    | memmode_embedded_sram as 2
|]
