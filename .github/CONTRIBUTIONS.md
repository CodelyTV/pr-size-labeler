# Contribution Guide

Thank you for your interest in contributing to our project! We welcome contributions from the community and appreciate your efforts to help improve our codebase. To ensure a smooth collaboration process, please follow the guidelines outlined below.

## License

By contributing to this project, you agree to maintain the MIT license for your contributions. All code and documentation submitted as part of your contributions will be subject to the terms and conditions of the MIT license.

## Semantic Versioning

We adhere to Semantic Versioning (SemVer) when introducing new fixes and features. When making changes that may affect the public contract or assumptions that current users might have made, we will:

1. Discuss the proposed changes openly within the project's communication channels (e.g., issue threads, pull requests) before making a decision.
2. If the changes are agreed upon and deemed beneficial, we will publish a new major version to indicate that the GitHub Action is no longer backward compatible in terms of the public contract or assumptions.

## Code Quality

To maintain a consistent and readable codebase, we kindly ask you to follow the existing code patterns and conventions. This includes:

- Writing short functions with clear purpose and naming.
- Separating functions by modules or namespaces (e.g., `github`, `ensure`).
- Following the established coding style and best practices.

While we don't aim to be overly strict, we appreciate your willingness to adhere to the existing patterns and maintain a minimum level of code quality.

## Testing

Tests are written using [bashunit](https://bashunit.typeddevs.com/).

To install the vendor dependencies, run:

```bash
./install-dependencies.sh
```

To run all tests, use the following command:

```bash
./lib/bashunit tests
```

Please make sure to write appropriate tests for any new features or bug fixes you introduce. Tests should be placed in the `tests` directory and follow the naming convention of `test_*.sh`.

## Contribution Process

To contribute to this project, please follow these steps:

1. Fork the repository and create a new branch for your feature or bug fix.
2. Make your changes in the new branch, ensuring that your code follows the project's coding style and conventions.
3. Write clear and concise commit messages that describe the purpose of your changes.
4. Push your changes to your forked repository.
5. Submit a pull request to the main repository, clearly explaining the purpose and scope of your changes by populating the pull request template.
6. Update the unit tests if the change requires testing, ie not a documentation change.
7. Engage in the discussion and address any feedback or questions raised during the code review process.

We will review your contribution and provide feedback as soon as possible. Once your changes have been approved, they will be merged into the main branch.

Thank you for your contribution and support!
