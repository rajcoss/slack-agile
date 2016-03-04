Poker::Application.configure do
  next if Rails.env.development?
  config.lograge.enabled = true

  config.lograge.ignore_actions = ['GithubWebhooksController#create']
end
