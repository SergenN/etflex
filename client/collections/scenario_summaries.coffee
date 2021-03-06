class exports.ScenarioSummaries extends Backbone.Collection
  model: require('models/scenario_summary').ScenarioSummary

  # Sorts summaries by score in descending order.
  comparator: (summary) -> - summary.get('score')

  # Returns a subcollection (as an array) containing only scenarios which have
  # a user name present.
  identified: ->
    @filter (summary) -> summary.get('user_name')?.match(/\S/)

  # Returns whether the given Summary score places it within the top N of
  # summaries in the collection.
  isTopN: (summary, n) ->
    isWithinThreshold summary, @models, n

  # Returns whether the given score summary should be displayed in the top N
  # list of summaries.
  #
  # This differs slightly from isTopN in that only summaries which have a
  # username are considered worth of display.
  shouldDisplay: (summary, n) ->
    return false unless summary.get('user_name')?.match(/\S/)

    isWithinThreshold summary, @identified(), n

# HELPERS --------------------------------------------------------------------

isWithinThreshold = (summary, collection, n) ->
  return true if collection.length < n

  # The summary which currently occupies the "last" position in the high
  # scores collection...
  atThreshold = collection[ n - 1 ]

  atThreshold.id is summary.id or
    atThreshold.get('score') <= summary.get('score')
