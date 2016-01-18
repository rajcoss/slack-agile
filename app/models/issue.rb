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

  def initialize(org:, repo:, number:)
    @org = org
    @repo = repo
    @number = number
  end

  def to_gh
    @_to_gh ||= Github.issues.get @org, @repo, @number
  end

  def label!(string)
    Github.issues.labels.add @org, @repo, @number, string
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

  def to_text
    "title: #{title}\n---\n#{body}"
  end
end
