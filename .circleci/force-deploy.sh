#!/bin/bash
SITE_UUID="f02adb1c-96a8-4aa0-990c-a1bd189465e5"
SITE_NAME="mosquito"
MULTIDEV="auto-update"

# enable git mode on dev
terminus connection:set $SITE_UUID.dev git

# merge the multidev back to dev
terminus multidev:merge-to-dev $SITE_UUID.$MULTIDEV 

# deploy to test
terminus env:deploy $SITE_UUID.test --sync-content --cc --note="Auto deploy of wordpress updates"

# backup the live site
	echo -e "\nBacking up the live environment for $SITE_NAME..."
	terminus backup:create $SITE_UUID.live --element=all --keep-for=30

# deploy to live
terminus env:deploy $SITE_UUID.live --cc --note="Auto deploy of wordpress updates"
#!/bin/bash
SLACK_MESSAGE="Forced deploy passed for $SITE_NAME! *Updates deployed to production.*"
SLACK_CHANNEL="pantheon-mass-updates"
SLACK_USERNAME="DevTeam"
SLACK_HOOK_URL="https://hooks.slack.com/services/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"
# Post the report back to Slack
echo -e "\nSending a message to the $SLACK_CHANNEL Slack channel"
curl -X POST --data-urlencode "payload={'channel': '${SLACK_CHANNEL}', 'username': '${SLACK_USERNAME}', 'text': '${SLACK_MESSAGE}'}" $SLACK_HOOK_URL