{ Input } = require 'models/input'

class exports.ManyToOneInput extends Input
  values: ->
    key         = @get('key')
    formula     = @get('formula')
    engine_key  = @get('engine_key')

    variables = {}
    values    = {}

    for dependant in @get('dependant')
      value = @collection.getKey(dependant).get('value')
      variables[dependant] = value

    values[engine_key] = @formula_function(formula).evaluate(variables)

    values


