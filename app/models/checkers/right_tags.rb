module Checkers
  # Check that the repo has the right tags in place
  class RightTags < Base
    REQUIRED_TAGS = [
      'sprint backlog',
      'bug',
      'in progress',
      'in review',
      'qa',
    ]

    def run(repo)
      REQUIRED_TAGS
        .reject { |tag| repo.labels.include?(tag) }
        .map do |missing_tag|
          Violation.new(
            repo: repo,
            message: "#{missing_tag} label is missing.",
          )
        end
    end
  end
end
