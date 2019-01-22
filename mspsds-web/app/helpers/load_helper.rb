module LoadHelper
  def preload_manually(records, associations)
    ActiveRecord::Associations::Preloader.new.preload(records, associations)
  end
end
