#!/usr/bin/env bash

set -x
set -e
set -u

export NEW_VERSION="${1}"
export BRANCH_NAME="release-v${NEW_VERSION}"
export GITHUB_ACTION_PATH="${2}"
export RELEASE_BODY="$(awk -v version="${NEW_VERSION}" -f ${GITHUB_ACTION_PATH}/scripts/show-changelog.awk CHANGELOG.md)"

git config user.name github-actions
git config user.email github-actions@github.com

node "${GITHUB_ACTION_PATH}/scripts/update-package-version.js"

git checkout -b "${BRANCH_NAME}"

if ! (git add . && git commit -m "${NEW_VERSION}");
then
    echo "Error: No changes detected."
    exit 1
fi

hub pull-request \
    --draft \
    --message "${NEW_VERSION} RC" --message "${RELEASE_BODY}" \
    --base "main" \
    --head "${BRANCH_NAME}";
