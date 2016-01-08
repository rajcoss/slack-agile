# Represents a game of planning poker against one issue. It can be in the
# following statuses:
# - open: Ready for estimates to be entered/not yet revealed
# - revealed: Estimates have been announced in the channel
# - decided: A final point value was assigned by the decide command
# - closed: We quit before deciding a value.
class Round < ActiveRecord::Base
  has_many :estimates, dependent: :destroy

  validates :issue, :channel, presence: true
  validates :issue, format: {
    with: Issue::ISSUE_PATTERN,
    message: 'must be formatted like "repo_name/123"',
  }
  validates :value,
            inclusion: {
              in: Estimate::VALID_VALUES,
              message: 'points must be 1, 2, 3, 5, 8, or 13',
            },
            if: :value

  scope :open_for_channel, (lambda do |channel|
    order('created_at DESC').where(value: nil, channel: channel)
  end)

  def self.latest_open_for_channel(channel)
    open_for_channel(channel).first
  end

  def self.close_existing_for_channel(channel)
    open_for_channel(channel).update_all(closed: true)
  end

  def close!
    update!(closed: true)
    self
  end

  def to_slack_response
    Jbuilder.new do |json|
      json.response_type response_type
      json.text response_text
    end.attributes!
  end

  def response_type
    if valid?
      'in_channel'
    else
      'ephemeral'
    end
  end

  def response_text
    if valid?
      text_for_status
    else
      errors.full_messages.to_sentence
    end
  end

  def text_for_status
    if closed
      "Quit planning poker for #{issue}."
    elsif value.present?
      "Complexity of #{issue} is #{value}."
    elsif revealed
      "Estimates for #{issue}: #{estimate_text}"
    else
      "Planning poker for #{issue}.\n---\n#{to_issue.to_text}"
    end
  end

  def estimate_text
    estimates.order('value ASC').map(&:to_text).to_sentence
  end

  def to_issue
    Issue.from_name(issue)
  end
end
