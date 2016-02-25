module Checkers
  # Warn when a user has multiple issues in progress
  class OneInProgress < Base
    def run(repo)
      assignee_counts(repo)
        .select { |_assignee, count| count > 1 }
        .map do |assignee, count|
          Violation.new(
            repo: repo,
            message: "#{assignee} has #{count} issues in progress.",
          )
        end
    end

    def assignee_counts(repo)
      repo
        .issues
        .labeled('in progress')
        .by_assignee.each_with_object({}) do |(assignee, list), memo|
          memo[assignee] = list.count
        end
    end
  end
end
