# Returns all events for a GitHub issues-- for example, labeling, unlabeling,
# closing, etc-- and handle pagination for you
class EventPaginator < Paginator
  include Enumerable

  def initialize(org:, repo:, issue_number:)
    @org = org
    @repo = repo
    @issue_number = issue_number
    super() do |i|
      Github.issues.events.list(
        @org,
        @repo,
        issue_number: @issue_number,
        page: i,
      )
    end
  end
end
