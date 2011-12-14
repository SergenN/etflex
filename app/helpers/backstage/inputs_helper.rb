module Backstage::InputsHelper

  # Returns the name for the input, as it should appear in the table which
  # lists all inputs. When no I18n name is defined, a lighter version of the
  # input key will be used instead.
  #
  # input - The Input instance whose name is being shown.
  #
  def input_name_for_list(input)
    fallback = %(<span class="missing-name">#{ h input.key }</span>).html_safe
    t("inputs.#{ input.key }.name", default: fallback)
  end

  # Returns the name of the input, suitable for use in the header of input
  # pages. Shows the I18n name if one is set, and the key.
  #
  # input - The input instance whose name is to be returned.
  #
  def input_name_for_title(input)
    # User may have changed the key in a form; perhaps even to a blank value.
    # Prefer to show the original key over the new one in the title.
    key = input.key_was or input.key

    translated = t("inputs.#{ key }.name", default: '')

    if translated.blank? then key else
      %(#{ h translated }
        <span class='quiet'>#{ h key}</span>
      ).html_safe
    end
  end

  # Returns a link to the edit form for an input. Correctly handles both Input
  # and SceneInputs, which is more than can be said for Rails' built-in
  # *_polymorphic_path.
  #
  def poly_backstage_input_path(input, action = nil)
    # backstage_input_path, or backstage_scene_input_path
    route_name = "backstage_#{ input.class.name.underscore }_path"

    # Prefixes "edit", "custom action", etc...
    route_name = "#{ action }_#{ route_name }" if action.present?

    # SceneInput routes require a Scene.
    scene = if input.respond_to?(:scene) then input.scene end

    # Generate the URL. Scene will be set when routing
    __send__(route_name, *[ scene, input ].compact)
  end

end
