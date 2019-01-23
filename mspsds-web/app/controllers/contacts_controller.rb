class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show edit update remove destroy]
  before_action :create_contact, only: %i[create]
  # GET /contacts
  # GET /contacts.json

  # GET /contacts/1
  # GET /contacts/1.json
  def show
    @business = @contact.business
  end

  # GET /contacts/new
  def new
    @business = Business.find(params[:business_id])
    @contact = @business.contacts.build
  end

  # GET /contacts/1/edit
  def edit
    @business = @contact.business
  end

  # POST /contacts
  # POST /contacts.json
  def create
    respond_to do |format|
      if @contact.save
        format.html do
          redirect_to business_url(@contact.business, anchor: "contacts"),
                      notice: "Contact was successfully created."
        end
        format.json { render :show, status: :created, contact: @contact }
      else
        format.html { render :new }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /contacts/1
  # PATCH/PUT /contacts/1.json
  def update
    # authorize @contact
    respond_to do |format|
      if @contact.update(contact_params)
        format.html do
          redirect_to business_url(@contact.business, anchor: "contacts"),
                      notice: "Contact was successfully updated."
        end
        format.json { render :show, status: :ok, contact: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove
    @business = @location.business
  end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html do
        redirect_to business_url(@contact.business, anchor: "contacts"),
                    notice: "contact was successfully deleted."
      end
      format.json { head :no_content }
    end
  end

private

  def create_contact
    business = Business.find(params[:business_id])
    @contact = business.contacts.create(contact_params)
    @contact.source = UserSource.new(user: current_user)
  end

    # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @contact = Contact.find(params[:id])
  end

    # Never trust parameters from the scary internet, only allow the white list through.
  def contact_params
    params.require(:contact).permit(:business_id, :name, :email, :phone_number, :description)
  end
end
