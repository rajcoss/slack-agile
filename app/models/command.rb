# Takes a slack request formatted like so:
#   token=XYZ
#   team_id=T0001
#   team_domain=example
#   channel_id=C2147483705
#   channel_name=test
#   user_id=U2147483697
#   user_name=Steve
#   command=/weather
#   text=94070
#   response_url=https://hooks.slack.com/commands/1234/5678
# and processes it. This coordinates creating the right DB records and returning
# the right response. It mostly just delegates down to Round and Estimate after
# doing validation that this is a well formed command.
class Command
  VALID_VERBS = %w(
    start
    check
    estimate
    reveal
    decide
    quit
  )

  HELP_TEXT = <<-TXT

    Poker commands:

    /poker start [repo/123] -- _Start a new round of planning poker for issue
    123 of the repo repo_.

    /poker check -- _Remind yourself what round is being played._

    /poker estimate [1|2|3|5|8|13] -- _Provide your complexity points for the
    current issue_.

    /poker reveal -- _Reveal the estimates for the current issue_.

    /poker decide [1|2|3|5|8|13] -- _Finalize the points for the current issue._
  TXT

  include ActiveModel::Model

  attr_accessor :token, :team_id, :team_domain
  attr_accessor :channel_id, :channel_name
  attr_accessor :user_id, :user_name
  attr_accessor :command, :text
  attr_accessor :response_url

  validates :token, presence: true
  validates :verb, presence: { message: Command::HELP_TEXT }
  validates :verb, inclusion: {
    in: Command::VALID_VERBS,
    message: 'must be start, estimate, reveal, decide, or quit',
  }
  validate :valid_token

  def initialize(params)
    params.each do |key, value|
      instance_variable_set("@#{key}".to_sym, value)
    end
  end

  def to_slack_response
    if valid?
      process.to_slack_response
    else
      Jbuilder.new do |json|
        json.response_type 'ephemeral'
        json.text errors.full_messages.to_sentence
      end.attributes!
    end
  end

  # Call the right process_XYZ command for the current verb, returning the
  # created/updated model
  def process
    send("process_#{verb}")
  end

  def process_start
    Round.close_existing_for_channel(channel_name)
    Round.new(issue: argument, channel: channel_name).tap(&:save)
  end

  def process_check
    Round.latest_open_for_channel(channel_name) ||
      CommandError.new('Not currently playing', ephemeral: false)
  end

  def process_estimate
    Estimate.find_or_initialize_by(
      round: Round.latest_open_for_channel(channel_name),
      user: user_name,
    ).tap do |estimate|
      estimate.update(
        value: argument.to_i,
      )
    end
  end

  def process_reveal
    Round
      .latest_open_for_channel(channel_name)
      .tap { |round| round.update(revealed: true) }
  end

  def process_decide
    Round
      .latest_open_for_channel(channel_name)
      .tap { |round| round.update(value: argument) }
  end

  def process_quit
    Round.latest_open_for_channel(channel_name).close!
  end

  def verb
    (command_parts[0] || '').downcase
  end

  def argument
    command_parts[1] || ''
  end

  def channel_name
    return "#{@channel_name}:#{channel_id}" if @channel_name == 'privategroup'
    @channel_name
  end

  protected

  def command_parts
    text.split(' ')
  end

  def valid_token
    return if token == ENV['SLACK_TOKEN']
    errors.add(:token, 'does not match secret value')
  end
end
