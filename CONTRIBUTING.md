# Contributing guidelines

This document provides guidelines for contributing to this project.

## Requesting changes

[Open a new issue](https://github.com/equinor/terraform-backend/issues/new/choose).

## Making changes

1. Create a new branch. For external contributors, create a fork.

1. Make your changes to `main.bicep`.
1. Commit your changes.

   Use the [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) specification for semantic commit messages.

1. Create a pull request to merge your changes into the `main` branch.

   This will trigger a [build workflow run](https://github.com/equinor/azure-terraform-backend-template/actions/workflows/build.yml) that builds `azuredeploy.json`.

1. Request a review.

1. Once approved, merge the pull request.

   This will trigger a [release workflow run](https://github.com/equinor/azure-terraform-backend-template/actions/workflows/release.yml) that creates a new GitHub release.
