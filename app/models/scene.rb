class Scene < ActiveRecord::Base

  # RELATIONSHIPS ------------------------------------------------------------

  with_options class_name: 'SceneInput', order: 'position ASC' do |opts|
    opts.has_many :scene_inputs
    opts.has_many :left_scene_inputs,  conditions: { left: true  }
    opts.has_many :right_scene_inputs, conditions: { left: false }
  end

  with_options class_name: 'Input', source: :input, readonly: true do |opts|
    opts.has_many :inputs,       through: :scene_inputs
    opts.has_many :left_inputs,  through: :left_scene_inputs
    opts.has_many :right_inputs, through: :right_scene_inputs
  end

  has_many :scene_props
  has_many :props, through: :scene_props, readonly: true

  # VALIDATION ---------------------------------------------------------------

  validates :name, presence: true, length: { maximum: 100 }

end
