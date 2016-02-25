module Checkers
  # Warn about issues in QA for more than 1 day
  class AgingQa < ::Checkers::Aging
    def run(repo)
      aging_qa_in(repo)
        .map do |issue, days_in_progress|
          msg = <<-MSG.squish
            #{issue.number} has been in QA for
            #{days_in_progress.round} days
          MSG

          Violation.new(
            repo: repo,
            message: msg,
          )
        end
    end

    def aging_qa_in(repo)
      aging_in_tag(repo, 'qa')
    end
  end
end
