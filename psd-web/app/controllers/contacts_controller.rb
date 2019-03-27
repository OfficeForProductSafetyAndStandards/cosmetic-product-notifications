class ContactsController < ApplicationController
  before_action :set_contact, only: %i[edit update remove destroy]
  before_action :create_contact, only: %i[create]
  before_action :assign_business, only: %i[edit remove]

  # GET /contacts/new
  def new
    @business = Business.find(params[:business_id])
    @contact = @business.contacts.build
  end

  # GET /contacts/1/edit
  def edit; end

  # POST /contacts
  # POST /contacts.json
  def create
    respond_to do |format|
      if @contact.save
        format.html do
          redirect_to business_url(@contact.business, anchor: "contacts"),
                      flash: { success: "Contact was successfully created." }
        end
        format.json { render :show, status: :created, location: @contact }
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
                      flash: { success: "Contact was successfully updated." }
        end
        format.json { render :show, status: :ok, contact: @contact }
      else
        format.html { render :edit }
        format.json { render json: @contact.errors, status: :unprocessable_entity }
      end
    end
  end

  def remove; end

  # DELETE /contacts/1
  # DELETE /contacts/1.json
  def destroy
    @contact.destroy
    respond_to do |format|
      format.html do
        redirect_to business_url(@contact.business, anchor: "contacts"),
                    flash: { success: "Contact was successfully deleted." }
      end
      format.json { head :no_content }
    end
  end

private

  def assign_business
    @business = @contact.business
  end

  def create_contact
    business = Business.find(params[:business_id])
    @contact = business.contacts.create(contact_params)
    @contact.source = UserSource.new(user: User.current)
  end

    # Use callbacks to share common setup or constraints between actions.
  def set_contact
    @contact = Contact.find(params[:id])
  end

    # Never trust parameters from the scary internet, only allow the white list through.
  def contact_params
    params.require(:contact).permit(:business_id, :name, :email, :phone_number, :job_title)
  end
end
