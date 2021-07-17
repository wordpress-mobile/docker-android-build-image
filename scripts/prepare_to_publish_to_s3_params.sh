#!/bin/bash

function prepare_to_publish_to_s3_params() {
    PARAMS=(--sha1=$CIRCLE_SHA1)
    [[ -n "$CIRCLE_TAG" ]] && PARAMS+=(--tag-name=$CIRCLE_TAG)
    [[ -n "$CIRCLE_BRANCH" ]] && PARAMS+=(--branch-name=$CIRCLE_BRANCH)
    [[ -n "$CIRCLE_PULL_REQUEST" ]] && PARAMS+=(--pull-request-url=$CIRCLE_PULL_REQUEST)
    echo "$PARAMS"
}
