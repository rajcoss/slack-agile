# README

## App boot

```
bundle
bundle exec rails s
```

## Slack config

Check out these instructions: https://api.slack.com/slash-commands

You need to set up a "custom integration" starting here:
https://revelrylabs.slack.com/apps/build/custom-integration

Configuration:

1. You need your token to be set as ENV['SLACK_TOKEN'].
2. The main slack route sits at /poker in the app, so configure that URL as the
   POST URL in Slack.

## Usage

Type `/poker` in the connected slack for usage instructions.
