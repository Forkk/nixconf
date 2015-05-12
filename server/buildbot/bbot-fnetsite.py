# -*- python -*-
# ex: set ft=python:

# This is a sample buildmaster config file. It must be installed as
# 'master.cfg' in your buildmaster's base directory.

# This is the dictionary that the buildmaster pays attention to. We also use
# a shorter alias to save typing.
c = BuildmasterConfig = {}

####### BUILDSLAVES

# The 'slaves' list defines the set of recognized buildslaves. Each element is
# a BuildSlave object, specifying a unique slave name and password.  The same
# slave name and password must be configured on the slave.
from buildbot.buildslave import BuildSlave
c['slaves'] = [BuildSlave("forkknet", "password")]

# 'slavePortnum' defines the TCP port to listen on for connections from slaves.
# This must match the value configured into the buildslaves (with their
# --master option)
c['slavePortnum'] = 9989

####### CHANGESOURCES

# the 'change_source' setting tells the buildmaster how it should find out
# about source code changes.  Here we point to the buildbot clone of pyflakes.

c['change_source'] = []


####### SCHEDULERS

# Configure the Schedulers, which decide how to react to incoming changes.  In this
# case, just kick off a 'runtests' build

from buildbot.schedulers.basic import SingleBranchScheduler
from buildbot.schedulers.forcesched import ForceScheduler
from buildbot.changes import filter
c['schedulers'] = []

c['schedulers'].append(ForceScheduler(
                            name="force-master",
                            builderNames=["master"]))

c['schedulers'].append(SingleBranchScheduler(
                            name="git-master",
                            change_filter=filter.ChangeFilter(branch='master'),
                            treeStableTimer=30,
                            builderNames=["master"]))

# c['schedulers'].append(SingleBranchScheduler(
#                             name="git-develop",
#                             change_filter=filter.ChangeFilter(branch='develop'),
#                             treeStableTimer=30,
#                             builderNames=["develop"]))

####### BUILDERS

# The 'builders' list defines the Builders, which tell Buildbot how to perform a build:
# what steps, and which slaves can execute them.  Note that any particular build will
# only take place on one slave.

from buildbot.process.factory import BuildFactory
from buildbot.steps.source.git import Git
from buildbot.steps.shell import ShellCommand, Configure, Compile
from buildbot.steps.master import MasterShellCommand
from buildbot.steps.transfer import DirectoryUpload
from buildbot.config import BuilderConfig

c['builders'] = []

f = BuildFactory()

# Check out the source.
f.addStep(Git(repourl="git://github.com/Forkk/forkk.net", mode="incremental"))

# f.addStep(ShellCommand(name="init-sandbox",
#                        command=["cabal", "sandbox", "init"],
#                        description=["initializing", "sandbox"],
#                        descriptionDone=["initialize", "sandbox"]))

# Build the site.
f.addStep(Compile(
    name="compile",
    command=["ghc", "--make", "-threaded", "site.hs"],
    description=["compiling", "site", "builder"],
    descriptionDone=["compile", "site", "builder"]
))
f.addStep(Compile(
    name="build-site",
    command=["./site", "rebuild"],
    description=["building", "site"],
    descriptionDone=["build", "site"]
))

f.addStep(DirectoryUpload(
    name="deploy",
    slavesrc="_site",
    masterdest="/var/www/forkk.net",
    description=["deploying", "site"],
    descriptionDone=["deploy", "site"]
))


c['builders'].append(
    BuilderConfig(name="master", slavenames=["forkknet"], factory=f))


####### STATUS TARGETS

# 'status' is a list of Status Targets. The results of each build will be
# pushed to these targets. buildbot/status/*.py has a variety to choose from,
# including web pages, email senders, and IRC bots.

c['status'] = []

from buildbot.status import html
from buildbot.status.web import authz, auth
from buildbot.status import words

authz_cfg=authz.Authz(
    # change any of these to True to enable; see the manual for more
    # options
    auth=auth.BasicAuth([("forkk", "password")]),
    gracefulShutdown = False,
    forceBuild = 'auth', # use this to test your slave once it is set up
    forceAllBuilds = False,
    pingBuilder = False,
    stopBuild = False,
    stopAllBuilds = False,
    cancelPendingBuild = False,
)
c['status'].append(html.WebStatus(http_port=8010, authz=authz_cfg,
                                  change_hook_dialects={"github": True}))


####### PROJECT IDENTITY

# the 'title' string will appear at the top of this buildbot
# installation's html.WebStatus home page (linked to the
# 'titleURL') and is embedded in the title of the waterfall HTML page.

c['title'] = "Forkk.net Website"
c['titleURL'] = "https://github.com/Forkk/forkk.net"

# the 'buildbotURL' string should point to the location where the buildbot's
# internal web server (usually the html.WebStatus page) is visible. This
# typically uses the port number set in the Waterfall 'status' entry, but
# with an externally-visible host name which the buildbot cannot figure out
# without some help.

c['buildbotURL'] = "http://siteci.forkk.net/"

####### DB URL

c['db'] = {
    # This specifies what database buildbot uses to store its state.  You can leave
    # this at its default for all but the largest installations.
    'db_url' : "sqlite:///state.sqlite",
}
