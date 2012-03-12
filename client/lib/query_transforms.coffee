# When a query does not define a formatting function, this is used instead.
FORMAT_DEFAULT = (value) ->
  I18n.toNumber value, precision: 1, strip_insignificant_zeros: true

# Formatter which displays a value in euros
FORMAT_EUROS = (value) ->
  I18n.toCurrency(value, unit: '€')

# Formatter which displays a percentage.
FORMAT_PERCENT = (value) ->
  I18n.toPercentage value, precision: 1, strip_insignificant_zeros: true

# Returns a function which divides a value by divisor.
divide = (divisor) -> ((value) -> value / divisor)

# Returns a function which multiplies a value by multiplier.
multiply = (multiplier) -> ((value) -> value * multiplier)

# Formats a value with the given unit.
as = (unit) -> ((value) -> "#{FORMAT_DEFAULT value} #{unit}")

# Retrieves the mutate/format definitions for a given query.
exports.forQuery = (query) ->
  if found = TRANSFORMS[ query.id ]
    found.mutate = _.identity unless found.mutate
    found.format = FORMAT_DEFAULT unless found.format
    found
  else
    TRANSFORMS[ query.id ] = { format: FORMAT_DEFAULT, mutate: _.identity }

# Transforms -----------------------------------------------------------------

TRANSFORMS =
  # ETFlex score must be rounded to a whole number, and restricted to no less
  # than 0 and no more than 999.
  etflex_score:
    mutate: (value) ->
      if (rounded = Math.round value) < 0
        0
      else if rounded > 999
        999
      else
        rounded

  # CO2 emissions arrive in kg so we convert to megatons.
  total_co2_emissions:
    mutate: divide 1000000000
    format: as 'Mtons'

  # Total costs come in Euros; convert to billions.
  total_costs:
    mutate: divide 1000000000
    format: (value) ->
      I18n.t 'magnitudes.billion', amount: FORMAT_EUROS(value)

  # Risk is bad, none is good.
  security_of_supply_blackout_risk:
    mutate: (value) -> ( 1 - value ) * 100
    format: FORMAT_PERCENT

  # Renewables arrives as a factor and should be displayed as a percentage.
  renewability:
    mutate: (value) -> value * 100
    format: FORMAT_PERCENT