ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../config/environment", __dir__)

# It's important that simplecov is "require"d early in the file
require 'simplecov'
require 'simplecov-console'
require 'shared/web/coveralls_formatter'
SimpleCov.formatters = [
  SimpleCov::Formatter::HTMLFormatter,
  SimpleCov::Formatter::Console,
  Shared::Web::CoverallsFormatter
]
SimpleCov.start

require "rails/test_help"
require "rspec/mocks/standalone"

class ActiveSupport::TestCase
  include ::RSpec::Mocks::ExampleMethods

  def initialize *args
    @keycloak_client_instance = Shared::Web::KeycloakClient.instance
    super(*args)
  end

  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Import all relevant models into Elasticsearch
  def self.import_into_elasticsearch
    unless @models_imported
      ActiveRecord::Base.descendants.each do |model|
        if model.respond_to?(:__elasticsearch__) && !model.superclass.respond_to?(:__elasticsearch__)
          model.import force: true, refresh: true
        end
      end
      @models_imported = true
    end
  end

  def setup
    self.class.import_into_elasticsearch
  end

  # On top of mocking out external services, this method also sets the user to an initial,
  # sensible value, but it should only be run once per test.
  # To change currently logged in user afterwards call `sign_in_as(...)`
  def mock_out_keycloak_and_notify(user_name: "User_one")
    @users = [admin_user,
              test_user(name: "User_one"),
              test_user(name: "User_two"),
              test_user(name: "User_three"),
              test_user(name: "Ts_user", ts_user: true)].map(&:attributes)
    @organisations = organisations.map(&:attributes)
    @teams = all_teams.map(&:attributes)
    @team_users = []

    allow(@keycloak_client_instance).to receive(:all_organisations) { @organisations }
    allow(@keycloak_client_instance).to receive(:all_teams) { @teams }
    allow(@keycloak_client_instance).to receive(:all_team_users) { @team_users }
    allow(@keycloak_client_instance).to receive(:all_users) { @users }
    stub_user_management
    Organisation.all
    Team.all
    TeamUser.all
    User.all
    set_default_group_memberships
    sign_in_as User.find_by(last_name: user_name)
    stub_notify_mailer
  end

  def sign_in_as(user)
    allow(@keycloak_client_instance).to receive(:user_signed_in?).and_return(true)
    allow(@keycloak_client_instance).to receive(:user_info).and_return(user.attributes)
    User.current = user
  end

  def reset_keycloak_and_notify_mocks
    allow(@keycloak_client_instance).to receive(:has_role?).and_call_original
    allow(@keycloak_client_instance).to receive(:user_signed_in?).and_call_original
    allow(@keycloak_client_instance).to receive(:user_info).and_call_original
    allow(@keycloak_client_instance).to receive(:all_users).and_call_original
    allow(@keycloak_client_instance).to receive(:all_organisations).and_call_original
    allow(@keycloak_client_instance).to receive(:all_teams).and_call_original
    allow(@keycloak_client_instance).to receive(:all_team_users).and_call_original
    Rails.cache.delete(:keycloak_users)
    restore_user_management

    allow(NotifyMailer).to receive(:alert).and_call_original
    allow(NotifyMailer).to receive(:investigation_updated).and_call_original
    allow(NotifyMailer).to receive(:investigation_created).and_call_original
    allow(NotifyMailer).to receive(:user_added_to_team).and_call_original
  end

  def stub_notify_mailer
    result = ""
    allow(result).to receive(:deliver_later)
    allow(NotifyMailer).to receive(:alert) { result }
    allow(NotifyMailer).to receive(:investigation_updated) { result }
    allow(NotifyMailer).to receive(:investigation_created) { result }
    allow(NotifyMailer).to receive(:user_added_to_team) { result }
  end

  def set_user_as_opss(user)
    user.organisation = Organisation.find(opss_organisation.id)
    # Keycloak bases this role on the group membership
    set_kc_user_group(user.id, opss_organisation.id)
    allow(@keycloak_client_instance).to receive(:has_role?).with(user.id, :opss_user).and_return(true)
  end

  def set_user_as_non_opss(user)
    user.organisation = Organisation.find(non_opss_organisation.id)
    # Keycloak bases this role on the group membership
    set_kc_user_group(user.id, non_opss_organisation.id)
    allow(@keycloak_client_instance).to receive(:has_role?).with(user.id, :opss_user).and_return(false)
  end

  def set_user_as_team_admin(user = User.current)
    allow(@keycloak_client_instance).to receive(:has_role?).with(user.id, :team_admin).and_return(true)
  end

  def set_user_as_not_team_admin(user = User.current)
    allow(@keycloak_client_instance).to receive(:has_role?).with(user.id, :team_admin).and_return(false)
  end

  def add_user_to_opss_team(user_id:, team_id:)
    set_user_as_opss User.find(user_id)
    add_user_to_team user_id, team_id
  end

  def assert_same_elements(expected, actual, msg = nil)
    full_message = message(msg, '') { diff(expected, actual) }
    condition = (expected.size == actual.size) && (expected - actual == [])
    assert(condition, full_message)
  end

