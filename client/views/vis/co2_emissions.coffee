{ GenericVisualisation } = require 'views/vis/generic'
{ IconVisualisation }    = require 'views/vis/icon'

class exports.CO2EmissionsView extends GenericVisualisation
  @queries: [ 8 ]

  className: 'visualisation co2-emissions'

  # Creates a new CO2Emissions visualisation. In addition to the usual
  # Backbone options, requires `gas` containing the gas-fired power plants
  # input, and `coal` containing the coal-fired power plans input.
  #
  constructor: (options) ->
    super options

    @icon = new IconVisualisation

    @query = options.queries.get 8
    @query.bind 'change:future', @updateValues

  # Calculates the total CO2 emissions based on the value of the coal and
  # gas inputs.
  #
  recalculate: ->
    # Query result is in kilograms. Devide by 1000 to get tons, then 1000000
    # to get Mtons.
    @precision @query.get('future') / 1000000000, 1

  # Renders the UI; calculates the C02 emissions. Can be safely called
  # repeatedly to update the UI.
  #
  render: ->
    super '', I18n.t 'etlite.emissions'

    $(@el).find('.icon').replaceWith @icon.render().el
    @updateValues()

    this

  updateValues: =>
    value   = @recalculate()
    element = $ @el

    element.find('.output').html "#{value} Mton CO<sup>2</sup>"

    if value < 140
      @icon.setState 'low'
    else if value < 150
      @icon.setState 'medium'
    else
      @icon.setState 'high'

    this
