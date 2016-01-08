fail('GITHUB_USERNAME is missing') unless ENV['GITHUB_USERNAME']
fail('GITHUB_TOKEN is missing') unless ENV['GITHUB_TOKEN']

Github.configure do |c|
  c.basic_auth = "#{ ENV['GITHUB_USERNAME'] }:#{ ENV['GITHUB_TOKEN'] }"
end
