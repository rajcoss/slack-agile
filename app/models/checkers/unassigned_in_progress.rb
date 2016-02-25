module Checkers
  # Warns if an issue is marked in progress but is not assigned (because it is
  # made when you software is being made by ~~ SPOOKY GHOSTS ~~)
  class UnassignedInProgress < Base
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
