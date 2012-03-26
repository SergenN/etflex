class ScenariosController < ApplicationController
  include ETFlex::ClientController
  helper  ScenesHelper

  # HELPERS ------------------------------------------------------------------

  #######
  private
  #######

  def new_scenario
    Scenario.new do |scenario|
      scenario.scene      = Scene.find(params[:scene_id])
      scenario.session_id = params[:id]

      if user_signed_in?
        scenario.user = current_user
      else
        scenario.guest_uid = guest_user.id
      end
    end
  end

  def scenario_attrs
    attrs = params[:scenario] || Hash.new

    { title:         attrs[:title],
      input_values:  attrs[:inputValues],
      query_results: attrs[:queryResults],
      end_year:      attrs[:endYear],
      country:       attrs[:country],
      guest_name:    attrs[:guestName] }
  end

  # Sends notification to Pusher that a user did something.
  #
  # event    - The event type: "created" or "updated" depending on whether the
  #            user modified their existing scenario, or started a new one.
  #
  # scenario - The scenario in question.
  #
  def scenario_pusher(event, scenario)
    pusher "scenario.#{ event }", scenario.to_pusher_event
  end

  # ACTIONS ------------------------------------------------------------------

  ######
  public
  ######

  # JSON-only action which returns a list of high-scoring scenarios which have
  # been updated within the previous :days.
  #
  # GET /scenarios/since/:days
  #
  def since
    if params[:days].match(/\A\d+\Z/)
      @scenarios = Scenario.since(params[:days].to_i.days.ago)
    else
      return head :bad_request
    end

    # We need to select twice as many scenarios as are actually displayed; if
    # a scenario currently in the top five is demoted, we need the next
    # highest so that it can be promoted in the UI. So, twice as many allows
    # all of the top five to be demoted without the UI crapping out.
    #
    # In the real world, (number_shown) + 2 should be enough...
    #
    @scenarios = @scenarios.by_score.limit(20).map(&:to_pusher_event)

    respond_with @scenarios
  end

  # Shows the JSON for a given scene, with extra information about the
  # scenario embedded within so that they client loads a specific ET-Engine
  # session.
  #
  # GET /scenes/:scene_id/with/:id
  #
  def show
    @scenario   = Scenario.for_session *params.values_at(:scene_id, :id)
    @scenario ||= new_scenario

    respond_with @scenario
  end

  # Creates or updates a Scenario record.
  #
  # The client hits this action when it creates a new ET-Engine session so
  # that we may resume the users sessions later.
  #
  # PUT /scenes/:scene_id/with/:id
  #
  def update
    @scenario   = Scenario.for_session *params.values_at(:scene_id, :id)
    @scenario ||= new_scenario

    return head :forbidden unless @scenario.can_change?(current_or_guest_user)

    event = if @scenario.new_record? then 'created' else 'updated' end

    @scenario.attributes = scenario_attrs if params[:scenario].present?
    @scenario.save

    respond_with @scenario, location: scene_scenario_url

    # Send information about the update to connected clients.
    scenario_pusher event, @scenario
  end

end # ScenariosController
