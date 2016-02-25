module Checkers
  # Warn about issues in progress more than 1 day
  class AgingInProgress < ::Checkers::Aging
    def run(repo)
      aging_in_progress_in(repo)
        .map do |issue, days_in_progress|
          msg = <<-MSG.squish
            #{issue.number} has been in progress for
            #{days_in_progress.round} days
          MSG

          Violation.new(
            repo: repo,
            message: msg,
          )
        end
    end

    def aging_in_progress_in(repo)
      aging_in_tag(repo, 'in progress')
    end
  end
end
