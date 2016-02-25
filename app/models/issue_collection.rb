# A collection of GitHub issues with chainable filters
class IssueCollection < ChainableCollection
  def labeled(x)
    return wrap(x.flat_map { |label| labeled(label) }) if x.respond_to?(:map)

    wrap(@inner.select do |issue|
      issue.labels.include?(x.downcase)
    end)
  end

  def labeled_like(x)
    wrap(@inner.select do |issue|
      issue.labels.any? { |label| x.match(label) }
    end)
  end

  def true_issues
    wrap(@inner.select(&:true_issue?))
  end

  def pulls
    wrap(@inner.select(&:pull?))
  end

  def unassigned
    wrap(@inner.select { |issue| issue.assignee.nil? })
  end

  def with_points
    labeled_like(/points:[0-9]+/)
  end

  def without_points
    self.not.with_points
  end

  def by_assignee
    groups = group_by { |issue| issue.assignee.try(:login) }
    groups.each_with_object(groups) do |(key, list), memo|
      memo[key] = wrap(list)
    end
  end
end
