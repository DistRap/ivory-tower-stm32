
 {-# LANGUAGE TypeOperators #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE RecordWildCards #-}

module Ivory.BSP.STM32.ClockConfig.InitF3
  ( init_clocks
  ) where

import Ivory.Language
import Ivory.Stdlib
import Ivory.HW

import Ivory.BSP.STM32.ClockConfig
import Ivory.BSP.STM32F303.Peripheral.Flash
import Ivory.BSP.STM32.Peripheral.PWR
import Ivory.BSP.STM32F303.Peripheral.RCC

init_clocks :: ClockConfig -> Def('[]':->())
init_clocks clockconfig = proc "init_clocks" $ body $ do
  comment ("platformClockConfig: " ++ (show cc)      ++ "\n" ++
           "sysclk: "  ++ (show (clockSysClkHz cc))  ++ "\n" ++
           "hclk:   "  ++ (show (clockHClkHz cc))    ++ "\n" ++
           "pclk1:  "  ++ (show (clockPClk1Hz cc))   ++ "\n" ++
           "pclk2:  "  ++ (show (clockPClk2Hz cc)))

  -- RCC clock config to default reset state
  modifyReg (rcc_reg_cr rcc) $ setBit rcc_cr_hsi_on

  modifyReg (rcc_reg_cfgr rcc) $ do
--    setField rcc_cfgr_mco2     rcc_mcox_sysclk
--    setField rcc_cfgr_mco2_pre rcc_mcoxpre_none
--    setField rcc_cfgr_mco1_pre rcc_mcoxpre_none
--    clearBit rcc_cfgr_i2ssrc
--    setField rcc_cfgr_mco1     rcc_mcox_sysclk
--    setField rcc_cfgr_rtcpre   (fromRep 0)
    setField rcc_cfgr_ppre2    rcc_pprex_none
    setField rcc_cfgr_ppre1    rcc_pprex_none
    setField rcc_cfgr_hpre     rcc_hpre_none
    -- FIXME: maybe bug - sw instead of sws
    --setField rcc_cfgr_sws      rcc_sysclk_hsi
    setField rcc_cfgr_sw      rcc_sysclk_hsi

  -- Reset HSEOn, CSSOn, PLLOn bits
  modifyReg (rcc_reg_cr rcc) $ do
    clearBit rcc_cr_hse_on
    clearBit rcc_cr_css_on
    clearBit rcc_cr_pll_on

  -- Reset HSEBYP bit
  modifyReg (rcc_reg_cr rcc) $ clearBit rcc_cr_hse_byp

  -- Disable all interrupts
  modifyReg (rcc_reg_cir rcc) $ do
    clearBit rcc_cir_plli2s_rdyie
    clearBit rcc_cir_pll_rdyie
    clearBit rcc_cir_hse_rdyie
    clearBit rcc_cir_hsi_rdyie
    clearBit rcc_cir_lse_rdyie
    clearBit rcc_cir_lsi_rdyie
  case clockconfig_source cc of
    Internal -> return ()
    External _ -> do
      -- Enable HSE
      modifyReg (rcc_reg_cr rcc) $ setBit rcc_cr_hse_on

      -- Spin for a little bit waiting for RCC->CR HSERDY bit to be high
      hserdy <- local (ival false)
      arrayMap $ \(_ :: Ix 1024) -> do
        cr <- getReg (rcc_reg_cr rcc)
        when (bitToBool (cr #. rcc_cr_hse_rdy)) $ do
          store hserdy true
          breakOut

      success <- deref hserdy
      when success $ do
        -- Set PLL to use external clock:
        modifyReg (rcc_reg_cfgr rcc) $ do
          -- use HSE
          setField rcc_cfgr_pllsrc rcc_cfgr_pllsrc_hse_div1
      --  modifyReg (rcc_reg_pllcfgr rcc) $ do
      --    setBit rcc_pllcfgr_pllsrc -- use HSE

      -- Handle exception case when HSERDY fails.
      unless success $ do
        comment "waiting for HSERDY failed: check your hardware for a fault"
        comment "XXX handle this exception case with a breakpoint or reconfigure pll values for hsi"
        forever $ return ()

  -- Select regulator voltage output scale 1 mode
  modifyReg (rcc_reg_apb1enr rcc) $ setBit rcc_apb1en_pwr
  modifyReg (pwr_reg_cr pwr) $ setBit pwr_cr_vos

  -- Select bus clock dividers
  modifyReg (rcc_reg_cfgr rcc) $ do
    setBit   rcc_cfgr_pllnodiv

    setField rcc_cfgr_pllsrc rcc_cfgr_pllsrc_hse_div1
    setField rcc_cfgr_pllmul rcc_cfgr_pllmul_x9

    setField rcc_cfgr_hpre  hpre_divider
    setField rcc_cfgr_ppre1 ppre1_divider
    setField rcc_cfgr_ppre2 ppre2_divider

  -- Configure main PLL:
  case clockconfig_pll cc of
    PLLFactor{..} -> error "No PLL on F3, use PLLMFactor"
    PLLMFactor{..} ->
      modifyReg (rcc_reg_cfgr rcc) $ do
                    setBit   rcc_cfgr_pllnodiv
                    setField rcc_cfgr_pllsrc rcc_cfgr_pllsrc_hse_div1
                    setField rcc_cfgr_pllmul rcc_cfgr_pllmul_x9

  -- Enable main PLL:
  modifyReg (rcc_reg_cr rcc) $ do
    setBit rcc_cr_pll_on
  -- Spin until RCC->CR PLLRDY bit is high
  forever $ do
    cr <- getReg (rcc_reg_cr rcc)
    when (bitToBool (cr #. rcc_cr_pll_rdy)) $ breakOut

  -- Configure flash prefetch, instruction cache, data cache, wait state 5
  modifyReg (flash_reg_acr flash) $ do
    setBit flash_acr_ic_en
    setBit flash_acr_dc_en
    setField flash_acr_latency (fromRep 5)

  -- Select main PLL as system clock source
  modifyReg (rcc_reg_cfgr rcc) $ do
    setField rcc_cfgr_sw rcc_sysclk_pll

  -- Spin until main PLL is ready:
  forever $ do
    cfgr <- getReg (rcc_reg_cfgr rcc)
    when ((cfgr #. rcc_cfgr_sws) ==? rcc_sysclk_pll) $ breakOut

  where
  cc = clockconfig

  hpre_divider = case clockconfig_hclk_divider cc of
    1   -> rcc_hpre_none
    2   -> rcc_hpre_div2
    4   -> rcc_hpre_div4
    8   -> rcc_hpre_div8
    16  -> rcc_hpre_div16
    64  -> rcc_hpre_div64
    128 -> rcc_hpre_div128
    256 -> rcc_hpre_div256
    512 -> rcc_hpre_div512
    _   -> error "platfomClockConfig hclk divider not in valid range"

  ppre1_divider = case clockconfig_pclk1_divider cc of
    1  -> rcc_pprex_none
    2  -> rcc_pprex_div2
    4  -> rcc_pprex_div4
    8  -> rcc_pprex_div8
    16 -> rcc_pprex_div16
    _  -> error "platformClockConfig pclk1 divider not in valid range"

  ppre2_divider = case clockconfig_pclk2_divider cc of
    1  -> rcc_pprex_none
    2  -> rcc_pprex_div2
    4  -> rcc_pprex_div4
    8  -> rcc_pprex_div8
    16 -> rcc_pprex_div16
    _  -> error "platformClockConfig pclk2 divider not in valid range"
