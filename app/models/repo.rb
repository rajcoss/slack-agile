class Repo
  attr_accessor :org, :repo

  def initialize(org:, repo:)
    @org = org
    @repo = repo
  end

  def issues
    issues_and_pulls.true_issues
  end

  def pulls
    issues_and_pulls.pulls
  end

  def issues_and_pulls
    @_issues_and_pulls ||=
      IssueCollection.new(
        IssuePaginator.new(org: @org, repo: @repo).to_a.flat_map do |gh_objs|
          gh_objs.map do |gh|
            Issue.from_gh(org: @org, repo: @repo, gh: gh)
          end
        end
      )
  end

  def labels
    @_labels ||= issues.flat_map(&:labels).map(&:downcase).uniq
  end

  def inspect
    @repo
  end
end
