#!/bin/bash

# Mandatory Input
MULTIPLE_PODS_INPUT=$1
INPUT_DIRECTORY=$2

# Optional Input
TITLE=$3
ASSIGNEE=$4
BODY=$5
LABELS=$6
COLOR=$7

if [ -z "$MULTIPLE_PODS_INPUT" ] || [ -z "$INPUT_DIRECTORY" ]; then
  echo "Mandatory fields must be present."
  exit 1
else
  echo "Input Pods is: $MULTIPLE_PODS_INPUT"
  echo "Input Directory is: $INPUT_DIRECTORY"
fi

echo "Title is: $TITLE"
echo "Assignee is: $ASSIGNEE"
echo "Body is: $BODY"
echo "Labels is: $LABELS"
echo "Color is: $COLOR"

echo "Change to directory: $INPUT_DIRECTORY"
cd "$INPUT_DIRECTORY"

# Remove the existing Podfile.lock and then install the pods
if [ -f Podfile.lock ]; then
  rm Podfile.lock
fi
pod install

# Function to trim whitespaces from a string
trim_whitespaces() {
  local string="$1"
  string="${string#"${string%%[![:space:]]*}"}"
  string="${string%"${string##*[![:space:]]}"}"
  echo "$string"
}

edit_issues() {
  local issues="$1"
  local title="$2"
  local body="$3"

  while read item; do
    i_title=$(jq -r '.title' <<<"$item")
    i_number=$(jq -r '.number' <<<"$item")

    if [ "$i_title" == "$title" ]; then
      echo "Edit existing issue"
      gh issue edit "$i_number" --body "$body"
      ISSUE_URL=$(gh issue view "$i_number" --json url | jq '.[]')
      return
    fi
  done <<<"$(echo "$issues" | jq -c -r '.[]')"
}

create_new_issue() {
  echo "Creating new issue"

  # Create a label
  if [ -n "$labels" ]; then

    $(gh label create --force "$LABELS" --description "Pod is outdated" --color "$COLOR")
  fi
  # Create a new issue
  ISSUE_URL=$(gh issue create -a "$ASSIGNEE" -b "$BODY" -t "$TITLE" --label "$LABELS")
}

# Save the original IFS
original_ifs=$IFS

# Set IFS to a comma
IFS=","

# Split the string into an array
MULTIPLE_PODS=($MULTIPLE_PODS_INPUT)

POD_OUTDATED_OUTPUT=$(pod outdated)
echo "POD INSTALL output: $POD_OUTDATED_OUTPUT"

# Initialize an empty body
body=()

HAS_OUTDATED_PODS="false"

# Check if outdated PODs are present or not and accordingly construct the description of the issue
for value in "${MULTIPLE_PODS[@]}"; do
  INDIVIDUAL_POD=$(trim_whitespaces "$value")
  echo "Currently checking for pod: $INDIVIDUAL_POD"

  CURRENT_VERSION=$(echo "$POD_OUTDATED_OUTPUT" | grep -i "$INDIVIDUAL_POD" | cut -d ">" -f2 | cut -d "(" -f1 | sed 's/ //g')
  LATEST_VERSION=$(echo "$POD_OUTDATED_OUTPUT" | grep -i "$INDIVIDUAL_POD" | cut -d "(" -f2 | cut -d ")" -f1)

  # Outdated POD is detected, update the body
  if [ -n "$CURRENT_VERSION" ]; then
    HAS_OUTDATED_PODS="true"
    echo "$INDIVIDUAL_POD POD need an update."

    GENERATED_BODY="Update the $INDIVIDUAL_POD SDK from the current version $CURRENT_VERSION to the $LATEST_VERSION."
    body+=("$GENERATED_BODY")
  fi
done

if [ -z "$TITLE" ]; then
  echo "Since title of the issue is not present, issue will not be created. To create the issue at least provide the title."
  export ISSUE_URL="" HAS_OUTDATED_PODS
else

  # Create a sinle body delimited with newlines
  body=$(
    IFS=$'\n'
    echo "${body[*]}"
  )

  # If BODY input is not provided
  if [ -z "$BODY" ]; then
    BODY="$body"
  fi

  # Create or edit existing issue
  if [ "$HAS_OUTDATED_PODS" == "true" ]; then

    # Construct json array containing title and number
    issues=$(gh issue list --search "$TITLE" --json title,number)

    # Edit the issue and get the issue url
    edit_issues "$issues" "$TITLE" "$BODY"
    # If issue url already exists
    if [ -n "$ISSUE_URL" ]; then
      echo "Issue exist and its URL is: $ISSUE_URL"
      export ISSUE_URL HAS_OUTDATED_PODS
    else
      # Issue doesn't exist!
      create_new_issue
      echo "New issue is created and its URL is: $ISSUE_URL"
      export ISSUE_URL HAS_OUTDATED_PODS
    fi
  else
    echo "No Outdted PODs detected"
    export ISSUE_URL="" HAS_OUTDATED_PODS
  fi
fi
