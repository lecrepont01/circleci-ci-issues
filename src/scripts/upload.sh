#!/bin/bash

set -x

if [[ $REPO_URL =~ ^https:\/\/github\.com\/([a-zA-Z0-9._-]+)\/([a-zA-Z0-9._-]+)$ ]]; then
  REPO_FULL_NAME=${BASH_REMATCH[1]}/${BASH_REMATCH[2]}
else
  echo "Invalid repository URL: $REPO_URL"
  exit 1
fi

# TODO: support multiple files
curl -X POST \
  -H "Authorization: bearer ${!TOKEN}" \
  -F name=${CIRCLE_JOB} \
  -F provider=circleci \
  -F head_sha=${CIRCLE_SHA1} \
  -F files=@${FILES} \
  -o result.json \
  ${MERGIFY_API_SERVER}/repos/${REPO_FULL_NAME}/ci_issues_upload \

GIGID=$(cat result.json | jq -r .gigid)
echo "::notice title=CI Issues report::CI_ISSUE_GIGID=$GIGID"
echo "CI_ISSUE_GIGID=$GIGID" >> "$GITHUB_OUTPUT"
