class Document
  extend ActiveModel::Naming
  include ActiveModel::Validations

  attr_accessor :file_id, :integer
  attr_accessor :title, :string
  attr_accessor :description, :string

  validates :title, presence: true

  def initialize(file, required_fields=[:file_id])
    @file_id = file.id if file
    @title = file.metadata["title"] if file&.metadata
    @description = file.metadata["description"] if file&.metadata
  end

  def update(params)
    @title = params[:title]
    @description = params[:description]
  end
end
