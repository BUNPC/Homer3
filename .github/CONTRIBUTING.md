# Contributing

We welcome contributions to the Homer3 open-source software package from the fNIRS community! This document describes the procedures for adding and editing code as well as building releases of the application for distribution. 

It is recommended that contributors familiarize themselves with Git and GitHub before attempting to contribute to Homer3. Links to relevant documentation are included here for your convenience. For a walkthrough of the contribution procedure, see [WORKFLOW.md](WORKFLOW.md). Version control software and contribution procedures are complicated, but there is no other way to achieve collaborative development. 😊

> Note: As of October 2021, code shared with other applications in the openfnirs ecosystem such as the DataTree and Utils libraries are managed as submodule repositories. Submodules cannot be managed using GitHub desktop.

## Release and versioning procedures

[Homer3 releases](https://github.com/BUNPC/Homer3/releases) are composed of frozen source code plus compiled versions of the software for use with the [MATLAB Runtime](https://www.mathworks.com/products/compiler/matlab-runtime.html) on Windows and MacOS.

Releases are to be built as often as important fixes and features are merged with the `master` branch and then tested.

Each release is associated with a [version tag](https://github.com/BUNPC/Homer3/tags), i.e. [`v1.32.3`](https://github.com/BUNPC/Homer3/releases/tag/v1.32.3).

As of November 2021, pull requests and commits need not increment the version tag, but version tags MUST be incremented before building a new release. The tag associated with a release CANNOT be changed unless the release is marked draft/is a pre-release.

For a description of how to generate and package a release for distribution, see [RELEASE.md](RELEASE.md).

## Fork and pull model

Following the [fork and pull model](https://docs.github.com/en/github/collaborating-with-pull-requests/getting-started/about-collaborative-development-models#fork-and-pull-model), contributors are expected to make their changes in their [fork](https://docs.github.com/en/get-started/quickstart/fork-a-repo) of the repository and to [create pull requests](https://docs.github.com/en/github/collaborating-with-pull-requests/proposing-changes-to-your-work-with-pull-requests/creating-a-pull-request) to integrate these changes with a branch of the BUNPC repository after they are reviewed by the community.

In most cases, changes should be made to the [development branch](https://github.com/BUNPC/Homer3/tree/development) of the repository.

### Pull requests

Open a pull request via the Contribute button on your fork's page.

Pull requests must meet the following requirements:
- Pull requests must not include erroneous files or whitespace changes
- Commit messages or the pull request description must fully document the proposed changes
- Relevant issues and milestones must be linked
- Relevant submodule pull requests must be linked
- Pull requests require review before they can be merged into `master` or `development`.

### Branches

The `master` branch should contain the most stable version of the working code. Releases are stable freezes of the master branch. Changes made directly to the master branch must address an issue or bug and be relatively small.

The `development` branch integrates finished features and fixes. The development branch is synced with the master branch periodically.

No one can push to master without creating a PR. **Administrators may push to `development` but are but are strongly encouraged not to.**

Depending on the scale of the changes, it may be preferable to direct pull requests to a *feature branch*: this is a branch created to integrate related changes prior to merging them with the development code. This is especially useful when multiple developers are working on the same large feature, i.e. a new GUI panel being developed in `plotprobe-2`. [Creating a milestone](https://docs.github.com/en/issues/using-labels-and-milestones-to-track-work/about-milestones) related to a feature branch can help to facilitate discussion about collaborative development.

## Submodules

As of October 2021, code shared with other applications in the openfnirs ecosystem such as the [DataTree](https://github.com/BUNPC/DataTree) and [Utils](https://github.com/BUNPC/Utils) libraries are managed as [submodule repositories](https://git-scm.com/book/en/v2/Git-Tools-Submodules). Submodules cannot be managed using GitHub desktop.

Contributing to submodules is mostly equivalent to contributing to the Homer3 repository. Take care to ensure that submodules changes are compatible with Homer3 and AtlasViewer by avoiding changes to interfaces and names.

If you have made combined changes to the submodule as well as Homer3, explicitly link the submodule PR to the related PR in the parent repository. The submodule PR must be accepted before the PR can be accepted in the parent repository.

## Development environment

An [intallation of Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) is required.

[GitHub Desktop](https://desktop.github.com/), [Visual Studio Code](https://code.visualstudio.com/), and [TortoiseSVN](https://tortoisesvn.net/) are popular GUI applications for version control. **While these applications are very useful for visualizing changes to files and resolving merge conflicts, please note that these applications offer only modest support for git submodules.** The use of command line git for management of submodules is highly recommended; see the example below.

### MATLAB Version

Homer3 is a MATLAB applicaton. In order to support users who do not have MATLAB licenses, we release a compiled build of Homer3 for use with the [MATLAB Runtime environment](https://www.mathworks.com/products/compiler/matlab-runtime.html).

As of November 2021, these builds target MATLAB R2020b (9.9) as well as MATLAB R2017b (9.3). Therefore, the use of functions introduced to MATLAB after R2020b (9.9) is not supported.

The use of 2020b is therefore recommended for development purposes.

We compile these releases for Windows and MacOS. Linux is not supported.

## Walkthrough

A step-by-step walkthrough of key steps in the version control process is described in [WORKFLOW.md](WORKFLOW.md).
