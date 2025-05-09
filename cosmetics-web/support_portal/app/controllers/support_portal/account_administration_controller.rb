module SupportPortal
  class AccountAdministrationController < ApplicationController
    before_action :set_user, except: %i[index search search_results invite_search_user create_search_user]
    before_action :set_responsible_persons, only: %i[show edit_responsible_persons]
    before_action :set_responsible_person, only: %i[delete_responsible_person_user_confirm delete_responsible_person_user]
    before_action :reenforce_secondary_authentication, only: %i[reset_account deactivate_account]

    # GET /
    def index; end

    # GET /search
    def search; end

    # GET /search-results
    def search_results
      @search_query = params[:q].presence

      users = if @search_query
                ::User.where("name ILIKE ?", "%#{@search_query}%").or(::User.where("email ILIKE ?", "%#{@search_query}%"))
                     .where(type: %w[SubmitUser SearchUser]).select(:id, :name, :email, :type).order(name: :asc).order(created_at: :desc)
              else
                ::User.where(type: %w[SubmitUser SearchUser]).select(:id, :name, :email, :type).order(name: :asc).order(created_at: :desc)
              end

      @records_count = users.size
      @pagy, @records = pagy(users)
    end

    # GET /:id
    def show; end

    # GET /:id/edit-name
    def edit_name; end

    # PATCH/PUT /:id/update-name
    def update_name
      existing_name = @user.name

      return redirect_to account_administration_path if existing_name == params[user_type_param(@user)][:name]

      if @user.update(update_name_params(@user))
        redirect_to account_administration_path, notice: "The name has been updated from #{existing_name} to #{params[user_type_param(@user)][:name]}"
      else
        render :edit_name
      end
    end

    # GET /:id/edit-email
    def edit_email; end

    # PATCH/PUT /:id/update-email
    def update_email
      existing_email = @user.email

      return redirect_to account_administration_path if existing_email == params[user_type_param(@user)][:email]

      if @user.update(update_email_params(@user))
        redirect_to account_administration_path, notice: "The email address has been updated from #{existing_email} to #{params[user_type_param(@user)][:email]}"
      else
        render :edit_email
      end
    end

    # GET /:id/reset-account
    def reset_account; end

    # DELETE /:id/reset
    def reset
      if @user.reset_secondary_authentication!
        redirect_to account_administration_path(@user, q: params[:q]), notice: "The account has been reset"
      else
        redirect_to reset_account_path(@user, q: params[:q]), notice: "The account failed to reset"
      end
    end

    # GET /:id/deactivate-account
    def deactivate_account
      redirect_to account_administration_path unless @user.is_a?(::SearchUser) && !@user.deactivated?
    end

    # PATCH/PUT /:id/deactivate
    def deactivate
      return redirect_to account_administration_path unless @user.is_a?(::SearchUser) && !@user.deactivated?

      if @user.update(deactivated_at: Time.zone.now)
        redirect_to account_administration_path, notice: "The account has been deactivated"
      else
        render :deactivate_account
      end
    end

    # PATCH/PUT /:id/reactivate
    def reactivate
      return redirect_to account_administration_path unless @user.is_a?(::SearchUser) && @user.deactivated?

      if @user.update(deactivated_at: nil) && @user.reset_secondary_authentication!(reactivated: true)
        redirect_to account_administration_path, notice: "The account has been reactivated<br>An email was sent to #{@user.email} to inform #{@user.name}."
      else
        redirect_to account_administration_path
      end
    end

    # GET /:id/edit-role
    def edit_role; end

    # PATCH/PUT /:id/update-role
    def update_role
      existing_roles = @user.roles.map(&:name)

      new_role = params[:search_user][:role]
      return redirect_to account_administration_path if existing_roles.include?(new_role)

      @user.roles.clear
      @user.add_role(new_role)

      if @user.save
        redirect_to account_administration_path, notice: "The account role type has been updated from #{helpers.role_type(existing_roles.first)} to #{helpers.role_type(new_role)}"
      else
        render :edit_role
      end
    end

    # GET /:id/edit-responsible-persons
    def edit_responsible_persons; end

    # GET /:id/delete-responsible-person-user/:responsible_person_user_id/confirm
    def delete_responsible_person_user_confirm
      @allow_removal = @responsible_person.responsible_person_users.count > 1
    end

    # DELETE /:id/delete-responsible-person-user/:responsible_person_user_id
    def delete_responsible_person_user
      @user.responsible_person_users.find(params[:responsible_person_user_id]).destroy
      ::SupportNotifyMailer.removed_from_responsible_person_email(@user, @responsible_person.name).deliver_later
      redirect_to edit_responsible_persons_account_administration_path(@user, q: params[:q]), notice: "#{@user.name} has been removed from #{@responsible_person.name}"
    end

    # GET /invite-search-user
    def invite_search_user
      @user = ::SearchUser.new
    end

    # PATCH/PUT /create-search-user
    def create_search_user
      @user = ::SearchUser.new(invite_search_user_params.merge(skip_password_validation: true))

      if params[:search_user][:role].present?
        @user.add_role(params[:search_user][:role])
      end

      if @user.valid?
        # Pass the role to the service if it needs it:
        ::InviteSearchUser.call(invite_search_user_params.merge(role: params[:search_user][:role]))
        redirect_to invite_search_user_account_administration_index_path, notice: "New search user account invitation sent"
      else
        render :invite_search_user
      end
    end

  private

    def set_user
      @user = ::User.where(id: params[:id], type: %w[SearchUser SubmitUser]).first!
    end

    def set_responsible_persons
      return unless @user.is_a?(::SubmitUser)

      @responsible_persons = @user.responsible_persons
                                  .select("responsible_persons.id AS id", "responsible_persons.name AS name", "responsible_person_users.id AS responsible_person_user_id")
                                  .order(name: :asc)
    end

    def set_responsible_person
      @responsible_person = @user.responsible_persons.where(responsible_person_users: { id: params[:responsible_person_user_id] })
                                                     .select("responsible_persons.id AS id", "responsible_persons.name AS name", "responsible_person_users.id AS responsible_person_user_id")
                                                     .first!
    end

    def user_type_param(user)
      case user
      when ::SubmitUser
        :submit_user
      when ::SearchUser
        :search_user
      end
    end

    def update_name_params(user)
      params.require(user_type_param(user)).permit(:name)
    end

    def update_email_params(user)
      params.require(user_type_param(user)).permit(:email)
    end

    # No longer permitting role here
    def invite_search_user_params
      params.require(:search_user).permit(:name, :email)
    end
  end
end
