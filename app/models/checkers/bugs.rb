module Checkers
  # Warn about any issues in the bug backlog
  class Bugs < Base
    def run(repo)
      repo.issues.labeled('bug').map do |issue|
        Violation.new(
          repo: repo,
          message: "Bug issue: #{issue.title}",
        )
      end
    end
  end
end
