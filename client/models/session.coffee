# The base URL used for all session requests.
BASE_URL = 'http://api.et-model.com/api/v2/api_scenarios'

# Send with the request as X-Api-Agent so that ETengine devs know where
# requests are coming from.
X_API_AGENT = 'ETflex Client'

# A function which returns a fully-qualified session API URL.
scenarioUrl = (path) -> "#{BASE_URL}/#{path}.json?callback=?&"

# Represents the user's session with ETengine; keeps track of their unique
# session ID, scenario country, end date, etc.
#
# Create a new session by calling `createSession()` instead of `new Session`
# since `createSession` will fetch the session ID from the server.
#
class Session extends Backbone.Model
  constructor: (attributes, options) ->
    super
      id:         attributes.id
      country:    attributes.country
      endYear:    attributes.end_year
      region:     attributes.region
      useFCE:     attributes.use_fce
      userValues: attributes.user_values or {}
    , options

  # Sends an API request updating the given `inputs` with their values.
  #
  # `updateInputs` doesn't check that the Inputs are dirty; it is assumed that
  # you already know that their values need to be pushed to the server.
  #
  # inputs   - An array of inputs whose values are to be sent to ETengine.
  #
  # queries  - An array of Query instances whose values should be refreshed
  #            when the inputs values are sent to the server. This argument
  #            may be omitted. Note that Query `change` events will fire
  #            before the `callback`.
  #
  #            You may instead provide a Backbone.Collection containing the
  #            queries to be updated.
  #
  # callback - A callback to the run after the XHR request has completed. The
  #            first parameter will be null unless an error occurred (in which
  #            case it will be an exception object). The updated Query
  #            instances will be provided to the callback in an array.
  #
  # Example (with a Query collection)
  #
  #   session.updateInputs inputs, queries, (err) ->
  #     console.log err if err?
  #
  # Example (without a Query collection)
  #
  #   session.updateInputs inputs, (err) ->
  #     console.log err if err?
  #
  updateInputs: (inputs, queries, callback) ->
    params = input: {}

    # queries may be a Backbone.Collection...
    queries = queries.models if queries? and not _.isArray queries

    # Simple update without wanting any new Query results.
    callback = queries if not callback? and _.isFunction queries

    # Map the inputs IDs and values.
    params.input[input.get('id')] = input.get('value') for input in inputs

    # If there were any queries, tell ETengine to also give us those results.
    params.result = ( query.get('id') for query in queries ) if queries?

    jQuery.ajax
      url:         scenarioUrl this.get('id')
      data:        params
      type:        'GET'
      dataType:    'json'
      accepts:     'json'
      contentType: 'json'
      headers:   { 'X-Api-Agent': X_API_AGENT }

    .done (data, textStatus, jqXHR) ->
      # ETengine currently returns a 200 OK even when an input is invalid;
      # work around this by forming our own error and running the callback
      # as a failure:
      if data.errors?.length isnt 0
        callback _.extend(new Error('API Error'), errors: data.errors)

      else
        # TODO Perhaps also update the Inputs with the values returned by
        #      ETengine in case it wasn't happy with something?

        # Update the queries with the new values returned by the engine.
        if data.result?
          for query in queries when result = data.result[ query.get 'id' ]
            query.set present: result[0][1], future: result[1][1]

        callback null, queries if callback

    .fail (jqXHR, textStatus, error) ->
      callback error if callback

  # Given an inputs collection, sets the value of each input to those given
  # when the session was first retrieved from ETengine.
  #
  # Used as part of the bootstrap process.
  #
  finalizeInputs: (collection) ->
    values = @get 'userValues'
    valueFrom = (data) -> data? and (data.user_value or data.start_value)

    collection.each (input) ->
      if value = valueFrom values[ input.get('id') ]
        input.set { value: value }, silent: true

  # Removes the user session by simply unsetting the cookie.
  #
  destroy: ->
    jQuery.cookie 'eteSid', null
    @trigger 'destroy'

# Exports --------------------------------------------------------------------

# Creates a new instance of Session.
#
# If an existing ETengine session ID is present in a cookie, the session will
# be initialized with the existing user values, otherwise a new sessioin is
# created.
#
# callback - A function which is run once the new Session has been created and
#            initialized. It will be provided with two arguments - the first
#            is an error object, and will be null if the API request was
#            successful. The second argument will be the Session object.
#
exports.initSession = (callback) ->
  if sessionId = jQuery.cookie 'eteSid'
    restoreSession sessionId, callback
  else
    createSession callback

# Helpers --------------------------------------------------------------------

# Sends a request to ETengine.
#
# TODO I feel this might be better encapsulated in an APIRequest object.
#
sendRequest = (path, callback) ->
  jQuery.ajax
    url:         scenarioUrl path
    type:        'GET'
    dataType:    'json'
    accepts:     'json'
    contentType: 'json'
    headers:   { 'X-Api-Agent':  X_API_AGENT }

  .done (data, textStatus, jqXHR) ->
    callback null, data

  .error (jqXHR, textStatus, error) ->
    callback error

# Hits ETengine to fetch basic information about a session (country, etc).
#
# sessionId - The ID of the session being fetched from ETengine.
# callback  - Is run with the error or retrieved session data.
#
fetchSession = (sessionId, callback) ->
  sendRequest "#{sessionId}", (err, result) ->
    if err? then callback(err) else
      # New sessions return the API information in "api_scenario" while
      # existing sessions return it in "settings".
      callback null, result.api_scenario or result.settings

# Hits user_values.json to get the state of the user's Inputs.
#
# sessionId - The ID of the ETengine session whose values are to be retrieved.
# callback  - Is called with the parsed values.
#
fetchUserValues = (sessionId, callback) ->
  sendRequest "#{sessionId}/user_values", callback

# Used to create a new Session instance, pre-initialized with values from
# ETengine. Use this in preference over `new Session` since creating a session
# explicitly will not actually create a session on ETengine.
#
# See `initSession`.
#
createSession = (callback) ->
  async.waterfall [
    # Create a new session.
    (cb) -> fetchSession 'new', cb

    # Fetch user_values.json to initialize sliders.
    (sessionValues, cb) ->
      fetchUserValues sessionValues.id, (err, userValues) ->
        cb null, sessionValues, userValues

  ], (err, sessionValues, userValues) ->
    # Store the session ID as a cookie so that we can restore on refresh.
    jQuery.cookie 'eteSid', "#{sessionValues.id}",
      expires: 1, path: '/'

    callback null, new Session _.extend sessionValues, user_values: userValues

# Restores the session state by retrieving it from ETengine.
#
# See `initSession`.
#
# sessionId - The ID of the ETengine session to be restored.
# callback  - Is called with the restored Session.
#
restoreSession = (sessionId, callback) ->
  # Currently we have to fetch both the session information and user values
  # separately; it would be just marvellous if we could do both in a single
  # request. ;-)
  #
  async.parallel
    # Fetches information about the session.
    session: (cb) -> fetchSession sessionId, cb
    # Fetches user_values.json
    values:  (cb) -> fetchUserValues sessionId, cb

  , (err, result) ->
    if err? then callback(err) else
      callback null, new Session _.extend result.session,
        id:          sessionId
        user_values: result.values
