module Checkers
  class InProgressWithoutPoints
    def run(repo)
      hits = repo.issues.labeled(['in progress', 'in review']).without_points
      return [] unless hits.any?

      Violation.new(
        repo: repo,
        message: "#{hits.count} in progress/review items without points",
      )
    end
  end
end
