module Backstage::InputsHelper

  # Returns the name for the input, as it should appear in the table which
  # lists all inputs. When no I18n name is defined, a lighter version of the
  # input key will be used instead.
  #
  # input - The Input instance whose name is being shown.
  #
  def input_name_for_list(input)
    fallback = %(<span class="missing-name">#{ h input.key }</span>).html_safe
    t("inputs.#{ input.key }", default: fallback)
  end

  # Returns the name of the input, suitable for use in the header of input
  # pages. Shows the I18n name if one is set, and the key.
  #
  # input - The input instance whose name is to be returned.
  #
  def input_name_for_title(input)
    if input.new_record? and input.key.blank?
      translated = t('inputs.new')
    else
      translated = t("inputs.#{ input.key }", default: '')
    end

    if translated.blank? then input.key else translated end
  end

  # Returns a link to the list of inputs, based on the given argument.
  #
  # If a @scene ivar is set, the path returned will be to the list of scene
  # inputs, otherwise the path will be to the main inputs list.
  #
  def poly_backstage_inputs_path
    if @scene
      backstage_scene_inputs_path @scene
    else
      backstage_inputs_path
    end
  end

  # Returns a link to the edit form for an input. Correctly handles both Input
  # and SceneInputs, which is more than can be said for Rails' built-in
  # *_polymorphic_path.
  #
  def poly_backstage_input_path(input = nil, action = nil)
    # backstage_input_path, or backstage_scene_input_path
    route_name = "backstage_#{ input.class.name.underscore }_path"

    # Prefixes "edit", "custom action", etc...
    route_name = "#{ action }_#{ route_name }" if action.present?

    # SceneInput routes require a Scene.
    scene = if input.respond_to?(:scene) then input.scene end

    # Generate the URL. Scene will be set when routing
    __send__(route_name, *[ scene, input ].compact)
  end

  # Creates the drop-down form element for setting the scene input location.
  #
  # form - The form builder object.
  #
  def scene_input_location_select(form)
    form.input :location,
      include_blank: 'Hidden',
      input_html: { class: 'small' },
      collection: [ %w( Left left ),
                    %w( Right right ) ]
  end

  # Creates the drop-down form element for selecting an input when adding a
  # new scene input.
  #
  # form - The form builder object.
  #
  def scene_input_input_select(form)
    inputs = Input.scoped.only(:id, :key).order('`key` ASC')
    form.association :input,
      collection: inputs,
      include_blank: false,
      input_html: { class: 'autocomplete' }
  end

end
