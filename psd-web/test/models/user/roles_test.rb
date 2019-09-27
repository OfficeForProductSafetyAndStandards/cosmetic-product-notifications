require "test_helper"

class UserRolesTest < ActiveSupport::TestCase
  setup do
    @user = User.new()
  end

  def stub_roles(roles)
    allow(@user).to receive(:roles) { roles }
  end

  class Roles < UserRolesTest
    setup do
      roles = JSON.generate([
        {
          "name" => "opss_user",
          "test" => "test"
        }
      ])

      allow(@keycloak_client_instance).to receive(:get_client_user_roles) { roles }
    end

    teardown do
      allow(@keycloak_client_instance).to receive(:get_client_user_roles).and_call_original
    end

    test "#roles retrieves the user's roles from Keycloak and caches them" do
      3.times { @user.roles }
      expect(@keycloak_client_instance).to have_received(:get_client_user_roles).once
    end

    test "#roles returns the user's roles" do
      assert_equal([:opss_user], @user.roles)
    end
  end

  class IsTeamAdmin < UserRolesTest
    test "#is_team_admin? returns false when the user's roles don't contain it" do
      stub_roles([:opss_user])
      refute(@user.is_team_admin?)
    end

    test "#is_team_admin? returns true when the user's roles contains it" do
      stub_roles([:team_admin])
      assert(@user.is_team_admin?)
    end
  end

  class IsOpss < UserRolesTest
    test "#is_opss? returns false when the user's roles don't contain it" do
      stub_roles([:team_admin])
      refute(@user.is_opss?)
    end

    test "#is_opss? returns true when the user's roles contains it" do
      stub_roles([:opss_user])
      assert(@user.is_opss?)
    end
  end

  class IsPsdAdmin < UserRolesTest
    test "#is_psd_admin? returns false when the user's roles don't contain it" do
      stub_roles([:team_admin])
      refute(@user.is_psd_admin?)
    end

    test "#is_psd_admin? returns true when the user's roles contains it" do
      stub_roles([:psd_admin])
      assert(@user.is_psd_admin?)
    end
  end

  class IsPsdUser < UserRolesTest
    test "#is_psd_user? returns false when the user's roles don't contain it" do
      stub_roles([:team_admin])
      refute(@user.is_psd_user?)
    end

    test "#is_psd_user? returns true when the user's roles contains it" do
      stub_roles([:psd_user])
      assert(@user.is_psd_user?)
    end
  end
end
