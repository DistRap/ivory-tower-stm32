{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE RecursiveDo #-}

module Ivory.Tower.StateMachine
  ( on
  , period
  , timeout
  , entry

  , Runnable
  , active
  , begin
  , stateMachine

  , MachineM
  , Stmt
  , StateLabel

  , state
  , stateNamed
  , branch
  , goto
  , haltWhen
  , halt
  , liftIvory
  , liftIvory_
  ) where

import Ivory.Language
import Ivory.Tower
import Ivory.Tower.StateMachine.Monad
import Ivory.Tower.StateMachine.Compile

on :: forall area
         . (IvoryArea area, IvoryZero area)
        => Event area
        -> (forall s s' . ConstRef s' area -> StmtM s ())
        -> StateM ()
on e stmtM = writeHandler $ EventHandler e (ScopedStatements stmts)
  where
  stmts :: ConstRef s' area -> [Stmt s]
  stmts ref = runStmtM (stmtM ref)

entry :: (forall s . StmtM s ()) -> StateM ()
entry stmtM = writeHandler $ EntryHandler (ScopedStatements (const (runStmtM stmtM)))

timeout :: Time a => a -> (forall s . StmtM s ()) -> StateM ()
timeout t stmtM = writeHandler $ TimeoutHandler (toMicroseconds t)
                                    (ScopedStatements (const (runStmtM stmtM)))

period :: Time a => a -> (forall s . StmtM s ()) -> StateM ()
period t stmtM = writeHandler $ PeriodHandler (toMicroseconds t)
                                    (ScopedStatements (const (runStmtM stmtM)))

state :: StateM () -> Machine
state sh = stateAux sh Nothing

stateNamed :: String -> StateM () -> Machine
stateNamed n sh = stateAux sh (Just n)

stateAux :: StateM () -> Maybe String-> Machine
stateAux sh name = do
  l <- label
  writeState $ runStateM sh l name
  return l

branch :: (CFlowable m) => IBool -> StateLabel -> m ()
branch b lbl = cflow $ CFlowBranch b lbl

goto :: (CFlowable m) => StateLabel -> m ()
goto lbl = branch true lbl

haltWhen :: (CFlowable m) => IBool -> m ()
haltWhen p = cflow $ CFlowHalt p

halt :: (CFlowable m) => m ()
halt = haltWhen true

liftIvory_ :: Ivory (AllocEffects s) () -> StmtM s ()
liftIvory_ i = writeStmt $ Stmt (i >> return (return ()))

liftIvory :: Ivory (AllocEffects s) CFlow-> StmtM s ()
liftIvory i = writeStmt $ Stmt i
