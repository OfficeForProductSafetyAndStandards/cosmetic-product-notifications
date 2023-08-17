module SupportPortal
  class ResponsiblePersonsController < ApplicationController
    before_action :set_responsible_person, except: %i[index search_results]
    before_action :set_assigned_contact, except: %i[index search_results edit_name update_name edit_address update_address edit_business_type update_business_type]

    # GET /
    def index; end

    # GET /search-results
    def search_results
      @search_query = params[:q].presence

      responsible_persons = if @search_query
                              ::ResponsiblePerson.left_joins(:contact_persons)
                                .where("responsible_persons.name ILIKE ?", "%#{@search_query}%")
                                .or(::ResponsiblePerson.left_joins(:contact_persons).where("contact_persons.name ILIKE ?", "%#{@search_query}%"))
                                .or(::ResponsiblePerson.left_joins(:contact_persons).where("contact_persons.email_address ILIKE ?", "%#{@search_query}%"))
                            else
                              ::ResponsiblePerson.left_joins(:contact_persons)
                            end

      responsible_persons = if params[:assigned_contact_sort_order].present?
                              responsible_persons.order("contact_persons.name": params[:assigned_contact_sort_order].to_sym)
                            else
                              responsible_persons.order(name: (params[:company_name_sort_order]&.to_sym || :asc))
                            end

      @records_count = responsible_persons.size
      @pagy, @records = pagy(responsible_persons)
    end

    # GET /:id
    def show; end

    # GET /:id/edit-name
    def edit_name; end

    # PATCH/PUT /:id/update-name
    def update_name
      existing_name = @responsible_person.name

      return redirect_to responsible_person_path(@responsible_person) if existing_name == params[:responsible_person][:name]

      if @responsible_person.update(update_name_params)
        redirect_to responsible_person_path(@responsible_person), notice: "The Responsible Person name has been updated from #{existing_name} to #{params[:responsible_person][:name]}"
      else
        render :edit_name
      end
    end

    # GET /:id/edit-address
    def edit_address; end

    # PATCH/PUT /:id/update-address
    def update_address
      existing_address = [
        @responsible_person.address_line_1,
        @responsible_person.address_line_2,
        @responsible_person.city,
        @responsible_person.county,
        @responsible_person.postal_code,
      ]

      new_address = [
        params[:responsible_person][:address_line_1],
        params[:responsible_person][:address_line_2],
        params[:responsible_person][:city],
        params[:responsible_person][:county],
        params[:responsible_person][:postal_code],
      ]

      return redirect_to responsible_person_path(@responsible_person) if existing_address == new_address

      if @responsible_person.update(update_address_params)
        existing_address_display = existing_address.reject(&:blank?).join(", ")
        new_address_display = new_address.reject(&:blank?).join(", ")
        redirect_to responsible_person_path(@responsible_person), notice: "The Responsible Person address has been updated from #{existing_address_display} to #{new_address_display}"
      else
        render :edit_address
      end
    end

    # GET /:id/edit-business-type
    def edit_business_type; end

    # PATCH/PUT /:id/update-business-type
    def update_business_type
      existing_business_type = @responsible_person.account_type

      return redirect_to responsible_person_path(@responsible_person) if existing_business_type == params[:responsible_person][:account_type]

      if @responsible_person.update(update_business_type_params)
        redirect_to responsible_person_path(@responsible_person), notice: "The Responsible Person business type has been updated from #{helpers.responsible_person_business_type(existing_business_type)} to #{helpers.responsible_person_business_type(params[:responsible_person][:account_type])}"
      else
        render :edit_business_type
      end
    end

    # GET /:id/edit-assigned-contact-name/:assigned_contact_id
    def edit_assigned_contact_name; end

    # PATCH/PUT /:id/update-assigned-contact-name/:assigned_contact_id
    def update_assigned_contact_name
      existing_name = @assigned_contact.name

      return redirect_to responsible_person_path(@responsible_person) if existing_name == params[:contact_person][:name]

      if @assigned_contact.update(update_assigned_contact_name_params)
        redirect_to responsible_person_path(@responsible_person), notice: "The assigned contact name has been updated from #{existing_name} to #{params[:contact_person][:name]}"
      else
        render :edit_assigned_contact_name
      end
    end

    # GET /:id/edit-assigned-contact-email/:assigned_contact_id
    def edit_assigned_contact_email; end

    # PATCH/PUT /:id/update-assigned-contact-email/:assigned_contact_id
    def update_assigned_contact_email
      existing_email = @assigned_contact.email_address

      return redirect_to responsible_person_path(@responsible_person) if existing_email == params[:contact_person][:email_address]

      if @assigned_contact.update(update_assigned_contact_email_params)
        redirect_to responsible_person_path(@responsible_person), notice: "The assigned contact email address has been updated from #{existing_email} to #{params[:contact_person][:email_address]}"
      else
        render :edit_assigned_contact_email
      end
    end

    # GET /:id/edit-assigned-contact-phone-number/:assigned_contact_id
    def edit_assigned_contact_phone_number; end

    # PATCH/PUT /:id/update-assigned-contact-phone-number/:assigned_contact_id
    def update_assigned_contact_phone_number
      existing_phone_number = @assigned_contact.phone_number

      return redirect_to responsible_person_path(@responsible_person) if existing_phone_number == params[:contact_person][:phone_number]

      if @assigned_contact.update(update_assigned_contact_phone_number_params)
        redirect_to responsible_person_path(@responsible_person), notice: "The assigned contact contact number has been updated from #{existing_phone_number} to #{params[:contact_person][:phone_number]}"
      else
        render :edit_assigned_contact_phone_number
      end
    end

  private

    def set_responsible_person
      @responsible_person = ::ResponsiblePerson.includes(:contact_persons)
        .where(id: params[:id])
        .select(:id, :name, :address_line_1, :address_line_2, :city, :county, :postal_code, :account_type)
        .first!
    end

    def set_assigned_contact
      @assigned_contact = @responsible_person.contact_persons.first
    end

    def update_name_params
      params.require(:responsible_person).permit(:name)
    end

    def update_address_params
      params.require(:responsible_person).permit(:address_line_1, :address_line_2, :city, :county, :postal_code)
    end

    def update_business_type_params
      params.require(:responsible_person).permit(:account_type)
    end

    def update_assigned_contact_name_params
      params.require(:contact_person).permit(:name)
    end

    def update_assigned_contact_email_params
      params.require(:contact_person).permit(:email_address)
    end

    def update_assigned_contact_phone_number_params
      params.require(:contact_person).permit(:phone_number)
    end
  end
end
