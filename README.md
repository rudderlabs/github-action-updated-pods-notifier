# Check outdate pods and create issue

This action has the capability to identify one or more outdated pods. Based on this detection, it will either create a new GitHub issue (if no issue with the specified `title` exists) or update an existing one. After the action is completed, it will pass the issue URL and a flag indicating whether or not an outdated pod was detected as output.

## Inputs

### `outdated-pod-names`

**Required** Please input the names of the PODs for which you want to detect outdated versions.

### `directory`

**Required** Please enter the directory where the Podfile is located.

### `title`

**Optional** Please provide the title for the issue. If a value is not specified, the `issue` will not be created or updated. The script will first check if an issue with the given `title` already exists. If it does, the issue will be edited. If it does not exist, a new issue with the specified title will be created.

### `body`

**Optional** Please provide a description for the issue. The default description is: "Update the `outdated-pod-names` SDK from the current version `x.y.z` to the latest version `x.y.z`."

### `assignee`

**Optional** Please provide the `Github ID` of the person who will be assigned to the new issue.

### `labels`

**Optional** Please provide the label for the `issue`.

### `color`

**Optional** Please provide the `color` for the label. The default color is set to `FBCA04`.

## Outputs

### `issue-url`

The URL of the created or edited GitHub issue.

## `has-outdated-pod`

A flag that indicates whether any outdated pods were detected. The value will be `true` if an outdated pod was found, and `false` if no outdated pods were detected.

## Example usage

Obtain the most recent tag from the GitHub release section and utilize that version in place of v1.0.0.

### Inputs

```yaml
steps:
  - uses: actions/checkout@v3
  - name: Check outdated pods and create issue
    id: check-outdated-pods-and-create-issue
    uses: rudderlabs/github-action-updated-pods-notifier@main
    with:
      outdated-pod-names: "Rudder, Amplitude"
      directory: "Example"
      title: "fix: update Amplitude SDK to the latest version"
      assignee: "1abhishekpandey"
      labels: "outdatedPod"
      color: "FBCA04"
    env:
      GH_TOKEN: ${{ github.token }}
```

### Outputs

```yaml
steps:
  - uses: actions/checkout@v3
  - name: Check outdated pods and create issue
    id: check-outdated-pods-and-create-issue
    uses: rudderlabs/github-action-updated-pods-notifier@main
    with:
      outdated-pod-names: "Amplitude"
      directory: "Example"
      title: "fix: update Amplitude SDK to the latest version"
    env:
      GH_TOKEN: ${{ github.token }}

  - name: Get the github issue url
    if: steps.check-outdated-pods-and-create-issue.outputs.issue-url != ''
    run: echo "The Github issue url is ${{ steps.check-outdated-pods-and-create-issue.outputs.issue-url }}"

  - name: Is outdated pods present
    if: steps.check-outdated-pods-and-create-issue.outputs.has-outdated-pod == 'true'
    run: echo "Outdated pod is detected"
```
