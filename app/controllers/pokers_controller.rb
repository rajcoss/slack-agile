# Main webhook controller for slack. Takes the slash command and processes it,
# returning the expected response. Most of the magic happens in Command
class PokersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def create
    command = Command.new(params)
    render json: command.to_slack_response
  end
end
