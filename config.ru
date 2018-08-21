# This file is used by Rack-based servers to start the application.

require_relative "config/environment"

# TODO MSPSDS_197: figure out how to move this to User model without
# build breaking (on db creation or docker-compose up)
User.import force: true

run Rails.application
