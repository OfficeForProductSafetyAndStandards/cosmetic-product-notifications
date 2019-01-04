class Component < ApplicationRecord
    belongs_to :notification
    has_many :cmr_materials
    has_many :nanomaterials
    has_many :exact_formulas
    has_many :range_formulas
    has_one :formula_files
    has_many :trigger_rule_answers
end
