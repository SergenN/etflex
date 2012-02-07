require 'spec_helper'

describe Scenario do
  it { should successfully_save }
  it { should successfully_save(:guest_scenario) }

  # ATTRIBUTES --------------------------------------------------------------

  it { should_not allow_mass_assignment_of(:user) }
  it { should_not allow_mass_assignment_of(:user_id) }
  it { should_not allow_mass_assignment_of(:guest_uid) }

  it { should_not allow_mass_assignment_of(:scene) }
  it { should_not allow_mass_assignment_of(:scene_id) }

  it { should_not allow_mass_assignment_of(:session_id) }
  it { should_not allow_mass_assignment_of(:score) }

  it { should allow_mass_assignment_of(:title) }
  it { should allow_mass_assignment_of(:input_values) }
  it { should allow_mass_assignment_of(:query_results) }

  # RELATIONS ----------------------------------------------------------------

  it { should belong_to(:user) }
  it { should belong_to(:scene) }

  it { should validate_presence_of(:scene_id) }
  it { should validate_presence_of(:session_id) }

  it {
    create :scenario
    should validate_uniqueness_of(:session_id) }

  # USERS --------------------------------------------------------------------

  describe 'user relations' do
    it 'should be valid when a guest UID is set' do
      scenario = Scenario.new { |s| s.guest_uid = 'abc' }
      scenario.should have(:no).errors_on(:user_id)
    end

    it 'should be valid when a user ID is set' do
      scenario = Scenario.new { |s| s.user_id = 1 }
      scenario.should have(:no).errors_on(:user_id)
    end

    it 'should not be valid when no user ID or guest UID are set' do
      scenario = Scenario.new
      scenario.errors_on(:user_id).should \
        include("can't be blank when no guest UID is set")
    end
  end

  # CAN CHANGE? --------------------------------------------------------------

  describe 'can_change?' do
    context "with a user's scenario" do
      subject { create(:scenario) }

      it 'should be changeable by the owner' do
        subject.can_change?(subject.user).should be_true
      end

      it 'should not be changeable by another user' do
        subject.can_change?(create :user).should be_false
      end

      it 'should not be changeable by a new user' do
        subject.can_change?(User.new).should be_false
      end

      it 'should not be changeable by a guest' do
        subject.can_change?(Guest.new('abc')).should be_false
      end

      it 'should not be changeable by an exploiting guest' do
        subject.can_change?(Guest.new(subject.user.id)).should be_false
      end
    end

    context "with a guest's scenario" do
      subject { create(:guest_scenario) }
      let(:guest) { Guest.new(subject.guest_uid) }

      it 'should be changeable by the owner' do
        subject.can_change?(guest).should be_true
      end

      it 'should not be changeable by another guest' do
        subject.can_change?(Guest.new('def')).should be_false
      end

      it 'should not be changeable by a user' do
        subject.can_change?(create :user).should be_false
      end

      it 'should not be changeable by a new user' do
        subject.can_change?(User.new).should be_false
      end
    end

    context 'with a new scenario' do
      subject { Scenario.new }

      it 'should be changeable by a user' do
        subject.can_change?(create :user).should be_true
      end

      it 'should be changeable by a guest' do
        subject.can_change?(Guest.new('abc')).should be_true
      end
    end
  end

  # FOR USER -----------------------------------------------------------------

  describe '#for_user' do
    let(:user)     { create :user }
    let(:scene)    { create :scene }
    let(:scenario) { create :scenario, user: user, scene: scene }
    before         { scenario }

    context 'when given a User' do
      it "should return the user's scenarios" do
        scenarios = Scenario.for_user(user)
        scenarios.should have(1).member
        scenarios.first.should eql(scenario)
      end
    end

    context 'when given a Guest' do
      it "should return the guest's scenarios" do
        scenario.user_id = nil
        scenario.guest_uid = 'abcdef'
        scenario.save!

        scenarios = Scenario.for_user(Guest.new('abcdef'))
        scenarios.should have(1).member
        scenarios.first.should eql(scenario)
      end
    end

    context 'when given something else' do
      it 'should raise an error' do
        expect { Scenario.for_user(1) }.to raise_error
      end
    end
  end

  # FOR USER -----------------------------------------------------------------

  describe '#for_users_other_than' do
    let(:user)  { create :user }
    let(:guest) { Guest.new('abcdef') }
    let(:scene) { create :scene }

    let(:scenario)       { create :scenario,
                             user: user, scene: scene }

    let(:user_scenario)  { create :scenario,
                             user: create(:user), scene: scene }

    let(:guest_scenario) { create :scenario,
                             user: nil, scene: scene, guest_uid: 'zxy' }

    before { scenario ; user_scenario ; guest_scenario }

    context 'when there exists another guest scenario and user scenario' do
      context 'when given a User' do
        it 'should return one scenario' do
          Scenario.for_users_other_than(user).should have(2).members
        end

        it 'should return a scenario belonging to another person' do
          scenarios = Scenario.for_users_other_than(user)

          scenarios.should_not include(scenario)
          scenarios.should     include(user_scenario)
          scenarios.should     include(guest_scenario)
        end
      end

      context 'when given a Guest' do
        let(:guest) { Guest.new('abcdef') }

        before do
          scenario.user_id   = nil
          scenario.guest_uid = guest.uid
          scenario.save!
        end

        it 'should return one scenario' do
          Scenario.for_users_other_than(guest).should have(2).members
        end

        it 'should return a scenario belonging to another person' do
          scenarios = Scenario.for_users_other_than(guest)

          scenarios.should_not include(scenario)
          scenarios.should     include(user_scenario)
          scenarios.should     include(guest_scenario)
        end
      end

      context 'when given something else' do
        it 'should raise an error' do
          expect { Scenario.for_user(1) }.to raise_error
        end
      end
    end
  end

  # SERIALIZE ATTRIBUTES -----------------------------------------------------

  describe '#input_values=' do
    it 'should set an empty hash when given nil' do
      scenario = Scenario.new input_values: nil
      scenario.input_values.should eql(Hash.new)
    end

    it 'should set an empty hash when given an empty hash' do
      scenario = Scenario.new input_values: {}
      scenario.input_values.should eql(Hash.new)
    end

    it 'should convert a hash-like value to a Hash' do
      scenario = Scenario.new input_values: {}.with_indifferent_access

      scenario.input_values.class.should eql(Hash)
      scenario.input_values.class.should_not \
        eql(ActiveSupport::HashWithIndifferentAccess)
    end

    it 'should set convert keys to integers when given a hash' do
      scenario = Scenario.new input_values: { '1' => '2' }
      scenario.input_values.should eql(1 => '2')
    end
  end

  describe '#query_results=' do
    it 'should set an empty hash when given nil' do
      scenario = Scenario.new query_results: nil
      scenario.query_results.should eql(Hash.new)
    end

    it 'should set an empty hash when given an empty hash' do
      scenario = Scenario.new query_results: {}
      scenario.query_results.should eql(Hash.new)
    end

    it 'should convert a hash-like value to a Hash' do
      scenario = Scenario.new query_results: {}.with_indifferent_access

      scenario.query_results.class.should eql(Hash)
      scenario.query_results.class.should_not \
        eql(ActiveSupport::HashWithIndifferentAccess)
    end

    it 'should set a hash' do
      scenario = Scenario.new query_results: { '1' => '2' }
      scenario.query_results.should eql('1' => '2')
    end

    it 'should also set a score when present' do
      scenario = Scenario.new query_results: { 'score' => 1337 }
      scenario.score.should eql(1337.0)
    end

    it 'should unset the score when not present' do
      scenario = Scenario.new { |s| s.score = 42.0 }

      expect { scenario.attributes = { query_results: {} } }.to \
        change { scenario.score }.from(42.0).to(nil)
    end
  end

end
