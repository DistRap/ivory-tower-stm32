{-# LANGUAGE GeneralizedNewtypeDeriving #-}
{-# LANGUAGE FlexibleInstances #-}
{-# LANGUAGE DataKinds #-}

module Ivory.HXStream.Types
  ( HXState
  , hxstate_tag
  , hxstate_progress
  , hxstate_esc
  ) where

import Ivory.Language

-- Idea: this pattern is useful, could we make an ivoryenum quasiquoter
-- for defining these automatically?

newtype HXState = HXState Uint8
  deriving (IvoryType, IvoryVar, IvoryExpr, IvoryEq, IvoryStore, IvoryInit)

instance IvorySizeOf (Stored HXState) where
  sizeOfBytes _ = sizeOfBytes (Proxy :: Proxy (Stored Uint8))

hxstate_tag, hxstate_progress, hxstate_esc  :: HXState
hxstate_tag        = HXState 1
hxstate_progress   = HXState 2
hxstate_esc        = HXState 3
