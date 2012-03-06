class PagesController < ApplicationController
  helper ScenesHelper

  # The root page.
  #
  # GET /
  #
  def root
    @scenes = Scene.limit(10)

    # We need to select twice as many scenarios as are actually displayed; if
    # a scenario currently in the top five is demoted, we need the next
    # highest so that it can be promoted in the UI. So, twice as many allows
    # all of the top five to be demoted without the UI crapping out.
    #
    # In the real world, (number_shown) + 2 should be enough...
    #
    @high_scenarios = Scenario.by_score.limit(10)
  end

  # A test page for Pusher.
  #
  # GET /pusher
  #
  def pusher
  end

end
