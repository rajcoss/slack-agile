# Represents one lint message
class Violation
  attr_accessor :org, :repo, :message

  def initialize(repo:, message:)
    @org = org
    @repo = repo
    @message = message
  end
end
