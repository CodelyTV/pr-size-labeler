<p align="center">
  <a href="http://codely.tv">
    <img alt="CodelyTV logo" src="http://codely.tv/wp-content/uploads/2016/05/cropped-logo-codelyTV.png" width="192px" height="192px"/>
  </a>
</p>

<h1 align="center">
  🏷 Pull Request size labeler
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

Create a file named `labeler.yml` inside the `.github/workflows` directory and paste the following configuration.

☝️ Here you can see the default values of all available configuration parameters, however, the only required parameter is the `GITHUB_TOKEN` one.

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
          xs_max_size: '10'
          s_max_size: '100'
          m_max_size: '500'
          l_max_size: '1000'
          fail_if_xl: 'false'
          message_if_xl: >
            'This PR exceeds the recommended size of 1000 lines.
            Please make sure you are NOT addressing multiple issues with one PR.
            Note this PR might be rejected due to its size.’
```

## 🎛️ Available parameters

- `*_max_size` (`xs_max_size`, `s_max_size`…): Adjust which amount of changes you consider appropriate for each size based on your project context
- `fail_if_xl`: Set to `'true'` will report GitHub Workflow failure if the PR size is xl allowing to forbid PR merge

## 🤔 Basic concepts or assumptions

- PR size labeler consider as a change any kind of line addition, deletion, or modification
- A PR will be labeled as `xl` if it exceeds the amount of changes defined as `l_max_size`

## :octocat: GitHub Enterprise Server support

- This Action relies on [default GitHub environment variables](https://docs.github.com/en/actions/reference/environment-variables#default-environment-variables) to obtain the correct GitHub instance. Fallback: `https://api.github.com`

## ⚖️ License

[MIT](LICENSE)
