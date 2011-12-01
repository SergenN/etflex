app = require 'app'

class exports.NotFoundView extends Backbone.View
  id:        'static-message-view'
  className: 'not-found'

  events:
    'click a': 'navigateToRoot'

  render: ->
    $(@el).append(
      $("<div class='message'></div>")
        .append($("<h1>#{ I18n.t 'oops' }!</h1>"))
        .append($("<p>#{ I18n.t 'fourOhFour' }</p>"))
        .append($("<p><a href='/'>#{ I18n.t 'frontPage' }.</a></p>")))

    this

  navigateToRoot: (event) ->
    app.navigate '', true
    event.preventDefault()
