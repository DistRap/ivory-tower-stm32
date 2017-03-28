{-# LANGUAGE DataKinds #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE TypeFamilies #-}
--
-- Regs.hs --- UART Register Description
--
-- Copyright (C) 2013, Galois, Inc.
-- All Rights Reserved.
--

module Ivory.BSP.STM32.Peripheral.UART.Regs where

import Ivory.Language
import Ivory.BSP.STM32.Peripheral.UART.Types

----------------------------------------------------------------------
-- UART Registers

[ivory|
 bitdata UART_CR1 :: Bits 32 = uart_cr1
   { _                 :: Bits 3
   , uart_cr1_m1       :: Bit -- Word length
   , uart_cr1_eobie    :: Bit -- End of Block interrupt enable
   , uart_cr1_rtoie    :: Bit -- Receiver timeout interrupt enable
   , uart_cr1_deat     :: Bits 5 -- Driver Enable assertion time
   , uart_cr1_dedt     :: Bits 5 -- Driver Enable de-assertion time
   , uart_cr1_over8    :: Bit    -- Oversampling mode
   , uart_cr1_cmie     :: Bit    -- Character match interrupt enable
   , uart_cr1_mme      :: Bit    -- Mute mode enable
   , uart_cr1_m0       :: Bit -- Word length
   , uart_cr1_wake     :: Bit -- Receiver wakeup method
   , uart_cr1_pce      :: Bit -- Parity control enable
   , uart_cr1_ps       :: Bit -- Parity selection
   , uart_cr1_peie     :: Bit -- PE interrupt enable
   , uart_cr1_txeie    :: Bit -- interrupt enable
   , uart_cr1_tcie     :: Bit -- Transmission complete interrupt enable
   , uart_cr1_rxneie   :: Bit -- RXNE interrupt enable
   , uart_cr1_idleie   :: Bit -- Idle interrupt
   , uart_cr1_te       :: Bit -- Transmitter enable
   , uart_cr1_re       :: Bit -- Receiver enable
   , uart_cr1_uesm     :: Bit -- USART enable in Stop mode
   , uart_cr1_ue       :: Bit -- USART enable
   }

 bitdata UART_CR2 :: Bits 32 = uart_cr2
   { uart_cr2_add1     :: Bits 4
   , uart_cr2_add2     :: Bits 4
   , uart_cr2_rtoen    :: Bit -- Receiver timeout enable
   , uart_cr2_abrmod   :: Bits 2 -- Auto baud rate mode
   , uart_cr2_abren    :: Bit -- Auto baud rate enable
   , uart_cr2_msbfst   :: Bit -- MSB first
   , uart_cr2_datainv  :: Bit -- Binary data inversion
   , uart_cr2_txinv    :: Bit -- TX pin active level inversion
   , uart_cr2_rxinv    :: Bit -- RX pin active level inversion
   , uart_cr2_swap     :: Bit -- Swap TX/RX pins
   , uart_cr2_lin      :: Bit -- LIN mode enable
   , uart_cr2_stop     :: Bits 2 -- LIN mode enable
   , uart_cr2_clken    :: Bit -- Clock enable (CK pin)
   , uart_cr2_cpol     :: Bit -- Clock polarity
   , uart_cr2_cpha     :: Bit -- Clock phase
   , uart_cr2_lbcl     :: Bit -- Last bit clock pulse
   , _                 :: Bit
   , uart_cr2_lbdie    :: Bit -- LIN break detection interrupt enable
   , uart_cr2_lbdl     :: Bit -- LIN break detection length
   , uart_cr2_addm7    :: Bit -- 7-bit Address Detection/4-bit Address Detection
   , _                 :: Bits 4
   }

 bitdata UART_CR3 :: Bits 32 = uart_cr3
   { _                 :: Bits 9
   , uart_cr3_wufie    :: Bit  -- Wakeup from Stop mode interrupt enable
   , uart_cr3_wus      :: Bits 2  -- Wakeup from Stop mode interrupt flag selection
   , uart_cr3_scarcnt  :: Bits 3  -- Smartcard auto-retry count
   , _                 :: Bit
   , uart_cr3_dep      :: Bit  -- Driver enable polarity selection
   , uart_cr3_dem      :: Bit  -- Driver enable mode
   , uart_cr3_ddre     :: Bit  -- DMA Disable on Reception Error
   , uart_cr3_ovrdis   :: Bit  -- Overrun Disable
   , uart_cr3_onebit   :: Bit  -- One sample bit method enable
   , uart_cr3_ctsie    :: Bit  -- CTS interrupt enable
   , uart_cr3_ctse     :: Bit  -- CTS enable
   , uart_cr3_rtse     :: Bit  -- RTS enable
   , uart_cr3_dmat     :: Bit  -- DMA enable transmitter
   , uart_cr3_dmar     :: Bit  -- DMA enable transmitter
   , uart_cr3_scen     :: Bit  -- Smartcard mode enable
   , uart_cr3_nack     :: Bit  -- Smartcard NACK enable
   , uart_cr3_hdsel    :: Bit  -- Half-duplex selection
   , uart_cr3_irlp     :: Bit  -- IrDA low-power
   , uart_cr3_iren     :: Bit  -- IrDA mode enable
   , uart_cr3_eie      :: Bit  -- Error interrupt enable
   }

 bitdata UART_BRR :: Bits 32 = uart_brr
   { _                 :: Bits 16
   , uart_brr_div      :: Bits 16
   }

 bitdata UART_GTPR :: Bits 32 = uart_gtpr
   { _                 :: Bits 16
   , uart_gtpr_gt      :: Bits 8
   , uart_gtpr_psc     :: Bits 8
   }

 bitdata UART_RTOR :: Bits 32 = uart_rtor
   { uart_rtor_blen    :: Bits 8
   , uart_rtor_rto     :: Bits 24
   }

 bitdata UART_RQR :: Bits 32 = uart_rqr
   { _                 :: Bits 27
   , uart_rqr_txfrq    :: Bit -- Transmit data flush request
   , uart_rqr_rxfrq    :: Bit -- Receive data flush request
   , uart_rqr_mmrq     :: Bit -- Mute mode request
   , uart_rqr_sbkrq    :: Bit -- Send break request
   , uart_rqr_abrrq    :: Bit -- Auto baud rate request
   }

 bitdata UART_ISR :: Bits 32 = uart_isr
   { _                 :: Bits 9
   , uart_isr_reack    :: Bit -- Receive enable acknowledge flag
   , uart_isr_teack    :: Bit -- Transmit enable acknowledge flag
   , uart_isr_wuf      :: Bit -- Wakeup from Stop mode flag
   , uart_isr_rwu      :: Bit -- Receiver wakeup from Mute mode
   , uart_isr_sbkf     :: Bit -- Send break flag
   , uart_isr_cmf      :: Bit -- Character match flag
   , uart_isr_busy     :: Bit -- Busy flag
   , uart_isr_abrf     :: Bit -- Auto baud rate flag
   , uart_isr_abre     :: Bit -- Auto baud rate error
   , _                 :: Bit
   , uart_isr_eobf     :: Bit -- End of block flag
   , uart_isr_rtof     :: Bit -- Receiver timeout
   , uart_isr_cfs      :: Bit -- CTS flag
   , uart_isr_cfsif    :: Bit -- CTS interrupt flag
   , uart_isr_lbdf     :: Bit -- LIN break detection flag
   , uart_isr_txe      :: Bit -- Transmit data register empty
   , uart_isr_tc       :: Bit -- Transmission complete
   , uart_isr_rxne     :: Bit -- Read data register not empty
   , uart_isr_idle     :: Bit -- Idle line detected
   , uart_isr_orne     :: Bit -- Overrun error
   , uart_isr_nf       :: Bit -- START bit Noise detection flag
   , uart_isr_fe       :: Bit -- Framing error
   , uart_isr_pe       :: Bit -- Parity error
   }

 bitdata UART_ICR :: Bits 32 = uart_icr
   { _                 :: Bits 11
   , uart_icr_wucf     :: Bit
   , _                 :: Bits 2
   , uart_icr_cmcf     :: Bit
   , _                 :: Bits 4
   , uart_icr_eobcf    :: Bit
   , uart_icr_rtocf    :: Bit
   , _                 :: Bit
   , uart_icr_ctscf    :: Bit
   , uart_icr_lbdcf    :: Bit
   , _                 :: Bit
   , uart_icr_tccf     :: Bit
   , _                 :: Bit
   , uart_icr_idlecf   :: Bit
   , uart_icr_orecf    :: Bit
   , uart_icr_ncf      :: Bit
   , uart_icr_fecf     :: Bit
   , uart_icr_pecf     :: Bit
   }

 bitdata UART_RDR :: Bits 32 = uart_rdr -- Receive data register
   { _                 :: Bits 24
   , uart_rdr_data     :: Bits 8
   }

 bitdata UART_TDR :: Bits 32 = uart_tdr -- Transmit data register
   { _                 :: Bits 24
   , uart_tdr_data     :: Bits 8
   }
|]

--[ivory|
-- bitdata UART_SR :: Bits 16 = uart_sr
--   { _                :: Bits 6
--   , uart_sr_cts      :: Bit
--   , uart_sr_lbd      :: Bit
--   , uart_sr_txe      :: Bit
--   , uart_sr_tc       :: Bit
--   , uart_sr_rxne     :: Bit
--   , uart_sr_idle     :: Bit
--   , uart_sr_orne     :: Bit
--   , uart_sr_nf       :: Bit
--   , uart_sr_fe       :: Bit
--   , uart_sr_pe       :: Bit
--   }
--
-- bitdata UART_DR :: Bits 16 = uart_dr
--   { _                  :: Bits 8
--   , uart_dr_data       :: Bits 8
--   }
--
-- bitdata UART_BRR :: Bits 16 = uart_brr
--   { uart_brr_div :: Bits 16
--   }
--
-- bitdata UART_CR1 :: Bits 16 = uart_cr1
--   { uart_cr1_over8    :: Bit
--   , _                 :: Bit
--   , uart_cr1_ue       :: Bit
--   , uart_cr1_m        :: UART_WordLen
--   , uart_cr1_wake     :: Bit
--   , uart_cr1_pce      :: Bit
--   , uart_cr1_ps       :: Bit
--   , uart_cr1_peie     :: Bit
--   , uart_cr1_txeie    :: Bit
--   , uart_cr1_tcie     :: Bit
--   , uart_cr1_rxneie   :: Bit
--   , uart_cr1_idleie   :: Bit
--   , uart_cr1_te       :: Bit
--   , uart_cr1_re       :: Bit
--   , uart_cr1_rwu      :: Bit
--   , uart_cr1_sbk      :: Bit
--   }
--
-- bitdata UART_CR2 :: Bits 16 = uart_cr2
--   { _                 :: Bit
--   , uart_cr2_linen    :: Bit
--   , uart_cr2_stop     :: UART_StopBits
--   , uart_cr2_clken    :: Bit
--   , uart_cr2_cpol     :: Bit
--   , uart_cr2_cpha     :: Bit
--   , uart_cr2_lbcl     :: Bit
--   , _                 :: Bit
--   , uart_cr2_lbdie    :: Bit
--   , uart_cr2_lbdl     :: Bit
--   , _                 :: Bit
--   , uart_cr2_add      :: Bits 4
--   }
--
-- bitdata UART_CR3 :: Bits 16 = uart_cr3
--   { _                 :: Bits 4
--   , uart_cr3_onebit   :: Bit
--   , uart_cr3_ctsie    :: Bit
--   , uart_cr3_ctse     :: Bit
--   , uart_cr3_rtse     :: Bit
--   , uart_cr3_dmat     :: Bit
--   , uart_cr3_dmar     :: Bit
--   , uart_cr3_scen     :: Bit
--   , uart_cr3_nack     :: Bit
--   , uart_cr3_hdsel    :: Bit
--   , uart_cr3_irlp     :: Bit
--   , uart_cr3_iren     :: Bit
--   , uart_cr3_eie      :: Bit
--   }
--
-- bitdata UART_GTPR :: Bits 16 = uart_gtpr
--   { uart_gtpr_gt      :: Bits 8
--   , uart_gtpr_psc     :: Bits 8
--   }
-- |]

