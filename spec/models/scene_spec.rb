require 'spec_helper'

describe Scene do
  it { should successfully_save }

  it { should allow_mass_assignment_of(:name) }
  it { should allow_mass_assignment_of(:name_key) }
  it { should allow_mass_assignment_of(:score_gquery) }

  it { should_not allow_mass_assignment_of(:scene_props) }
  it { should_not allow_mass_assignment_of(:props) }

  it { should_not allow_mass_assignment_of(:scene_inputs) }
  it { should_not allow_mass_assignment_of(:left_scene_inputs) }
  it { should_not allow_mass_assignment_of(:right_scene_inputs) }
  it { should_not allow_mass_assignment_of(:hidden_scene_inputs) }

  it { should_not allow_mass_assignment_of(:inputs) }
  it { should_not allow_mass_assignment_of(:left_inputs) }
  it { should_not allow_mass_assignment_of(:right_inputs) }
  it { should_not allow_mass_assignment_of(:hidden_inputs) }

  it { should_not allow_mass_assignment_of(:scenarios) }

  # RELATIONS ----------------------------------------------------------------

  it { should have_many(:scene_props) }
  it { should have_many(:scenarios) }

  # NAME ---------------------------------------------------------------------

  describe 'name' do
    it 'should not be blank' do
      subject.errors_on(:name).should include("can't be blank")
    end

    it 'should be no longer than 100 characters' do
      subject.name = ( 'x' * 101 )
      subject.errors_on(:name).should include(
        "is too long (maximum is 100 characters)")
    end
  end # name

  describe 'name_key' do
    it 'should not be blank' do
      subject.errors_on(:name_key).should include("can't be blank")
    end

    it 'should be no longer than 100 characters' do
      subject.name_key = ( 'x' * 101 )
      subject.errors_on(:name_key).should include(
        "is too long (maximum is 100 characters)"
      )
    end

    it 'should be formatted as a slug' do
      subject.name_key = 'my first scene'
      subject.errors_on(:name_key).should include(
        "is invalid"
      )
    end
  end

  describe 'score_gquery' do
    it 'should not be blank' do
      subject.errors_on(:score_gquery).should include("can't be blank")
    end

    it 'should be formatted as a variable' do
      subject.score_gquery = 'The ETFlex Score!'
      subject.errors_on(:score_gquery).should include(
        "is invalid"
      )
    end
  end
end
