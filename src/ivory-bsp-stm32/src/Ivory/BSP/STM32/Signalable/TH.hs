{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE TemplateHaskell #-}

module Ivory.BSP.STM32.Signalable.TH
  ( stm32SignalableInstance
  ) where

import Ivory.Tower

import Ivory.BSP.STM32.Signalable.Class
import Ivory.BSP.STM32.Interrupt
import Language.Haskell.TH.Syntax

stm32SignalableInstance :: Name -> Name -> Q [Dec]
stm32SignalableInstance platformtype interrupttype = do
  n <- newName "n"
  return
    [ InstanceD []
        (AppT (ConT ''Signalable) (ConT platformtype))
        [ stinstance
        , signalnamedef n
        ]
    , InstanceD []
       (AppT (ConT ''STM32Signal) (ConT platformtype))
       [ TySynInstD ''InterruptType [ConT platformtype] (ConT interrupttype)
       , stm32signaldef n
       ]
    ]
  where
  stname = mkName ((nameBase platformtype) ++ "Signal")
  stinstance =
    DataInstD [] ''SignalType [ConT platformtype]
              [NormalC stname [(NotStrict, AppT (ConT ''IRQ) (ConT interrupttype))]]
              [''Eq, ''Show]
  signalnamedef n =
    FunD 'signalName
         [Clause [ConP stname [VarP n]]
                 (NormalB (AppE (VarE 'irqHandlerName) (VarE n)))
                 []]
  stm32signaldef n =
    FunD 'stm32Signal
         [Clause [VarP n]
                 (NormalB (AppE (ConE stname) (VarE n)))
                 []]

