class PubliclyAccessibleController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :has_accepted_declaration
  skip_before_action :create_or_join_responsible_person
end
