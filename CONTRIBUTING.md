# Contributing to Dozer

There are various ways to contribute to Dozer, and all are welcome and appreciated!

- [Bug reports](#bug-reports)
- [Feature requests](#feature-requests)
- [Design](#design)
- [Code](#code)
    - [Getting started](#getting-started)
    - [Submitting your pull request](#submitting-your-pull-request)

## Bug reports
Open issues about problems you may be encountering. When doing so please mention the version you're using.

## Feature requests
If you have a good idea for a feature or enhancement open an issue.

## Design
Refresh the Dozer icons or logo. [Design resources for logo and status bar icon](https://www.figma.com/file/g5MhiwxR1YFg5vti0tPANa/Dozer).

## Code
Bug fixes and features are welcome. Discuss larger changes in this fork's
[issues](https://github.com/disparta/Dozer/issues) before starting work.

### Getting started
Use an Apple Silicon Mac with macOS 13 or newer, Xcode 26 or newer, and XcodeGen
(`brew install xcodegen`).

Run the following command:
```shell
git clone https://github.com/disparta/Dozer &&
cd dozer &&
make build
```
The app is built in `build/DerivedData/Build/Products/Release/Dozer.app`.
Run `make open` to open the generated project in Xcode.

### Submitting your pull request
Please give a small summary of what has changed. Also add any github issues links (`Fixes #100`).
Once your pull request is created, please add a changelog entry to the CHANGELOG.md along with the PR number.
