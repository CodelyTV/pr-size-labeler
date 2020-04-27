<p align="center">
  <a href="http://codely.tv">
    <img src="http://codely.tv/wp-content/uploads/2016/05/cropped-logo-codelyTV.png" width="192px" height="192px"/>
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

Create a file named `labeler.yml` inside the `.github/workflows` directory and paste:

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
          message_if_xl: 'This PR is sooooo big!! 😳'
```

> If you want, you can customize all `*_max_size` with the size that fits in your project.

> Setting `fail_if_xl` to `'true'` will make fail all pull requests bigger than `l_max_size`.

## ⚖️ License

[MIT](LICENSE)
