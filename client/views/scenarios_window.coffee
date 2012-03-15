app            = require 'app'

template       = require 'templates/scenarios_window'
summaryTpl     = require 'templates/summaries/scenario'

{ ScenarioSummaries } = require 'collections/scenario_summaries'

{ costsWidth, renewablesWidth, emissionsWidth, HighScores } =
  require 'views/high_scores'

# ScenariosWindow ------------------------------------------------------------

class exports.ScenariosWindow extends Backbone.View
  className: 'overlay-content high-scores-overlay'

  events:
    'click .high-scores li': 'activateScenario'

  # Creates a new ScenariosWindow. Loads the high scores and stuff. :D
  constructor: (options) ->
    @scores = new HighScores show: 8, style: 'compact', realtime: false
    @scene  = options.scene

    super

  # Creates the HTML for the scenarios window. Does not place anything into
  # the DOM.
  #
  # Returns self.
  #
  render: ->
    @$el.html template()
    @$('.high-scores').append @scores.render().el
    @$('.since').addClass 'nav'

    this

  # Callback triggered when the user click on one of the high scoring
  # scenarios. Shows a summary of the scenarios in the right-hand pane.
  #
  activateScenario: (event) =>
    scenarioId = event.currentTarget.id.replace(/^high-score-/, '')
    scenarioId = parseInt scenarioId, 10

    if scenario = @scores.collection.get scenarioId
      @scores.$('li').removeClass 'active'
      $( event.currentTarget ).addClass 'active'

      # Get the widths for each bar.

      @$('.info .content').html(new ScenarioComparison(
        current: @scene, selected: scenario).render().el)

# ScenarioComparison ---------------------------------------------------------

class ScenarioComparison extends Backbone.View
  # Creates a new ScenarioComparison; compares the currently active scenario
  # with one chosen from a list in the ScenarioWindow.
  constructor: ({ @current, @selected }) -> super

  # Renders HTML which compares the outcomes of two scenarios.
  render: ->
    @$el.html summaryTpl
      width:
        emissions:    (q) -> emissionsWidth  q.get 'future'
        costs:        (q) -> costsWidth      q.get 'future'
        renewability: (q) -> renewablesWidth q.get 'future'
      selected:
        who:          userName @selected
        emissions:    @selected.query 'total_co2_emissions'
        renewability: @selected.query 'renewability'
        score:        @selected.query 'score'
        costs:        @selected.query 'total_costs'
      current:
        who:          '{who}'
        emissions:    @current.queries.get 'total_co2_emissions'
        renewability: @current.queries.get 'renewability'
        score:        @current.queries.get 'etflex_score'
        costs:        @current.queries.get 'total_costs'

    this

# Helpers --------------------------------------------------------------------

# Returns the name of the owner of a scenario summary as a string. Will return
# "You" if it is the current user.
userName = (summary) ->
  if summary.get('user_id') is app.user.id
    I18n.t('words.you').toLowerCase()
  else
    summary.get 'user_name'
