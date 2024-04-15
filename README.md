<p align="center">
  <a href="http://codely.tv">
    <img alt="CodelyTV logo" src="http://codely.tv/wp-content/uploads/2016/05/cropped-logo-codelyTV.png" width="192px" height="192px"/>
  </a>
</p>

<h1 align="center">
  🏷 Pull Request Size Labeler
</h1>

<p align="center">
    <a href="https://github.com/CodelyTV"><img src="https://img.shields.io/badge/CodelyTV-OS-green.svg?style=flat-square" alt="codely.tv"/></a>
    <a href="http://pro.codely.tv"><img src="https://img.shields.io/badge/CodelyTV-PRO-black.svg?style=flat-square" alt="CodelyTV Courses"/></a>
    <a href="https://github.com/marketplace/actions/pull-request-size-labeler"><img src="https://img.shields.io/github/v/release/CodelyTV/pr-size-labeler?style=flat-square" alt="GitHub Action version"></a>
</p>

<p align="center">
    Visualize and optionally limit the size of your Pull Requests
</p>

## 🚀 Usage

Create a file named `labeler.yml` inside the `.github/workflows` directory and paste the following configuration:

```yml
name: labeler

on: [pull_request]

jobs:
  labeler:
    runs-on: ubuntu-latest
    name: Label the PR size
    steps:
      - uses: codelytv/pr-size-labeler@v1
        with:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          xs_label: 'size/xs'
          xs_max_size: '10'
          s_label: 'size/s'
          s_max_size: '100'
          m_label: 'size/m'
          m_max_size: '500'
          l_label: 'size/l'
          l_max_size: '1000'
          xl_label: 'size/xl'
          fail_if_xl: 'false'
          message_if_xl: >
            This PR exceeds the recommended size of 1000 lines.
            Please make sure you are NOT addressing multiple issues with one PR.
            Note this PR might be rejected due to its size.
          github_api_url: 'https://api.github.com'
          files_to_ignore: ''
```

## 🎛️ Arguments

| Name                    | Required | Default Value        | Description                                                                                                             |
|-------------------------|----------|----------------------|-------------------------------------------------------------------------------------------------------------------------|
| `GITHUB_TOKEN`          | Yes      | Automatically supplied| GitHub token needed to interact with the repository.                                                                    |
| `xs_label`              | No       | 'size/xs'            | Label for very small-sized PRs.                                                                                         |
| `xs_max_size`           | No       | '10'                 | Maximum number of changes allowed for XS-sized PRs.                                                                    |
| `s_label`               | No       | 'size/s'             | Label for small-sized PRs.                                                                                              |
| `s_max_size`            | No       | '100'                | Maximum number of changes allowed for S-sized PRs.                                                                     |
| `m_label`               | No       | 'size/m'             | Label for medium-sized PRs.                                                                                             |
| `m_max_size`            | No       | '500'                | Maximum number of changes allowed for M-sized PRs.                                                                     |
| `l_label`               | No       | 'size/l'             | Label for large-sized PRs.                                                                                              |
| `l_max_size`            | No       | '1000'               | Maximum number of changes allowed for L-sized PRs.                                                                     |
| `xl_label`              | No       | 'size/xl'            | Label for extra-large-sized PRs.                                                                                        |
| `fail_if_xl`            | No       | 'false'              | Whether to fail the GitHub workflow if the PR size is 'XL' (blocks the merge).                                         |
| `message_if_xl`         | No       | Custom message       | Message to display when a PR exceeds the 'XL' size limit.                                                              |
| `github_api_url`        | No       | 'https://api.github.com' | URL for the GitHub API, can be changed for GitHub Enterprise Servers.                                                  |
| `files_to_ignore`       | No       | ''                   | Files to ignore during PR size calculation. Supports newline or whitespace delimited list.                              |
| `ignore_line_deletions` | No       | 'false'              | Whether to ignore lines which are deleted when calculating the PR size. If set to 'true', deleted lines will be ignored. |

### Example for `files_to_ignore`:
```yml
files_to_ignore: 'package-lock.json *.lock'
# OR
files_to_ignore: |
  "package-lock.json"
  "*.lock"
  "docs/*"
```

## 🤔 Basic concepts or assumptions

- PR Size Labeler considers any line addition, deletion, or modification as a change.
- A PR will be labeled as 'xl' if it exceeds the amount of changes defined in `l_max_size`.

## ⚖️ License

[MIT](LICENSE)
