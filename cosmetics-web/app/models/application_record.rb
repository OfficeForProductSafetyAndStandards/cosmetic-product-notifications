ActiveRecord::Base.extend ActiveHash::Associations::ActiveRecordExtensions
class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end
