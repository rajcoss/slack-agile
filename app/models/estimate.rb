# Represents one estimate by a user during a round. Note that after a user has
# an estimate for a round, we'll try to update that estimate rather than create
# a new one (you can't have more than one estimate in planning poker).
class Estimate < ActiveRecord::Base
  VALID_VALUES = [1, 2, 3, 5, 8, 13]

  belongs_to :round

  validates :round, presence: true
  validates :value, inclusion: {
    in: Estimate::VALID_VALUES,
    message: 'points must be 1, 2, 3, 5, 8, or 13',
  }

  after_create do
    round.broadcast_who_has_estimated
  end

  def to_text
    "#{user}=#{value}"
  end

  def to_slack_response
    Jbuilder.new do |json|
      json.response_type 'ephemeral'
      json.text response_text
    end.attributes!
  end

  def response_text
    if valid?
      "Ok, your estimate for #{round.issue} is #{value}."
    else
      errors.full_messages.to_sentence
    end
  end
end
