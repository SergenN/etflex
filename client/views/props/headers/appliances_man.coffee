{ HeaderIcon } = require 'views/props/header_icon'

class exports.AppliancesManProp extends HeaderIcon
  queries: [ 'etflex_households_amount_of_appliances' ]

  hurdles: [ 3150 ]
  states:  [ 'reading', 'watching' ]

  render: ->
    result = super
    @$el.append '<span class="animation cat"></span>'

    result
