
create_release() {
  local token="$1";
  local owner="$2";
  local repo="$3";
  local tag_name="$4";
  local target_commitish="$5";
  local name="$6";
  local body="$7";
  local draft="$8";
  local prerelease="$9";

  local payload="\"tag_name\":\"$tag_name\"";

  if [ -n "$target_commitish" ]; then
    payload="$payload,\"target_commitish\":\"$target_commitish\"";
  fi;

  if [ -n "$name" ]; then
    payload="$payload,\"name\":\"$name\"";
  fi;

  if [ -n "$body" ]; then
    payload="$payload,\"body\":\"$body\"";
  fi;

  if [ -n "$draft" ]; then
    payload="$payload,\"draft\":\"$draft\"";
  fi;

  if [ -n "$prerelease" ]; then
    payload="$payload,\"prerelease\":\"$prerelease\"";
  fi;

  payload="\{$payload\}";

  curl -f -X POST https://api.github.com/repos/$owner/$repo/releases \
    -A "wercker-create-release" \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token $token" \
    -H "Content-Type: application/json" \
    -d "$payload";
}

export_id_to_env_var() {
  local json="$1";
  local export_name="$2";

  local id=$(echo "$json" | $WERCKER_STEP_ROOT/bin/jq ".id");

  export $export_name=$id;
}

main() {

  # Assign global variables to local variables
  local token="$WERCKER_GITHUB_CREATE_RELEASE_TOKEN";
  local owner="$WERCKER_GITHUB_CREATE_RELEASE_OWNER";
  local repo="$WERCKER_GITHUB_CREATE_RELEASE_REPO";
  local tag_name="$WERCKER_GITHUB_CREATE_RELEASE_TAG_NAME";
  local target_commitish="$WERCKER_GITHUB_CREATE_RELEASE_TARGET_COMMITISH";
  local name="$WERCKER_GITHUB_CREATE_RELEASE_NAME";
  local body="$WERCKER_GITHUB_CREATE_RELEASE_BODY";
  local draft="$WERCKER_GITHUB_CREATE_RELEASE_DRAFT";
  local prerelease="$WERCKER_GITHUB_CREATE_RELEASE_PRERELEASE";
  local export_id="$WERCKER_GITHUB_CREATE_RELEASE_EXPORT_ID";

  # Validate variables
  if [ -z "$token" ]; then
    error "Token not specified; please add a token parameter to the step";
  fi

  if [ -z "$tag_name" ]; then
    error "Tag name not specified; please add a tag_name parameter to the step";
  fi

  if [ -n "$draft" ]; then
    if [ "$draft" != "false" ] && [ "$draft" != "true" ]; then
      error "The parameter draft has to be false or true";
    fi
  fi

  if [ -n "$prerelease" ]; then
    if [ "$prerelease" != "false" ] && [ "$prerelease" != "true" ]; then
      error "The parameter prerelease has to be false or true";
    fi
  fi

  # Set variables to defaults if not set by the user
  if [ -z "$owner" ]; then
    owner="$WERCKER_GIT_OWNER";
  fi

  if [ -z "$repo" ]; then
    repo="$WERCKER_GIT_REPOSITORY";
  fi

  if [ -z "$target_commitish" ]; then
    target_commitish="$WERCKER_GIT_COMMIT";
  fi

  if [ -z "$export_id" ]; then
    export_id="WERCKER_GITHUB_CREATE_RELEASE_ID";
  fi

  # Create the release and save the output from curl
  local RELEASE_RESPONSE=$(create_release \
    "$token" \
    "$owner" \
    "$repo" \
    "$tag_name" \
    "$target_commitish" \
    "$name" \
    "$body" \
    "$draft" \
    "$prerelease");

  export_id_to_env_var "$RELEASE_RESPONSE" "$export_id";
}

# Run the main function
main;