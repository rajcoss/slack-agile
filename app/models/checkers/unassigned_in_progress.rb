module Checkers
  class UnassignedInProgress
    def run(repo)
      unassigned_ip = repo.issues.labeled('in progress').unassigned
      return [] if unassigned_ip.count == 0

      Violation.new(
        repo: repo,
        message: "#{unassigned_ip.count} unassigned issues in progress.",
      )
    end
  end
end
