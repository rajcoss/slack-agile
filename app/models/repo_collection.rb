# A collection of Repos with chainable filters
class RepoCollection < ChainableCollection
  scope :organization do |x|
    @inner.select do |repo|
      repo['owner']['login'] == x
    end
  end

  scope :fork do
    @inner.select { |repo| repo['fork'] }
  end

  def repo_blacklist
    YAML.load_file(Rails.root.join('config/repo_ignore.yml').to_s)
  end

  scope :blacklisted do
    @inner.select { |repo| repo_blacklist.include?(repo.name) }
  end

  scope :active do
    self.not.fork.not.blacklisted
  end
end
