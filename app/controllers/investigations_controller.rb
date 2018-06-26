class InvestigationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_investigation, only: %i[show edit update destroy close reopen assign update_assignee]

  # GET /investigations
  # GET /investigations.json
  def index
    @investigations = Investigation.paginate(page: params[:page], per_page: 20)
  end

  # GET /investigations/1
  # GET /investigations/1.json
  def show; end

  # GET /investigations/new
  def new
    @investigation = Investigation.new
  end

  # GET /investigations/1/edit
  def edit
    authorize @investigation
  end

  # POST /investigations/1/close
  def close
    @investigation.is_closed = true
    save_and_respond "Investigation was successfully closed."
  end

  # POST /investigations/1/reopen
  def reopen
    authorize @investigation
    @investigation.is_closed = false
    save_and_respond "Investigation was successfully reopened."
  end

  # GET /investigations/1/assign
  def assign
    authorize @investigation
    @assignee = @investigation.assignee
  end

  # POST /investigations/1/update_assignee
  def update_assignee
    authorize @investigation, :assign?
    assignee = User.where("lower(email) = ?", params[:email].downcase).first
    if assignee.nil?
      redirect_to assign_investigation_path(@investigation), alert: "Assignee does not exist."
    else
      @investigation.assignee = assignee
      save_and_respond "Assignee was successfully updated."
    end
  end

  # POST /investigations
  # POST /investigations.json
  def create
    @investigation = Investigation.new(investigation_params)

    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @investigation, notice: "Investigation was successfully created." }
        format.json { render :show, status: :created, location: @investigation }
      else
        format.html { render :new }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /investigations/1
  # PATCH/PUT /investigations/1.json
  def update
    authorize @investigation
    respond_to do |format|
      if @investigation.update(investigation_params)
        format.html { redirect_to @investigation, notice: "Investigation was successfully updated." }
        format.json { render :show, status: :ok, location: @investigation }
      else
        format.html { render :edit }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /investigations/1
  # DELETE /investigations/1.json
  def destroy
    authorize @investigation
    @investigation.destroy
    respond_to do |format|
      format.html { redirect_to investigations_url, notice: "Investigation was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private

  def save_and_respond(notice)
    respond_to do |format|
      if @investigation.save
        format.html { redirect_to @investigation, notice: notice }
        format.json { render :show, status: :ok, location: @investigation }
      else
        format.html { render :show }
        format.json { render json: @investigation.errors, status: :unprocessable_entity }
      end
    end
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_investigation
    @investigation = Investigation.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def investigation_params
    params.require(:investigation).permit(
      :description, :source, :severity,
      investigation_products_attributes: %i[id product_id _destroy]
    )
  end
end
