app          = require 'app'
notification = require 'templates/scenario_notification'

# MINIMAL ROUTER -------------------------------------------------------------

# A Router which is used to progressively enhance otherwise static pages, such
# as setting up Pusher subscriptions for scenario updates, etc.
#
class exports.Minimal extends Backbone.Router
  routes:
    'pusher': 'pusher'

  # A test page which is used to listen to events sent by Pusher, such as
  # listing scenario creation and updates, so that we can update the list of
  # highest scoring scenarios.
  #
  # GET /pusher
  #
  pusher: ->
    pusher  = new Pusher '415cc8feb622f665d49a'
    channel = pusher.subscribe 'etflex-development'

    informUpdate = (event, data) ->
      console.log data
      $('#scenarios .none').remove()
      $('#scenarios').prepend $('<li/>').html notification { event, data }

    channel.bind 'scenario.created', (thing) ->
      informUpdate 'scenario.created', thing

    channel.bind 'scenario.updated', (thing) ->
      informUpdate 'scenario.updated', thing
