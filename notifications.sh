#!/bin/bash
# Code from https://github.com/DiscordHooks/gitlab-ci-discord-webhook

# Get and set variables
TIMESTAMP=$(date --utc +%FT%TZ)
AUTHOR_NAME="$(git log -1 "$CI_COMMIT_SHA" --pretty="%aN")"
COMMITTER_NAME="$(git log -1 "$CI_COMMIT_SHA" --pretty="%cN")"
COMMIT_SUBJECT="$(git log -1 "$CI_COMMIT_SHA" --pretty="%s")"
COMMIT_MESSAGE="$(git log -1 "$CI_COMMIT_SHA" --pretty="%b")" | sed -E ':a;N;$!ba;s/\r{0,1}\n/\\n/g'
ARTIFACT_URL="$CI_JOB_URL/artifacts/download"
JOB_STAGE=$1
JOB_STATUS=$2
WEBHOOK_URL=$3

# Set the message color based on the status we got
case $JOB_STATUS in
  "success" )
    EMBED_COLOR=3066993
    ;;
  "failure" )
    EMBED_COLOR=15158332
    ;;

  * )
    EMBED_COLOR=#808080
    JOB_STAGE="Unknown job status ..."
    ;;
esac

shift

# Check if we have the webhook URL set
if [ $# -lt 1 ]; then
  echo -e "WARNING!!\nYou need to pass the WEBHOOK_URL environment variable as the second argument to this script.\nFor details & guide, visit: https://github.com/DiscordHooks/gitlab-ci-discord-webhook" && exit
fi

# Check if author and committer are the same for readability
if [ "$AUTHOR_NAME" == "$COMMITTER_NAME" ]; then
  CREDITS="$AUTHOR_NAME authored & committed"
else
  CREDITS="$AUTHOR_NAME authored & $COMMITTER_NAME committed"
fi

# If merge request, include link
if [ -z $CI_MERGE_REQUEST_ID ]; then
  URL=""
else
  URL="$CI_PROJECT_URL/merge_requests/$CI_MERGE_REQUEST_ID"
fi

# Create JSON payload that contains the message data
if [ -z $LINK_ARTIFACT ] || [ $LINK_ARTIFACT = false ] ; then
  WEBHOOK_DATA='{
    "avatar_url": "https://gitlab.com/favicon.png",
    "embeds": [ {
      "color": '$EMBED_COLOR',
      "author": {
        "name": "Pipeline #'"$CI_PIPELINE_IID"' status update",
        "url": "'"$CI_PIPELINE_URL"'",
        "icon_url": "https://gitlab.com/favicon.png"
      },
      "title": "'"$COMMIT_SUBJECT"'",
      "url": "'"$URL"'",
      "description": "'"${COMMIT_MESSAGE//$'\n'/ }"\\n\\n"$CREDITS"'",
      "fields": [
        {
          "name": "Commit",
          "value": "'"[\`$CI_COMMIT_SHORT_SHA\`]($CI_PROJECT_URL/commit/$CI_COMMIT_SHA)"'",
          "inline": true
        },
        {
          "name": "Branch",
          "value": "'"[\`$CI_COMMIT_REF_NAME\`]($CI_PROJECT_URL/tree/$CI_COMMIT_REF_NAME)"'",
          "inline": true
        },
        {
          "name": "Job",
          "value": "'"[\`$JOB_STAGE\`]($CI_JOB_URL)"' : '"$JOB_STATUS"'"
        }
        ],
        "timestamp": "'"$TIMESTAMP"'"
      } ]
    }'
else
	WEBHOOK_DATA='{
		"avatar_url": "https://gitlab.com/favicon.png",
		"embeds": [ {
			"color": '$EMBED_COLOR',
			"author": {
			"name": "Pipeline #'"$CI_PIPELINE_IID"' status update",
			"url": "'"$CI_PIPELINE_URL"'",
			"icon_url": "https://gitlab.com/favicon.png"
			},
			"title": "'"$COMMIT_SUBJECT"'",
			"url": "'"$URL"'",
			"description": "'"${COMMIT_MESSAGE//$'\n'/ }"\\n\\n"$CREDITS"'",
			"fields": [
			{
				"name": "Commit",
				"value": "'"[\`$CI_COMMIT_SHORT_SHA\`]($CI_PROJECT_URL/commit/$CI_COMMIT_SHA)"'",
				"inline": true
			},
			{
				"name": "Branch",
				"value": "'"[\`$CI_COMMIT_REF_NAME\`]($CI_PROJECT_URL/tree/$CI_COMMIT_REF_NAME)"'",
				"inline": true
			},
			{
				"name": "Artifacts",
				"value": "'"[\`$CI_JOB_ID\`]($ARTIFACT_URL)"'",
				"inline": true
			},
      {
          "name": "Job",
          "value": "'"[\`$JOB_STAGE\`]($CI_JOB_URL)"' : '"$JOB_STATUS"'"
      }
			],
			"timestamp": "'"$TIMESTAMP"'"
		} ]
	}'
fi

(curl --fail --progress-bar -A "GitLabCI-Webhook" -H Content-Type:application/json -d "$WEBHOOK_DATA" "$WEBHOOK_URL" \
&& echo -e "\\n[Webhook]: Successfully sent the webhook.") || echo -e "\\n[Webhook]: Unable to send webhook."
