# Check outdate pods and create issue

This action detects a single outdated pod and acoordingly either create a new GitHub issue (if the issue with the passed `title` doesn't exists) or update the existing one.

## Inputs

### `outdated-pod-name`

**Required** Enter the pod name for which outdated pods need to be searched.

### `directory`

**Required** Enter the directory where Podfile is located

### `title`

**Optional** Title of the issue. If value is not passed then `Issue` will not be created/updated. First we will check, if issue, already exists or not, with the given title, if exists then edit the issue or create a new issue with the given title.
Since we're editing the existing issue (if present and open), make sure `title` doesn't matches more than 1 issue, otherwise this action will fail.

### `body`

**Optional** Description of the issue. Default value is: "Update the `outdated-pod-name` SDK from the current version `x.y.z` to the latest version `x.y.z`."

### `assignee`

**Optional** Person (Github ID) who'll be assigned for the new isuue.

### `labels`

**Optional** The label for the `issue`.

### `color`

**Optional** Colors for the label. Default is set to `FBCA04`.

## Outputs

### `issue-url`

The GitHub `issue url`, if it is either created or edited.

## `has-outdated-pod`

It will be `true` if pod have been outdated, otherwise `false`.

## Example usage

### Inputs

```yaml
steps:
  - name: Check outdated pods and create issue
    id: check-outdated-pods-and-create-issue
    uses: 1abhishekpandey/pod-outdated-check-and-create-github-issue@v1.0.0
    with:
      outdated-pod-name: "Amplitude"
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
  - name: Check outdated pods and create issue
    id: check-outdated-pods-and-create-issue
    uses: 1abhishekpandey/pod-outdated-check-and-create-github-issue@v1.0.0
    with:
      outdated-pod-name: "Amplitude"
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
