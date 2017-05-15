{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
--
-- Regs.hs --- SYSCFG (System configuration controller) registers,
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32.Peripheral.SYSCFG.Regs where

import Ivory.Language
import Ivory.BSP.STM32.Peripheral.SYSCFG.RegTypes

[ivory|
 bitdata SYSCFG_MEMRMP :: Bits 32 = syscfg_memrmp
  { _                              :: Bits 30
  , syscfg_memrmp_mem_mode         :: MEMMode
  }

 bitdata SYSCFG_EXTICR1 :: Bits 32 = syscfg_exticr1x
  { _                              :: Bits 16
  , syscfg_exticr1_exti3           :: EXTIPort
  , syscfg_exticr1_exti2           :: EXTIPort
  , syscfg_exticr1_exti1           :: EXTIPort
  , syscfg_exticr1_exti0           :: EXTIPort
  }

  bitdata SYSCFG_EXTICR2 :: Bits 32 = syscfg_exticr2x
  { _                              :: Bits 16
  , syscfg_exticr2_exti7           :: EXTIPort
  , syscfg_exticr2_exti6           :: EXTIPort
  , syscfg_exticr2_exti5           :: EXTIPort
  , syscfg_exticr2_exti4           :: EXTIPort
  }

  bitdata SYSCFG_EXTICR3 :: Bits 32 = syscfg_exticr3x
  { _                              :: Bits 16
  , syscfg_exticr3_exti11          :: EXTIPort
  , syscfg_exticr3_exti10          :: EXTIPort
  , syscfg_exticr3_exti9           :: EXTIPort
  , syscfg_exticr3_exti8           :: EXTIPort
  }

  bitdata SYSCFG_EXTICR4 :: Bits 32 = syscfg_exticr4x
  { _                              :: Bits 16
  , syscfg_exticr4_exti15          :: EXTIPort
  , syscfg_exticr4_exti14          :: EXTIPort
  , syscfg_exticr4_exti13          :: EXTIPort
  , syscfg_exticr4_exti12          :: EXTIPort
  }
|]
