# Scrap every startup the MFS search engine returns


# Server >> Startups > Initialization


Spooky  = Meteor.npmRequire('spooky')
cronJob = Meteor.npmRequire('cron').CronJob

startups = [ ]


# Server >> Startups > Actions


@startupResearch = ->
	startupProcess.then ->
    for i in [1..248]
		  @then ->
        url = 'http://www.myfrenchstartup.com/fr/liste-startup-france/-' + i
        @open url

      @then ->
        @wait 2 * 1000

			@then ->
				startups = @evaluate ->
				  links = []

				  $('#affiche td a').each ->
				    link = $(this).attr('href')
				    links.push link

				  return links

			@then ->
				@emit 'save.startups', startups
				@wait 2 * 1000


# Server >> Startups > Event Listeners > Specific


@startupProcessSaveStartups = (startups) ->
	for startup in startups
		exist = Startups.findOne { url: startup }

		if not exist?
      Startups.insert { url: startup }


# Server >> Startups > Event Listeners > Debugging
 
 
@startupProcessRemoteMessage = (line) ->
  console.log 'MFS Startups: [PhantomJS] ' + line
 
 
@startupProcessConsole = (line) ->
  console.log 'MFS Startups: ' + line
 
 
@startupProcessError = (e, stack) ->
  console.error 'MFS Startups: ' + e
 
 
@startupProcessDie = (e, stack) ->
  console.error 'MFS Startups: ' + e
  console.log 'MFS Startups: The process just die'
  startupDestroyProcess()
 
 
@startupProcessStarted = ->
  console.log 'MFS Startups: The process is starting'
 
 
@startupProcessCompleted = ->
  console.log 'MFS Startups: The process is now over'
  startupDestroyProcess()
 
 
# Server >> Startups > Helpers
 
 
@startupDestroyProcess = ->
  startupProcess.removeAllListeners()
  # startupProcess.destroy()
  console.log 'MFS Startups: Spooky has been destroyed'
 
 
# Server >> Startups > Build Processes
 
 
@buildStartupProcess = (err) ->
  if err
    e = new Error 'Failed to initialize SpookyJS'
    e.details = err
    throw e
 
  # 1. Debugging & Specific Event Listeners
  startupProcess.on 'remote.message', startupProcessRemoteMessage
  startupProcess.on 'console', startupProcessConsole
  startupProcess.on 'error', startupProcessError
  startupProcess.on 'die', startupProcessDie
  startupProcess.on 'run.start', startupProcessStarted
  startupProcess.on 'run.complete', startupProcessCompleted

  startupProcess.on 'save.startups', Meteor.bindEnvironment startupProcessSaveStartups
 
  # 2. Initialization
  startupProcess.start()
 
  # 3. Actions
  startupResearch()
  startupScraping()
 
  # 4. Time to run the process
  startupProcess.run()
 
 
# Server >> Startups > Run Processes
 
 
@runStartupProcess = ->
  @startupProcess = new Spooky
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
 
  , Meteor.bindEnvironment buildStartupProcess
 
 
# Server >> Startups > Cron Jobs
 

# Meteor.startup ->
#   runStartupProcess()
