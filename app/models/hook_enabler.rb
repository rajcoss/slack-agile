class HookEnabler
  HOOK_URL = 'https://revelry-poker.herokuapp.com/github_webhooks.json'

  def run
    Checkers.repos_to_check.flat_map do |repo|
      maybe_enable_hook_for(repo)
    end
  end

  def maybe_enable_hook_for(repo)
    return if has_hook_already?(repo)

    enable_hook_for(repo)
  end

  def enable_hook_for(repo)
    Github.repos.hooks.create(
      repo.org,
      repo.repo,
      {
        name: 'web',
        config: {
          url: HookEnabler::HOOK_URL,
          secret: ENV['GITHUB_WEBHOOK_SECRET'],
          content_type: 'json',
        },
        events: ['*'],
        active: true,
      },
    )
  end

  def has_hook_already?(repo)
    current_hooks_for(repo).any? { |hook| hook.config.url == HookEnabler::HOOK_URL }
  end

  def current_hooks_for(repo)
    Github.repos.hooks.list(repo.org, repo.repo)
  end
end
