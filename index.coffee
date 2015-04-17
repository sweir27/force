#
# Main app file that runs setup code and starts the server process.
# This code should be kept to a minimum. Any setup code that gets large should
# be abstracted into modules under /lib.
#

{ PORT, NODE_ENV, RESTART_INTERVAL, API_URL, ARTSY_ID, ARTSY_SECRET } = require "./config"
artsyXapp = require 'artsy-xapp'
require 'newrelic' if NODE_ENV in ['production','staging']

require './findleak'

express = require "express"
setup = require "./lib/setup"
cache = require './lib/cache'

app = module.exports = express()
app.set 'view engine', 'jade'

# Attempt to connect to Redis. If it fails, no worries, the app will move on
# without caching.
cache.setup ->
  setup app

  # Get an xapp token
  artsyXapp.init { url: API_URL, id: ARTSY_ID, secret: ARTSY_SECRET }, ->

    # Start the server and send a message to IPC for the integration test helper
    # to hook into.
    app.listen PORT, ->
      console.log "Listening on port " + PORT
      process.send? "listening"

# Crash if we can't get/refresh an xapp token
artsyXapp.on 'error', process.exit

# Reboot for memory leak (╥﹏╥)
setTimeout process.exit, RESTART_INTERVAL
