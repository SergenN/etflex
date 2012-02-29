template        = require 'templates/prop'
{ GenericProp } = require 'views/props/generic'

# A base class used by props which appear in the dashboard section. Shows an
# icon visualisation, and a nicely formatted version of the query value, and
# the change from the previous value.
#
class exports.DashboardProp extends GenericProp

  # Renders a simple template, and assigns values and events.
  #
  render: (value, unit) ->
    @$el.html template value: value, unit: unit
    super

  # Shows the user the difference between the previous value of a prop, and
  # the new value. Formats the number appropriately for the user locale.
  #
  # difference - The difference between the old and new values.
  # options    - Options which are passed to the I18n formatted.
  #
  setDifference: (difference, options = { precision: 1 }) ->
    element = @$el.find '.difference'

    # Clear out other classes by default
    element.attr class: 'difference'

    # The locale-formatted difference.
    formatted  = I18n.toNumber difference, options

    # Don't display the difference if, when rounded to the precision, it would
    # equal 0 (e.g. score increases by 0.1, but we only care when it increases
    # in whole numbers).
    difference = parseFloat @precision(difference,
      if options.precision? then options.precision else 1)

    if difference > 0
      element.addClass('up').html "#{formatted}"
    else if difference < 0
      element.addClass('down').html "#{formatted}"
    else
      element.html ""