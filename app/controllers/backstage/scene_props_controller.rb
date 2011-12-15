module Backstage
  class ScenePropsController < BackstageController

    # FILTERS ----------------------------------------------------------------

    #######
    private
    #######

    before_filter :fetch_scene
    before_filter :fetch_input, :except => [ :index, :new, :create ]

    # Retrieves the scene identified in the params.
    #
    def fetch_scene
      @scene = Scene.find(params[:scene_id])
    end

    # Retrieves the scene prop identified in the params.
    #
    def fetch_prop
      @prop = @scene.scene_props.find(params[:id])
    end

    # ACTIONS ----------------------------------------------------------------

    ######
    public
    ######

    # Shows a list of all props used by the scene.
    #
    # GET /backstage/scenes/:scene_id/props
    #
    def index
      @props = @scene.scene_props.includes(:prop)
    end

  end # BackstagePropsController
end # Backstage