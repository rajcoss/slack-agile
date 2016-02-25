module Checkers
  # Warn about any issues in progress without points values
  class InProgressWithoutPoints < Base
    def run(repo)
      hits =
        repo
        .issues
        .labeled(['sprint backlog', 'bug', 'in progress', 'in review'])
        .without_points
      return [] unless hits.any?

      Violation.new(
        repo: repo,
        message: "#{hits.count} unscored items in backlog/progress/review",
      )
    end
  end
end