private

  def admin_user
    id = SecureRandom.uuid
    allow(@keycloak_client_instance).to receive(:has_role?).with(id, :team_admin).and_return(false)
    allow(@keycloak_client_instance).to receive(:has_role?).with(id, :mspsds_user).and_return(true)
    allow(@keycloak_client_instance).to receive(:has_role?).with(id, :opss_user).and_return(true)
    User.new(id: id, email: "admin@example.com", first_name: "Test", last_name: "Admin")
  end

  def test_user(name: "User_one", ts_user: false)
    id = SecureRandom.uuid
    allow(@keycloak_client_instance).to receive(:has_role?).with(id, :team_admin).and_return(false)
    allow(@keycloak_client_instance).to receive(:has_role?).with(id, :mspsds_user).and_return(true)
    allow(@keycloak_client_instance).to receive(:has_role?).with(id, :opss_user).and_return(true) unless ts_user
    User.new(id: id, email: "#{name}@example.com", first_name: "Test", last_name: name)
  end

  def organisations
    [non_opss_organisation, opss_organisation]
  end

  def non_opss_organisation
    Organisation.new(id: "def4eef8-1a33-4322-8b8c-fc7fa95a2e3b", name: "Organisation 1", path: "/Organisations/Organisation 1")
  end

  def opss_organisation
    Organisation.new(id: "1a612aea-1d3d-47ee-8c3a-76b4448bb97b", name: "Office of Product Safety and Standards", path: "/Organisations/Organisation 2")
  end

  def set_default_group_memberships
    add_user_to_opss_team user_id: @users[0][:id], team_id: @teams[0][:id]
    add_user_to_opss_team user_id: @users[1][:id], team_id: @teams[0][:id]
    add_user_to_opss_team user_id: @users[1][:id], team_id: @teams[1][:id]
    add_user_to_opss_team user_id: @users[2][:id], team_id: @teams[1][:id]
    add_user_to_opss_team user_id: @users[3][:id], team_id: @teams[2][:id]
    add_user_to_opss_team user_id: @users[3][:id], team_id: @teams[3][:id]
    set_user_as_non_opss User.find(@users[4][:id])
  end

  def add_user_to_team(user_id, team_id)
    tu = TeamUser.add user_id: user_id, team_id: team_id
    @team_users.push tu.attributes
    set_kc_user_group(user_id, team_id)
  end

  def set_kc_user_group(user_id, group_id)
    mock_user = @users.find { |u| u[:id] == user_id }
    mock_user[:groups] ||= []
    mock_user[:groups].push group_id
  end

  def all_teams
    [
      Team.new(id: "aaaaeef8-1a33-4322-8b8c-fc7fa95a2e3b", name: "Team 1", path: "/Organisations/Office of Product Safety and Standards/Team 1", organisation_id: "1a612aea-1d3d-47ee-8c3a-76b4448bb97b"),
      Team.new(id: "aaaxzcf8-1a33-4322-8b8c-fc7fa95a2e3b", name: "Team 2", path: "/Organisations/Office of Product Safety and Standards/Team 2", organisation_id: "1a612aea-1d3d-47ee-8c3a-76b4448bb97b"),
      Team.new(id: "bbbbeef8-1a33-4322-8b8c-fc7fa95a2e3b", name: "Team 3", path: "/Organisations/Office of Product Safety and Standards/Team 3", organisation_id: "1a612aea-1d3d-47ee-8c3a-76b4448bb97b"),
      Team.new(id: "cccceef8-1a33-4322-8b8c-fc7fa95a2e3b", name: "Team 4", path: "/Organisations/Office of Product Safety and Standards/Team 4", organisation_id: "1a612aea-1d3d-47ee-8c3a-76b4448bb97b", team_recipient_email: "team@example.com")
    ]
  end

  def format_user_for_get_users(users)
    users.map { |user| { id: user[:id], email: user[:email], firstName: user[:first_name], lastName: user[:last_name] } }.to_json
  end

  def stub_user_management
    allow(@keycloak_client_instance).to receive(:add_user_to_team), &method(:add_user_to_team)
    allow(@keycloak_client_instance).to receive(:create_user) do |email|
      @users.push id: SecureRandom.uuid, email: email, username: email
    end
    allow(@keycloak_client_instance).to receive(:send_required_actions_welcome_email).and_return(true)
  end

  def restore_user_management
    allow(@keycloak_client_instance).to receive(:add_user_to_team).and_call_original
    allow(@keycloak_client_instance).to receive(:create_user).and_call_original
    allow(@keycloak_client_instance).to receive(:send_required_actions_welcome_email).and_call_original
  end
end
