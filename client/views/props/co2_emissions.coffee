{ GenericProp } = require 'views/props/generic'
{ IconProp }    = require 'views/props/icon'

class exports.CO2EmissionsView extends GenericProp
  @queries: [ 'co2_emission_total' ]
  states:   [ 'low', 'medium', 'high', 'extreme' ]

  className: 'prop co2-emissions'

  # Creates a new CO2Emissions prop. In addition to the usual Backbone
  # options, requires `gas` containing the gas-fired power plants input, and
  # `coal` containing the coal-fired power plans input.
  #
  constructor: (options) ->
    super options

    @icon = new IconProp

    @query = options.queries.get 'co2_emission_total'
    @query.bind 'change:future', @updateValues

  # Renders the UI; calculates the C02 emissions. Can be safely called
  # repeatedly to update the UI.
  #
  render: ->
    super '', I18n.t 'scenes.etlite.emissions'

    $(@el).find('.icon').replaceWith @icon.render().el
    @updateValues()

    this

  # Updates the value shown to the user, and swaps the icon if necessary,
  # without re-rendering the whole view.
  #
  updateValues: =>
    # Query result is in kilograms. Divide by 1000 to get tons, then 1000000
    # to get Mtons.
    value = @query.get('future') / 1000000000

    # Reduce the value to one decimal place when shown.
    $(@el).find('.output').html "#{@precision value, 1} Mton CO<sup>2</sup>"

    @icon.setState @hurdleState value

    this