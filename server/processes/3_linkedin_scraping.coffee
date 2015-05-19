# Scrap every Linkedin profile


# Server >> Linkedin > Initialization


Spooky  = Meteor.npmRequire('spooky')
cronJob = Meteor.npmRequire('cron').CronJob

linkedin = [ ]


# Server >> Linkedin > Actions


@linkedinScraping = (startups) ->
  founders = Founders.find({ 'linkedin': { $exists: false } }).fetch()

  for founder in founders
    linkedinProcess.then [
      _i: _i,
      founder: founder
    , ->
      @then ->
        @open founder.url
        @wait 2 * 1000

      @then ->
        linkedin = @evaluate ->
          return $('a.link-linkedin').attr 'href'

      @then ->
        console.log linkedin
        if linkedin?
          @emit 'save.linkedin', linkedin, founder.url
    ]


# Server >> Linkedin > Event Listeners > Specific


@linkedinProcessSaveLinkedin = (linkedin, founderUrl) ->
  Founders.update { url: founderUrl }, { $set: { linkedin: linkedin } }


# Server >> Linkedin > Event Listeners > Debugging
 
 
@linkedinProcessRemoteMessage = (line) ->
  console.log 'F6S Linkedin: [PhantomJS] ' + line
 
 
@linkedinProcessConsole = (line) ->
  console.log 'F6S Linkedin: ' + line
 
 
@linkedinProcessError = (e, stack) ->
  console.error 'F6S Linkedin: ' + e
 
 
@linkedinProcessDie = (e, stack) ->
  console.error 'F6S Linkedin: ' + e
  console.log 'F6S Linkedin: The process just die'
  linkedinDestroyProcess()
 
 
@linkedinProcessStarted = ->
  console.log 'F6S Linkedin: The process is starting'
 
 
@linkedinProcessCompleted = ->
  console.log 'F6S Linkedin: The process is now over'
  linkedinDestroyProcess()
 
 
# Server >> Linkedin > Helpers
 
 
@linkedinDestroyProcess = ->
  linkedinProcess.removeAllListeners()
  # linkedinProcess.destroy()
  console.log 'F6S Linkedin: Spooky has been destroyed'
 
 
# Server >> Linkedin > Build Processes
 
 
@buildLinkedinProcess = (err) ->
  if err
    e = new Error 'Failed to initialize SpookyJS'
    e.details = err
    throw e
 
  # 1. Debugging & Specific Event Listeners
  linkedinProcess.on 'remote.message', linkedinProcessRemoteMessage
  linkedinProcess.on 'console', linkedinProcessConsole
  linkedinProcess.on 'error', linkedinProcessError
  linkedinProcess.on 'die', linkedinProcessDie
  linkedinProcess.on 'run.start', linkedinProcessStarted
  linkedinProcess.on 'run.complete', linkedinProcessCompleted

  linkedinProcess.on 'save.linkedin', Meteor.bindEnvironment linkedinProcessSaveLinkedin
 
  # 2. Initialization
  linkedinProcess.start()
 
  # 3. Actions
  linkedinScraping()
 
  # 4. Time to run the process
  linkedinProcess.run()
 
 
# Server >> Linkedin > Run Processes
 
 
@runLinkedinProcess = ->
  @linkedinProcess = new Spooky
    child:
      'ssl-protocol': 'any'
 
    casper:
      logLevel: 'debug' # can also be set 'info', 'warning' and 'error'
      verbose: true
      exitOnError: false
 
      pageSettings:
        userAgent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_2)
                    AppleWebKit/537.36 (KHTML, like Gecko)
                    Chrome/34.0.1847.137 Safari/537.36'
 
  , Meteor.bindEnvironment buildLinkedinProcess
 
 
# Server >> Linkedin > Cron Jobs
 

Meteor.startup ->
  runLinkedinProcess()
