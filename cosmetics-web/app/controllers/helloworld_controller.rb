class HelloworldController < ApplicationController
  def index
    TestJob.perform_later
    puts 'Testing!'
  end
end
