# Homer3 Release Procedures

This document describes the procedure for building and hosting a release of Homer3. A release of Homer3 consists of the source code packaged with a MATLAB Runtime executable for both Windows and MacOS.

## Creating a GitHub release

GitHub releases is used to host the frozen source code and [MATLAB Runtime](https://www.mathworks.com/products/compiler/matlab-runtime.html) executables. Create a new release by clicking "Draft a new release" at the top of the [Releases page](https://github.com/BUNPC/Homer3/releases). Leave the release in draft state and in pre-release state until it can be tested. See the [GitHub docs](https://docs.github.com/en/repositories/releasing-projects-on-github/managing-releases-in-a-repository) for more information about managing releases.

Release notes should be created from the commit messages logged since the last release was tagged.

## Packaging the latest source code

Create a .zip archive containing the latest source code from the master branch, making sure to include submodules. Remove all version control files from the `master` branch, including `.gitignore`. This can be accomplished with the following shell commands:

```bash
git clone https://github.com/BUNPC/Homer3 --single-branch -b master --recurse-submodules
rm -rf .git\
rm .gitignore
```

Rename the zip file `homer3_src_<version tag>_<platform>_<target MATLAB env>` i.e. `homer3_src_v1_26_0_win_R2017b.zip` or `homer3_src_v1_32_1_mac_R2020b.zip` and upload it to the GitHub release.

> Note: as of November 2021, unfortunately the automatically generated source code does NOT contain submodules! That is why we generate this archive manually.

## Creating MATLAB Runtime executables for Windows and Mac

Cross-compilation is not possible with the MATLAB compiler. The following must be repeated within both a Mac and Windows environment:

Linux is not supported.

1. Download and install MATLAB Runtime corresponding to the MATLAB version the build targets. **As of November 2020, this is MATLAB R2017b (9.3) and R2020b.**
2. Download the latest version of the master branch. In the MATLAB command window, navigate to the Homer3 root folder.
3. Execute `setpaths`
4. Execute `createInstallFile()`
5. Zip up the resulting install files which will be generated at `Homer3\Install\homer3_install`.
6. Rename this zip file `homer3_install_<version tag>_<platform>_<target MATLAB env>` i.e. `homer3_install_v1_26_0_win_R2017b.zip` or `homer3_install_v1_32_1_mac_R2020b.zip`.
7. Upload the renamed archive to the GitHub release.