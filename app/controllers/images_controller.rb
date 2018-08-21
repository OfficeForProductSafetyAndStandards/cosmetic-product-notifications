class ImagesController < ApplicationController
  before_action :set_investigation
  before_action :set_image, only: [:show, :edit, :update, :destroy]
  before_action :create_image, only: %i[create]
  before_action :update_image, only: %i[update]


  # GET /images
  # GET /images.json
  def index
    @images = @investigation.images
  end

  # GET /images/1
  # GET /images/1.json
  def show
  end

  # GET /images/new
  def new
  end

  # GET /images/1/edit
  def edit
  end

  # POST /images
  # POST /images.json
  def create
    respond_to do |format|
      if @image
        format.html { redirect_to action: 'index', notice: 'Image was successfully added.' }
        format.json { render :show, status: :created, location: @image }
      else
        format.html { render :new }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /images/1
  # PATCH/PUT /images/1.json
  def update
    respond_to do |format|
      if @image.blob.save
        format.html { redirect_to action: 'index', notice: 'Image was successfully updated.' }
        format.json { render :show, status: :ok, location: @image }
      else
        format.html { render :edit }
        format.json { render json: @image.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /images/1
  # DELETE /images/1.json
  def destroy
    @image.purge
    respond_to do |format|
      format.html { redirect_to action: 'index', notice: 'Image was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_investigation
    @investigation = Investigation.find(params[:investigation_id])
  end

  def set_image
    if @investigation.present?
      @image = @investigation.images.find(params[:id])
    end
  end

  def create_image
    image = ActiveStorage::Blob.create_after_upload! \
            io: image_params[:file].open,
            filename: image_params[:file].original_filename,
            content_type: image_params[:file].content_type,
            metadata: { title: image_params[:title] }

    @images = @investigation.images.attach(image)
    @image = @images.last
  end

  def update_image
    @image.blob.metadata.update(image_params)
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def image_params
    params.require(:image).permit(:title, :file)
  end
end
