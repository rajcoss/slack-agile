class IssuePaginator
  include Enumerable

  def initialize(org:, repo:)
    @org = org
    @repo = repo
  end

  def each
    i = 1
    loop do
      results = Github.issues.list(user: @org, repo: @repo, page: i).body
      yield results
      i += 1
      break if results.length == 0
    end
  end
end
