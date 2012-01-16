{ collections } = require 'app'

# Scenario keeps track of a user's attempt to complete a scene. Holding on to
# the scene ID, user ID, and the corresponding ET-Engine session ID, it allows
# a user to attempt a scene multiple times, and to share their scenes with
# others.
#
# The session ID is the ET-Engine session ID.
#
class exports.Scenario extends Backbone.Model
  # Returns the URL to the scenario. Raises an error if the scenario ID or
  # scene ID are missing.
  #
  url: ->
    unless @id and @get('scene').id
      throw 'Cannot generate scenario URL when missing ID or scene ID'

    "/scenes/#{ @get('scene').id }/scenarios/#{ @id }"

  # Starts the scenario by fetching th ET-Engine session, then starting the
  # scene. The scene must already exist in the Scenes collection.
  #
  # callback - A function which will be run after the scenari has been set up.
  #            The callback will be provided with the scenario, scene, and
  #            session instances.
  #
  start: (callback) ->
    collections.scenes.get(@get('scene').id).start (err, scene, session) =>
      callback err, this, scene, session
