# An error in processing a command such that we can't return a model.
# E.g. this can happen if we reference the current round but there is none.
class CommandError
  def initialize(text, ephemeral: true)
    @text = text
    @ephemeral = ephemeral
  end

  def to_slack_response
    Jbuilder.new do |json|
      json.response_type response_type
      json.text @text
    end.attributes!
  end

  def response_type
    if @ephemeral
      'ephemeral'
    else
      'in_channel'
    end
  end
end
