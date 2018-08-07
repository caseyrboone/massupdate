#!/bin/bash
MULTIDEV="auto-update"

#Provide the target site name (e.g. your-awesome-site)
echo 'Provide the site name (e.g. your-awesome-site), then press [ENTER] to reset the Dev environment to Live:'
read SITE_NAME

#Provide the target site UUID (26ea87c4-3460-40fe-aa02-b23eb264d682)
echo 'Provide the site UUID (e.g. 26ea87c4-3460-40fe-aa02-b23eb264d682), then press [ENTER]'
read SITE_UUID

# enable git mode on dev
echo "committing any files that are staged"
terminus env:commit $SITE_UUID.dev --message="Forced commit for mass updates"
echo "enabling git"
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

SLACK_MESSAGE="Forced deploy passed for $SITE_NAME! *Updates deployed to production.*"
SLACK_CHANNEL="pantheon-mass-updates"
SLACK_USERNAME="DevTeam"
SLACK_HOOK_URL="https://hooks.slack.com/services/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"
# Post the report back to Slack
echo -e "\nSending a message to the $SLACK_CHANNEL Slack channel"
curl -X POST --data-urlencode "payload={'channel': '${SLACK_CHANNEL}', 'username': '${SLACK_USERNAME}', 'text': '${SLACK_MESSAGE}'}" $SLACK_HOOK_URL

