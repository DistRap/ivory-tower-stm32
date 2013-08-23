{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE ScopedTypeVariables #-}
{-# LANGUAGE TypeOperators #-}
{-# LANGUAGE TypeFamilies #-}
{-# LANGUAGE DataKinds #-}
{-# LANGUAGE FlexibleContexts #-}

module Ivory.Tower.Task where

import Text.Printf

import Ivory.Language
import Ivory.Stdlib (when)

import Ivory.Tower.Types
import Ivory.Tower.Monad
import Ivory.Tower.Node

-- Public Task Definitions -----------------------------------------------------
instance Channelable TaskSt where
  nodeChannelEmitter  = taskChannelEmitter
  nodeChannelReceiver = taskChannelReceiver

taskChannelEmitter :: forall n area p . (SingI n, IvoryArea area)
        => ChannelSource n area -> Node TaskSt p (ChannelEmitter n area, String)
taskChannelEmitter chsrc = do
  nodename <- getNodeName
  unique   <- freshname -- May not be needed.
  let chid    = unChannelSource chsrc
      emitName = printf "emitFromTask_%s_chan%d%s" nodename (chan_id chid) unique
      externEmit :: Def ('[ConstRef s area] :-> IBool)
      externEmit = externProc emitName
      procEmit :: TaskSchedule -> Def ('[ConstRef s area] :-> IBool)
      procEmit schedule = proc emitName $ \ref -> body $ do
        r <- tsch_mkEmitter schedule emitter ref
        ret r
      (_, cb_mdef) = getChannelSourceCallback chsrc
      emitter  = ChannelEmitter
        { ce_chid         = chid
        , ce_chsrc        = chsrc
        , ce_extern_emit  = call externEmit
        , ce_extern_emit_ = call_ externEmit
        }
  taskStAddModuleDef $ \sch -> do
    incl (procEmit sch)
  taskStAddModuleDefUser cb_mdef
  return (emitter, emitName)

taskChannelReceiver :: forall n area p
                     . (SingI n, IvoryArea area, IvoryZero area)
                    => ChannelSink n area
                    -> Node TaskSt p (ChannelReceiver n area, String)
taskChannelReceiver chsnk = do
  nodename <- getNodeName
  unique   <- freshname -- May not be needed.
  let chid = unChannelSink chsnk
      rxName = printf "receiveFromTask_%s_chan%d%s" nodename (chan_id chid) unique
      externRx :: Def ('[Ref s area] :-> IBool)
      externRx = externProc rxName
      procRx :: TaskSchedule -> Def ('[Ref s area] :-> IBool)
      procRx schedule = proc rxName $ \ref -> body $ do
        r <- tsch_mkReceiver schedule rxer ref
        ret r
      rxer = ChannelReceiver
        { cr_chid      = chid
        , cr_extern_rx = call externRx
        }
  taskStAddModuleDef $ \sch -> do
    incl (procRx sch)
  return (rxer, rxName)

------

instance DataPortable TaskSt where
  nodeDataReader = taskDataReader
  nodeDataWriter = taskDataWriter

taskDataReader :: forall area p . (IvoryArea area)
               => DataSink area -> Node TaskSt p (DataReader area, String)
taskDataReader dsnk = do
  nodename <- getNodeName
  unique   <- freshname -- May not be needed.
  let dpid = unDataSink dsnk
      readerName = printf "read_%s_dataport%d%s" nodename (dp_id dpid) unique
      externReader :: Def ('[Ref s area] :-> ())
      externReader = externProc readerName
      procReader :: TaskSchedule -> Def ('[Ref s area] :-> ())
      procReader schedule = proc readerName $ \ref -> body $
        tsch_mkDataReader schedule dsnk ref
      reader = DataReader
        { dr_dpid   = dpid
        , dr_extern = call_ externReader
        }
  taskStAddModuleDef $ \sch -> do
    incl (procReader sch)
  return (reader, readerName)

taskDataWriter :: forall area p . (IvoryArea area)
               => DataSource area -> Node TaskSt p (DataWriter area, String)
taskDataWriter dsrc = do
  nodename <- getNodeName
  unique   <- freshname -- May not be needed.
  let dpid = unDataSource dsrc
      writerName = printf "write_%s_dataport%d%s" nodename (dp_id dpid) unique
      externWriter :: Def ('[ConstRef s area] :-> ())
      externWriter = externProc writerName
      procWriter :: TaskSchedule -> Def ('[ConstRef s area] :-> ())
      procWriter schedule = proc writerName $ \ref -> body $
        tsch_mkDataWriter schedule dsrc ref
      writer = DataWriter
        { dw_dpid   = dpid
        , dw_extern = call_ externWriter
        }
  taskStAddModuleDef $ \sch -> do
    incl (procWriter sch)
  return (writer, writerName)

--------------------------------------------------------------------------------

-- | Track Ivory dependencies used by the 'Ivory.Tower.Tower.taskBody' created
--   in the 'Ivory.Tower.Types.Task' context.
taskModuleDef :: ModuleDef -> Task p ()
taskModuleDef = taskStAddModuleDefUser

-- | Export a dependency on the packages generated by the Task context.
--   This permits the use of communication primitives, taskLocal, etc. from
--   external modules.
taskDependency :: Task p ModuleDef
taskDependency = do
  n <- getNode
  let fakeUserPkg = package (taskst_pkgname_user n) (return ())
      fakeLoopPkg = package (taskst_pkgname_loop n) (return ())
  return $ do
    depend fakeUserPkg
    depend fakeLoopPkg

-- | Specify the stack size, in bytes, of the 'Ivory.Tower.Tower.taskBody'
--   created in the 'Ivory.Tower.Types.Task' context.
withStackSize :: Integer -> Task p ()
withStackSize stacksize = do
  s <- getTaskSt
  case taskst_stacksize s of
    Nothing -> setTaskSt $ s { taskst_stacksize = Just stacksize }
    Just _  -> getNodeName >>= \name ->
               fail ("Cannot use withStackSize more than once in task named "
                  ++  name)

-- | Specify an OS priority level of the 'Ivory.Tower.Tower.taskBody' created in
--   the 'Ivory.Tower.Types.Task' context. Implementation at the backend
--   defined by the 'Ivory.Tower.Types.OS' implementation.
withPriority :: Integer -> Task p ()
withPriority p = do
  s <- getTaskSt
  case taskst_priority s of
    Nothing -> setTaskSt $ s { taskst_priority = Just p }
    Just _  -> getNodeName >>= \name ->
               fail ("Cannot use withPriority more than once in task named "
                     ++ name)

-- | Add an Ivory Module to the result of this Tower compilation, from the
--   Task context.
withModule :: Module -> Task p ()
withModule m = do
  s <- getTaskSt
  setTaskSt $ s { taskst_extern_mods = m:(taskst_extern_mods s)}


-- | Create an 'Ivory.Tower.Types.OSGetTimeMillis' in the context of a 'Task'.
withGetTimeMillis :: Task p OSGetTimeMillis
withGetTimeMillis = do
  os <- getOS
  return $ OSGetTimeMillis (os_getTimeMillis os)

-- | Create a global (e.g. not stack) variable which is private to the task
--   code.
taskLocal :: (IvoryArea area) => Name -> Task p (Ref Global area)
taskLocal n = tlocalAux n Nothing

-- | like 'TaskLocal' but you can provide an 'Init' initialization value.
taskLocalInit :: (IvoryArea area) => Name -> Init area -> Task p (Ref Global area)
taskLocalInit n i = tlocalAux n (Just i)

-- | Private helper implements 'taskLocal' and 'taskLocalInit'
tlocalAux :: (IvoryArea area) => Name -> Maybe (Init area) -> Task p (Ref Global area)
tlocalAux n i = do
  f <- freshname
  let m = area (n ++ f) i
  -- When we started, I thought the taskLocal variables should be private.
  -- However, now that we expose taskDependency, we have a mechanism to use them
  -- from outside the precise *module*s generated by the Task context. So we
  -- will make the definition public.
  taskStAddModuleDefUser $ public $ defMemArea m
  return (addrOf m)

-- | Task Initialization handler. Called once when the Tower system initializes.
taskInit :: ( forall s . Ivory (ProcEffects s ()) () ) -> Task p ()
taskInit i = do
  s <- getTaskSt
  n <- getNodeName
  case taskst_taskinit s of
    Nothing -> setTaskSt $ s { taskst_taskinit = Just (initproc n) }
    Just _ -> (err n)
  where
  err nodename = error ("multiple taskInit definitions in task named "
                          ++ nodename)
  initproc nodename = proc ("taskInit_" ++ nodename) $ body i

-- | Event handler. Called once per received event. Gives event by
--   reference.
onEvent :: forall area p
           . (IvoryArea area, IvoryZero area)
          => Event area
          -> (forall s s' . ConstRef s area -> Ivory (ProcEffects s' ()) ())
          -> Task p ()
onEvent evt k = onEventAux evt $ \name ->
  proc name $ \ref -> body $ k ref

-- | Channel event handler. Like 'onEvent', but for 'Stored' type events,
--   which can be given by value.
onEventV  :: forall t p
           . (IvoryVar t, IvoryArea (Stored t), IvoryZero (Stored t))
          => Event (Stored t)
          -> (forall s . t -> Ivory (ProcEffects s ()) ())
          -> Task p ()
onEventV evt k = onEventAux evt $ \name ->
  proc name $ \ref -> body $ deref ref >>= k

-- | Private helper function used to implement 'onEvent' and 'onEventV'
onEventAux  :: forall area p
             . (IvoryArea area)
            => Event area
            -> (forall s . Name -> Def ('[ConstRef s area] :-> ()))
            -> Task p ()
onEventAux evt mkproc = do
  n <- getNodeName
  f <- freshname
  let name = printf "eventhandler_%s_%s%s"  n evtname f
      callback :: Def ('[ConstRef s area] :-> ())
      callback = mkproc name
  taskStAddModuleDefUser $ incl callback
  taskStAddEventHandler $ Action $ do
    rdy <- deref (evt_ready evt)
    when rdy $ call_ callback (evt_ref evt)
  where
  evtname = case evt_impl evt of
    ChannelEvent chid -> "chan" ++ (show (chan_id chid))
    PeriodEvent  p    -> "per" ++ (show p)

-- | Private: generate code to make a channel drive an event handler.
--   Assumes the channel receiver is ONLY used to drive event handler - don't
--   expose the receiver to the user after using it to drive an event handler.
makeChannelEvent :: (IvoryArea area) => ChannelReceiver n area -> Task p (Event area)
makeChannelEvent chrxer = do
  ready <- taskLocal (named "ready")
  ref   <- taskLocal (named "ref")
  taskStAddEventRxer $ Action $ do
    success <- cr_extern_rx chrxer ref
    store ready success
  return $ Event
    { evt_impl  = ChannelEvent (cr_chid chrxer)
    , evt_ref   = constRef ref
    , evt_ready = constRef ready
    }
  where
  named n = "chan" ++ (show (chan_id (cr_chid chrxer))) ++ "_evt_" ++ n

-- | Public: Make a channel receiver which drives an event handler.
withChannelEvent :: (SingI n, IvoryArea area, IvoryZero area)
      => ChannelSink n area -> String -> Task p (Event area)
withChannelEvent chsink label = do
  rxer <- withChannelReceiver chsink label
  makeChannelEvent rxer

withPeriodicEvent :: Integer -> Task p (Event (Stored Uint32))
withPeriodicEvent interval = do
  per   <- mkPeriod interval
  ready <- taskLocal (named "ready")
  ref   <- taskLocal (named "ref")
  taskStAddEventRxer $ Action $ do
    success <- per_tick per
    now     <- per_tnow per
    store ready success
    store ref   now
  return $ Event
    { evt_impl  = PeriodEvent interval
    , evt_ref   = constRef ref
    , evt_ready = constRef ready
    }
  where
  named n = "per" ++ (show interval) ++ "_evt_" ++ n

-- | Private: interal, makes a Period from an integer, stores
--   generated code
mkPeriod :: Integer -> Task p Period
mkPeriod per = do
  st <- getTaskSt
  setTaskSt $ st { taskst_periods = per : (taskst_periods st)}
  os <- getOS
  n <- freshname
  let (p, initdef, mdef) = os_mkPeriodic os per n
  nodeStAddCodegen initdef mdef
  return p

--- Legacy interface emulation

onPeriod :: Integer -> (forall s  . Uint32 -> Ivory (ProcEffects s ()) ()) -> Task p ()
onPeriod p k = do
  e <- withPeriodicEvent p
  onEventV e k

onChannel :: (SingI n, IvoryArea area, IvoryZero area)
          => ChannelSink n area -> String
          -> (forall s cs . ConstRef s area -> Ivory (ProcEffects cs ()) ()) -> Task p ()
onChannel c label k = do
  e <- withChannelEvent c label
  onEvent e k

onChannelV :: (SingI n, IvoryVar t, IvoryArea (Stored t), IvoryZero (Stored t))
           => ChannelSink n (Stored t) -> String
           -> (forall cs . t -> Ivory (ProcEffects cs ()) ()) -> Task p ()
onChannelV c label k = do
  e <- withChannelEvent c label
  onEventV e k
