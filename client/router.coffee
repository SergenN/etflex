app              = require 'app'
{ ModuleView }   = require 'views/module'
{ NotFoundView } = require 'views/not_found'

# A simpler way to call `app.masterView.setSubView`.
render = (view) -> app.masterView.setSubView view

# Router watches the URL and, as it changes, re-renders the main view
# mimicking the user navigating from one page to another.
#
class exports.Router extends Backbone.Router
  routes:
    '':            'root'
    'sanity':      'sanity'
    'etlite':      'etlite'

    'scenes/:id':  'showScene'

    'en':          'languageRedirect'
    'nl':          'languageRedirect'
    'en/*actions': 'languageRedirect'
    'nl/*actions': 'languageRedirect'

    '*undefined':   'notFound'

  constructor: ->
    @views  = { sanity: new (require('views/sanity').SanityView)
              , etlite: new (require('views/etlite').ETLiteView) }

    super()

  # A 404 Not Found page. Presents the user with a localised message guiding
  # them back to the front page.
  #
  # GET /*undefined
  #
  notFound: ->
    $('body').html (new NotFoundView).render().el

  # The root page; simply shows the default scene with the "modern" theme for
  # the moment.
  #
  # GET /
  #
  root: ->
    console.log 'hello world; routing to /scenes/1'
    app.router.navigate '/scenes/1', true

  # A test page which shows the all of the application dependencies are
  # correctly installed and work as intended.
  #
  # GET /sanity
  #
  sanity: ->
    render @views.sanity

  # A recreation of the ETLite UI which serves as the starting point for
  # development of the full ETFlex application.
  #
  # GET /etflex
  #
  etlite: ->
    console.log @views
    render @views.etlite

  # Loads a scene using JSON delivered from ETflex to set up which inputs and
  # visualiations are used.
  #
  # GET /scenes/:id
  #
  showScene: (id) ->
    app.collections.modules.getOrFetch id, (err, module) =>
      # Backbone doesn't return a useful error, but it was almost certainly a
      # 404, so just render the Not Found page...
      if err? then @notFound() else

        # Otherwise, let's start the module by starting the ETengine session.
        module.start (err, module, session) ->
          if err? then console.error err else
            render new ModuleView model: module

  # Used when changing language; a two-character language code is appended to
  # the URL.
  #
  # GET /en/*actions
  # GET /nl/*actions
  #
  languageRedirect: (action) ->
    @navigate action or 'sanity', true
