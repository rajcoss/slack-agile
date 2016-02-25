# Handle webhooks from github and use them to invalidate the check cache
class GithubWebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token
  include GithubWebhook::Processor

  GITHUB_EVENTS_WHITELIST.each do |event|
    define_method "github_#{event}" do |payload|
      name = payload['repository']['name']
      org = payload['repository']['owner']['login']
      repo = Repo.new(org: org, repo: name)

      Checkers.reset_cache_repo(repo)
      Thread.new do
        Checkers.check!(repo)
      end
    end
  end

  def webhook_secret(_payload)
    ENV['GITHUB_WEBHOOK_SECRET']
  end
end
