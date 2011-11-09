# app.coffee contains the instance of the main application router, as
# well as any other objects which are considered "singletons", such as
# full-page views.

session          = require 'models/session'

{ Inputs }       = require 'collections/inputs'
{ Queries }      = require 'collections/queries'
{ Modules }      = require 'collections/modules'

{ InputManager } = require 'lib/input_manager'

# Holds the router singleton. For the moment the application has only
# one; in time we may add more.
exports.router = null

# Holds each of the main model collections (Sliders, Widgets, etc).
exports.collections = {}

# Contains the raw model data from the server -- inputs, queries, etc. Used
# when a module loads so that we can prepare actual model instances as needed.
exports.raw = require 'raw'

# The singleton views/Master instance.
exports.masterView = null

# Used to simplify persistance of Inputs and Queries.
exports.inputManager = null

# Called _once_ when the application is first loaded in the browser.
exports.boot = (window, locale) ->
  installConsolePolyfill window

  I18n.locale    = locale
  I18n.fallbacks = no

  # Set up the collections.
  exports.collections.inputs  = new Inputs
  exports.collections.queries = new Queries
  exports.collections.modules = new Modules

  async.parallel data: fetchInitialData, postBoot

# Bootstrap Functions, execute in parallel -----------------------------------

# Retrieves static data such as input and query definitions. Ideally it should
# be possible for the remote API to deliver this all in a single response.
#
fetchInitialData = (callback) ->
  createDefaultInputs  exports.collections.inputs
  createDefaultQueries exports.collections.queries
  createDefaultModules exports.collections.modules

  callback null, true

# Called after all the other boot functions have completed.
#
# Issues a warning if one of the functions failed, otherwise finishes set-up
# of the application. Any part of the app set-up which depends must occur
# _after_ the asynchronous boostrap function should go here.
#
postBoot = (err, result) ->
  exports.boot = (->)

  if err?
    console.error "Could not initialize application.", err
  else
    exports.router       = new (require('router').Router)
    exports.masterView   = new (require('views/master').MasterView)

    # Fire up Backbone routing...
    Backbone.history.start pushState: true

# Helper Functions -----------------------------------------------------------

# If the Inputs collection has no entries, this is the first time the user has
# visited the application. Create twelve sample inputs for the ETLite
# recreation page.
#
# This can be removed once ETEngine is integrated.
#
createDefaultInputs = (collection) ->
  collection.add input for input in exports.raw.inputs

# Creates the default Query instances.
#
# This can be removed once there's a better infrastructure in place for
# storing and retrieving Query instances.
#
createDefaultQueries = (collection) ->
  collection.add query for query in exports.raw.queries

# Creates a single module; the ETlite module.
#
# This can be removed once modules are defined on the server and delivered
# as JSON to the client.
#
createDefaultModules = (collection) ->
  collection.add
    id:   1
    name: 'ETlite'

    leftInputs:  [  43, 146, 336, 348, 366, 338 ]
    rightInputs: [ 315, 256, 259, 263, 313, 196 ]

    centerVis:     require('views/vis/supply_demand').SupplyDemandView
    mainVis:     [ require('views/vis/renewables').RenewablesView,
                   require('views/vis/co2_emissions').CO2EmissionsView
                   require('views/vis/costs').CostsView ]

installConsolePolyfill = (window) ->
  unless 'console' of window
    window.console = { log: (->), info: (->), warn: (->), error: (->) }
