# Represents one GitHub repo
class Repo
  attr_accessor :org, :repo

  def self.from_gh(gh)
    new(org: gh['owner']['login'], repo: gh.name)
  end

  def initialize(org:, repo:)
    @org = org
    @repo = repo
  end

  def issues
    issues_and_pulls.true_issues
  end

  delegate :pulls, to: :issues_and_pulls

  def issues_and_pulls
    @_issues_and_pulls ||=
      IssueCollection.new(
        IssuePaginator.new(org: @org, repo: @repo).to_a.flat_map do |gh|
          Issue.from_gh(org: @org, repo: @repo, gh: gh)
        end,
      )
  end

  def labels
    @_labels ||= issues.flat_map(&:labels).map(&:downcase).uniq
  end

  def inspect
    @repo
  end
end
