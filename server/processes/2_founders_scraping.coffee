# Scrap every founders profile


# Server >> Founders > Initialization


Spooky  = Meteor.npmRequire('spooky')
cronJob = Meteor.npmRequire('cron').CronJob

founders = [ ]


# Server >> Founders > Actions


@founderScraping = (startups) ->
  startups = Startups.find().fetch()

  for startup in startups
  	founderProcess.then [
      _i: _i,
      startup: startup
    , ->
      @then ->
        @open startup.url
        @wait 2 * 1000

      @then ->
        founders = @evaluate ->
          links = []

          $('div[data-mod-name="connections_founders"] .profile-img a').each ->
            link = $(this).attr('href')
            links.push(link)

          return links

      @then ->
        @emit 'save.founders', founders
    ]


# Server >> Founders > Event Listeners > Specific


@founderProcessSaveFounders = (founders) ->
	for founder in founders
		exist = Founders.findOne { url: founder }

		if not exist?
      Founders.insert { url: founder }


# Server >> Founders > Event Listeners > Debugging
 
 
@founderProcessRemoteMessage = (line) ->
  console.log 'F6S Founders: [PhantomJS] ' + line
 
 
@founderProcessConsole = (line) ->
  console.log 'F6S Founders: ' + line
 
 
@founderProcessError = (e, stack) ->
  console.error 'F6S Founders: ' + e
 
 
@founderProcessDie = (e, stack) ->
  console.error 'F6S Founders: ' + e
  console.log 'F6S Founders: The process just die'
  founderDestroyProcess()
 
 
@founderProcessStarted = ->
  console.log 'F6S Founders: The process is starting'
 
 
@founderProcessCompleted = ->
  console.log 'F6S Founders: The process is now over'
  founderDestroyProcess()
 
 
# Server >> Founders > Helpers
 
 
@founderDestroyProcess = ->
  founderProcess.removeAllListeners()
  # founderProcess.destroy()
  console.log 'F6S Founders: Spooky has been destroyed'
 
 
# Server >> Founders > Build Processes
 
 
@buildFounderProcess = (err) ->
  if err
    e = new Error 'Failed to initialize SpookyJS'
    e.details = err
    throw e
 
  # 1. Debugging & Specific Event Listeners
  founderProcess.on 'remote.message', founderProcessRemoteMessage
  founderProcess.on 'console', founderProcessConsole
  founderProcess.on 'error', founderProcessError
  founderProcess.on 'die', founderProcessDie
  founderProcess.on 'run.start', founderProcessStarted
  founderProcess.on 'run.complete', founderProcessCompleted

  founderProcess.on 'save.founders', Meteor.bindEnvironment founderProcessSaveFounders
 
  # 2. Initialization
  founderProcess.start()
 
  # 3. Actions
  founderScraping()
 
  # 4. Time to run the process
  founderProcess.run()
 
 
# Server >> Founders > Run Processes
 
 
@runFounderProcess = ->
  @founderProcess = new Spooky
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
 
  , Meteor.bindEnvironment buildFounderProcess
 
 
# Server >> Founders > Cron Jobs
 

# Meteor.startup ->
#   runFounderProcess()
