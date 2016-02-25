# Represents one issue in github
class Issue
  # i.e. dingus/123 or foobar/dingus/123
  ISSUE_PATTERN = %r{
    (
      (?<org>[^/]+)/(?<repo>[^/]+)
      |
      (?<repo>[^/]+)
    )
    /
    (?<number>[0-9]+)
  }x

  def self.from_name(name)
    new(**parameters_from_name(name))
  end

  def self.parameters_from_name(name)
    match_data = Issue::ISSUE_PATTERN.match(name)
    {
      org: match_data[:org] || ENV['DEFAULT_GITHUB_ORG'],
      repo: match_data[:repo],
      number: match_data[:number],
    }
  end

  def self.from_gh(org:, repo:, gh:)
    new(org: org, repo: repo, number: gh['number']).tap do |issue|
      issue.instance_variable_set(:@_to_gh, gh)
    end
  end

  attr_accessor :org, :repo, :number

  def initialize(org:, repo:, number:)
    @org = org
    @repo = repo
    @number = number
  end

  def to_gh
    @_to_gh ||= Github.issues.get @org, @repo, @number
  end

  def labels
    @_labels ||= to_gh['labels'].map { |label| label.name.downcase }
  end

  def label!(string)
    Github.issues.labels.add @org, @repo, @number, string
    labels.append(string).uniq!
  end

  def unlabel!(&block)
    fail('Block is required for unlabel') unless block_given?
    to_gh.labels.map(&:name)
    .select do |label_name|
      yield label_name
    end
    .each do |label_name|
      Github.issues.labels.remove @org, @repo, @number, label_name: label_name
    end
  end

  delegate :title, to: :to_gh

  def body
    to_gh.body.body
  end

  def pull?
    to_gh['pull_request'].present?
  end

  def true_issue?
    !pull?
  end

  def when_labeled(x)
    return unless if events.labeled(x).any?
    Time.zone.parse(events.labeled(x).first['created_at'])
  end

  def events
    @_events ||=
      EventCollection.new(
        EventPaginator.new(
          org: @org,
          repo: @repo,
          issue_number: @number,
        ),
      )
      .reverse_chronological
  end

  def to_text
    "title: #{title}\n---\n#{body}"
  end

  def method_missing(name, *args, &block)
    return to_gh[name] if args.length == 0 && !block_given? && to_gh.key?(name)
    super
  end
end
