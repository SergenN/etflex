application         = require 'app'
etliteTemplate      = require 'templates/etlite'

{ Range }           = require 'views/range'
{ SavingsMediator } = require 'mediators/savings_mediator'
{ CO2Emissions }    = require 'views/vis/co2_emissions'
{ Renewables }      = require 'views/vis/renewables'
{ Costs }           = require 'views/vis/costs'

# A full-page view which recreates the ETLite interface. Six sliders are on
# the left of the UI allowing the user to control how savings can be made in
# energy use, and six on the right controlling how energy will be produced.
#
# A graph in the middle, and three image-based visualisations at the bottom
# provide feedback to the user based on the choices they make.
#
class exports.ETLite extends Backbone.View
  id: 'etlite-view'

  events:
    'click a.clear': 'clearInputStorage'

  # Creates the HTML elements for the view, and binds events. Returns self.
  #
  # Example:
  #
  #   view = new ETLite()
  #   $('body').html view.render().el
  #
  render: ->
    @fetchInputs()

    $(@el).html etliteTemplate()

    leftRangesEl  = @$ '#savings'
    rightRangesEl = @$ '#energy-production'

    # Render each of the ranges...

    _.each @savingsInputs, (range) ->
      leftRangesEl.append new Range(model: range).render().el

    _.each @productionInputs, (range) ->
      rightRangesEl.append new Range(model: range).render().el

    # Add three visualisations to the bottom of the page.

    @$('#visualisations')
      .append(@createRenewablesVis().render().el)
      .append(@createCarbonVis().render().el)
      .append(@createCostsVis().render().el)

    @delegateEvents()
    this

  # Retrieves the inputs needed to render the view, and memoizes them for
  # future reference. Sliders can be found on @savingsInputs and
  # @productionInputs.
  #
  fetchInputs: ->
    inputs = application.collections.inputs

    @savingsInputs or= [
      inputs.getByName 'Low-energy lighting'
      inputs.getByName 'Electric cars'
      inputs.getByName 'Better insulation'
      inputs.getByName 'Solar water heater'
      inputs.getByName 'Switch off appliances'
      inputs.getByName 'Heat pump for the home'
    ]

    @productionInputs or= [
      inputs.getByName 'Coal-fired power plants'
      inputs.getByName 'Gas-fired power plants'
      inputs.getByName 'Nuclear power plants'
      inputs.getByName 'Wind turbines'
      inputs.getByName 'Solar panels'
      inputs.getByName 'Biomass'
    ]

  # Callback for the "Clear Input Storage" button. Wipes out all of the inputs
  # which should be followed by a browser refresh.
  #
  clearInputStorage: (event) =>
    head.destroy() while head = application.collections.inputs.first()
    event.preventDefault()

  # Creates and returns the visualisation which shows the total amount of
  # carbon emissions based on the user's choices.
  #
  createCarbonVis: ->
    new CO2Emissions
      gas:  @productionInputs[0]
      coal: @productionInputs[1]

  # Creates and returns the visualisation which shows the proportion of energy
  # generated from renewable, but unreliable, sources.
  #
  createRenewablesVis: ->
    new Renewables
      gas:      @productionInputs[0]
      coal:     @productionInputs[1]
      nuclear:  @productionInputs[2]
      wind:     @productionInputs[3]
      solar:    @productionInputs[4]
      biomass:  @productionInputs[5]

  # Creates and returns the visualisation which shows the total cost, in
  # Euros, of the choices the user makes.
  #
  createCostsVis: ->
    new Costs
      lighting:   @savingsInputs[0]
      cars:       @savingsInputs[1]
      insulation: @savingsInputs[2]
      heating:    @savingsInputs[3]
      appliances: @savingsInputs[4]
      heatPump:   @savingsInputs[5]

      gas:        @productionInputs[0]
      coal:       @productionInputs[1]
      nuclear:    @productionInputs[2]
      wind:       @productionInputs[3]
      solar:      @productionInputs[4]
      biomass:    @productionInputs[5]
