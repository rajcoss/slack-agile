# Returns the list of issues for a repo, handling pagination for you
class IssuePaginator < Paginator
  include Enumerable

  def initialize(org:, repo:)
    @org = org
    @repo = repo
    super() do |i|
      Github.issues.list(user: @org, repo: @repo, page: i).body
    end
  end
end
