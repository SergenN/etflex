app            = require 'app'

template       = require 'templates/scenarios_window'
summaryTpl     = require 'templates/summaries/scenario'

{ ScenarioSummaries } = require 'collections/scenario_summaries'
{ HighScores }        = require 'views/high_scores'

class exports.ScenariosWindow extends Backbone.View
  className: 'overlay-content high-scores-overlay'

  events:
    'click .high-scores li': 'activateScenario'

  # Creates a new ScenariosWindow. Loads the high scores and stuff. :D
  constructor: (options) ->
    @scores   = new HighScores show: 8, style: 'compact', realtime: false
    @scenario = options.scenario

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

      @$('.info .content').html summaryTpl
        selected:
          who:          userName scenario
          emissions:    queryVal scenario, 'total_co2_emissions'
          renewability: queryVal scenario, 'renewability'
          score:        queryVal scenario, 'score'
          costs:        queryVal scenario, 'costs'
        current:
          who:          '{who}'
          emissions:    '{emissions}'
          renewability: '{renewability}'
          score:        '{score}'
          costs:        '{costs}'

# Helpers --------------------------------------------------------------------

# Given a scenario summary and query key, returns the formatted value of the
# query as a string.
queryVal = (summary, queryKey) ->
  summary.query(queryKey).formatted 'future'

# Returns the name of the owner of a scenario summary as a string. Will return
# "You" if it is the current user.
userName = (summary) ->
  if summary.get('user_id') is app.user.id
    I18n.t('words.you').toLowerCase()
  else
    summary.get 'user_name'
