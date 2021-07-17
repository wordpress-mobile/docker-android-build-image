#!/bin/bash

function prepare_to_publish_to_s3_params() {
    PARAMS=(--sha1=$BUILDKITE_COMMIT)
    [[ -n "$BUILDKITE_TAG" ]] && PARAMS+=(--tag-name=$BUILDKITE_TAG)
    [[ -n "$BUILDKITE_BRANCH" ]] && PARAMS+=(--branch-name=$BUILDKITE_BRANCH)
    [[ -n "$BUILDKITE_PULL_REQUEST" ]] && PARAMS+=(--pull-request-number=$BUILDKITE_PULL_REQUEST)
    echo "$PARAMS"
}
