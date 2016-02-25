# Contains all logic for "linting the kanban board"-- all rules are implemented
# as classes under this module, and the main linter loop is made of module
# methods defined here
module Checkers
  class << self
    def checkers
      @_checkers ||= Dir['app/models/checkers/**/*'].map do |relative_path|
        name = File.basename(relative_path, '.*').camelize
        Checkers.const_get(name)
      end
    end

    def check_all!
      Hash[
        repos_to_check.map do |repo|
          [repo.repo, check!(repo)]
        end
      ]
    end

    def repos_to_check
      RepoCollection.new(RepoPaginator.new)
        .organization(ENV['DEFAULT_GITHUB_ORG'])
        .active
        .map { |repo| Repo.from_gh(repo) }
    end

    def check!(repo)
      Rails.cache.fetch(
        "check/#{repo.org}/#{repo.repo}",
        expires_in: 8.hours,
      ) do
        checkers.flat_map do |checker|
          instance = checker.new
          instance.run(repo) if instance.respond_to?(:run)
        end.compact
      end
    end

    def reset_cache_all
      repos_to_check.each do |repo|
        reset_cache_repo(repo)
      end
    end

    def reset_cache_repo(repo)
      Rails.cache.delete("check/#{repo.org}/#{repo.repo}")
    end
  end

  class Base
  end
end
