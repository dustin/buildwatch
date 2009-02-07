#
#  BuildWatchAppDelegate.py
#  BuildWatch
#
#  Created by Dustin Sallings on 2/28/08.
#  Copyright Dustin Sallings <dustin@spy.net> 2008. All rights reserved.
#

from Foundation import *
from AppKit import *

import time
import sys, re
import threading
import Queue

from twisted.spread import pb
from twisted.cred import credentials, error
from twisted.internet import reactor, task

PING_FREQUENCY = 60 * 5
PING_TIMEOUT = 15

class StatusClient(pb.Referenceable):
    """To use this, call my .connected method with a RemoteReference to the
    buildmaster's StatusClientPerspective object.
    """

    def __init__(self, events, q):
        self.builders = {}
        self.events = events
        self.queue = q

    def connected(self, remote):
        print "connected"
        self.remote = remote
        remote.callRemote("subscribe", self.events, 5, self)

    def remote_builderAdded(self, buildername, builder):
        self.queue.put(lambda b: b.builderAdded_(buildername))

    def remote_builderRemoved(self, buildername):
        self.queue.put(lambda b: b.builderRemoved_(buildername))

    def remote_builderChangedState(self, buildername, state, eta):
        self.queue.put(lambda b:
            b.builderChangedState_state_eta_(buildername, state, str(eta)))

    def remote_buildStarted(self, buildername, build):
        self.queue.put(lambda b: b.buildStarted_(buildername))

    def remote_buildFinished(self, buildername, build, result):
        self.queue.put(lambda b:
            b.buildFinished_result_(buildername, int(result)))

    def remote_buildETAUpdate(self, buildername, build, eta):
        self.queue.put(lambda b: b.buildETAUpdate_eta_(buildername, eta))

    def remote_stepStarted(self, buildername, build, stepname, step):
        self.queue.put(lambda b: b.stepStarted_stepname_(buildername, stepname))

    def remote_stepFinished(self, buildername, build, stepname, step, result):
        self.queue.put(lambda b:
            b.stepFinished_stepname_result_(buildername, stepname,
                int(result[0])))

    def remote_stepETAUpdate(self, buildername, build, stepname, step,
                             eta, expectations):
        self.queue.put(lambda b:
            b.stepETAUpdate_stepname_eta_(buildername, stepname, eta))

    def remote_logStarted(self, buildername, build, stepname, step,
                          logname, log):
        print "logStarted", buildername, stepname

    def remote_logFinished(self, buildername, build, stepname, step,
                           logname, log):
        print "logFinished", buildername, stepname

    def remote_logChunk(self, buildername, build, stepname, step, logname, log,
                        channel, text):
        ChunkTypes = ["STDOUT", "STDERR", "HEADER"]
        print "logChunk[%s]: %s" % (ChunkTypes[channel], text)

class BridgeClient:
    def __init__(self, master, queue, events="steps"):
        """
        @type  events: string, one of builders, builds, steps, logs, full
        @param events: specify what level of detail should be reported.
         - 'builders': only announce new/removed Builders
         - 'builds': also announce builderChangedState, buildStarted, and
           buildFinished
         - 'steps': also announce buildETAUpdate, stepStarted, stepFinished
         - 'logs': also announce stepETAUpdate, logStarted, logFinished
         - 'full': also announce log contents
        """
        self.master = master
        self.queue = queue
        self.listener = StatusClient(events, queue)
        self.lastMessage = time.time()
        self.remote = None
        self.running = True

    def startConnecting(self):
        try:
            host, port = re.search(r'(.+):(\d+)', self.master).groups()
            port = int(port)
        except:
            print "unparseable master location '%s'" % self.master
            print " expecting something more like localhost:8007"
            raise
        cf = pb.PBClientFactory()
        creds = credentials.UsernamePassword("statusClient", "clientpw")
        d = cf.login(creds)
        reactor.connectTCP(host, port, cf)
        d.addCallbacks(self.connected, self.not_connected)
        return d

    def shutdown(self):
        self.running = False
        self.hangUp()

    def hangUp(self):
        if self.remote:
            self.remote.broker.transport.loseConnection()

    def checkTimeout(self, t):
        if t == self.lastMessage:
            print "Timed out.  Let's hang up or something."
            self.hangUp()

    def ping(self):
        print "Doing ping."
        def recordResponse(x):
            print "Ping response:  %s" % x
            self.lastMessage = time.time()
        reactor.callLater(PING_TIMEOUT, self.checkTimeout, self.lastMessage)
        self.remote.callRemote('ping').addBoth(recordResponse)

    def retry(self):
        if self.running:
            print "Retrying in 5s"
            reactor.callLater(5, self.startConnecting)

    def connected(self, ref):
        ref.notifyOnDisconnect(self.disconnected)
        self.remote = ref
        self.listener.connected(ref)
        self.pinger = task.LoopingCall(self.ping)
        self.pinger.start(PING_FREQUENCY)

    def not_connected(self, why):
        if why.check(error.UnauthorizedLogin):
            print """
Unable to login.. are you sure we are connecting to a
buildbot.status.client.PBListener port and not to the slaveport?
"""
        self.retry()
        return why

    def disconnected(self, ref):
        print "lost connection"
        self.pinger.stop()
        def sendNotification(notused):
            NSNotificationCenter.defaultCenter().postNotificationName_object_(
                'disconnected', self.master)
        self.queue.put(sendNotification)
        self.retry()

class TwistyThread(threading.Thread):
    def __init__(self):
        threading.Thread.__init__(self)
        self.setName("Reactor thread")
        self.start()

    def run(self):
        reactor.run(False)

class BuildWatchAppDelegate(NSObject):

    bridge = objc.IBOutlet('bridge')

    def emptyQueue(self):
        while not self.queue.empty():
            self.queue.get()(self.bridge)

    def startTask_(self, notification):
        loc=notification.object()
        NSLog("Starting task connected to %@", loc)
        bc = BridgeClient(loc, self.queue)
        self.tasks[loc] = bc
        reactor.callFromThread(bc.startConnecting)

    def stopTask_(self, notification):
        NSLog("Requested to stop task %@", loc)
        self.tasks[loc].shutdown()
        del self.tasks[loc]

    def stopAll_(self, notification):
        NSLog("Requested to stop all tasks.")
        for loc,bridge in self.tasks.iteritems():
            bridge.shutdown()
        self.tasks.clear()

    def awakeFromNib(self):
        self.thread = TwistyThread()
        self.tasks={}
        self.queue=Queue.Queue()

        NSNotificationCenter.defaultCenter().addObserver_selector_name_object_(
            self, 'startTask:', 'connect', None)
        NSNotificationCenter.defaultCenter().addObserver_selector_name_object_(
            self, 'stopTask:', 'disconnect', None)
        NSNotificationCenter.defaultCenter().addObserver_selector_name_object_(
            self, 'stopAll:', 'disconnectAll', None)

        self.timer = NSTimer.scheduledTimerWithTimeInterval_target_selector_userInfo_repeats_(
            2, self, 'emptyQueue', None, True)
