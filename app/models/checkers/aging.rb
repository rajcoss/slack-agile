module Checkers
  # Base class for rules which check whether an issue has been in a column for
  # more than 1 day
  class Aging < Base
    def aging_in_tag(repo, tag)
      Hash[
        repo
          .issues
          .labeled(tag)
          .select { |issue| issue.when_labeled(tag).present? }
          .map do |issue|
            [
              issue,
              (Time.zone.now - issue.when_labeled(tag)) / 1.day,
            ]
          end
          .select do |(_issue, days_in_progress)|
            days_in_progress > 1
          end
      ]
    end
  end
end
