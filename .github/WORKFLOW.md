# Development workflow walkthrough

The following is an example of the fork and pull workflow, making use of the git command line interface. Users of alternative graphical interfaces are responsible for learning how to achieve equivalent functionality!

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines for development.

**Please follow along with this when contributing if you are only an entry-level user of Git!**

## Forking Homer3

A fork is a complete copy of a repository. Regular contributors should maintain their own fork of Homer3.

To create a fork, click the Fork button on the top right of the repository page.

If you intend to contribute to Homer3's submodules, repeat this process for these repositories as well.

## Cloning your fork of Homer3

To clone the repository is to download the *remote* repository (the code hosted on GitHub) to your local machine.

To clone Homer3 along with all its submodules, use

```shell
git clone https://github.com/<your username>/Homer3 --recurse-submodules
```

A simple `git clone` without the `--recurse-submodules` parameter WILL NOT download the associated submodules, nor using the Download button on the repository webpage.

### Switching to the working branch

 If you intend to edit a single branch of your fork, a convenient parameter is `--single-branch`:

 ```shell
git clone https://github.com/<your username>/Homer3 --recurse-submodules --single-branch -b <working branch name>
```

Otherwise, `checkout` the working branch:
 ```shell
git checkout <working branch name>
```

### Submodule management

You will also need to switch to the fork and branch of the submodule you wish to make changes to.

To change the remote repository associated with each submodule, edit the contents of `Homer3\.gitmodules` or use:
```shell
git config --file=.gitmodules submodule.<name of submodule>.url <url of your fork>
```
and then call
```shell
git submodule sync
```
To confirm that the submodules are now part of your branch:
 ```shell
 cd <name of submodule>
git status
```
The submodule should be treated as its own repository from this point o\



nward. For the remainder of the tutorial, remember that each section must be repeated within the submodules up until the point at which pull requests are created. **Do not commit your changes to `.gitmodules`**.

## Syncing your fork with the BUNPC repository

If you want to download the latest code from the BUNPC repository before making your changes or before opening a pull request, you will need to link your local repository to the original remote. From inside the cloned /Homer3 folder:
```shell
git remote add bunpc https://github.com/BUNPC/Homer3
```

To verify that the remote has been added:
```shell
git remote -v
```

Now you can sync the working branch of your local repository with the current state of the branch you ultimately want to contribute to, such as BUNPC/development:
```shell
git pull bunpc development --recurse-submodules
```

This will fetch and merge the remote branch `development` from the BUNPC respository. If problems arise, you will have to resolve the merge conflicts manually. Resolving conflicts is [possible via the Git command line interface](https://docs.github.com/en/github/collaborating-with-pull-requests/addressing-merge-conflicts/resolving-a-merge-conflict-using-the-command-line), but made easier with graphical utilities such as [GitHub Desktop](https://desktop.github.com/), [Visual Studio Code](https://code.visualstudio.com/), or [TortoiseSVN](https://tortoisesvn.net/).

To undo a merge that has gone awry, use
```shell
git merge --abort
```

> Note: pulling the latest remote branch and resolving conflicts is required before opening a pull request.

## Committing changes

Changes you have made must deliberately committed to the working branch.

To see the list of files which have been changed:
```shell
git status
```

> Note: Graphical interfaces can make staging files for commits more intuitive. 

To add files to a commit using the command line:
```shell
git add <name of file>
```

Once changes have been staged, commit them using
```shell
git commit -m <description of the changes being committed>
```

To commit files to a submodule, change directories to the submodule and repeat the process of adding files and committing changes.

> Note: take care not to accidentally add log files, configuration files like AppSettings.cfg, or generated data such as Registry.mat to your commits.

To push your commits to your remote fork:
```shell
git push origin <working branch name>
```

## Creating a pull request

Create a pull request in the Pull Request tab of the repository website or via the Contribute button. Target the head branch you wish to contribute to, i.e. `development`.

If there is a conflict, follow the above instructions for [Syncing your fork with the BUNPC repository](WORKFLOW.md#syncing-your-fork-with-the-bunpc-repository) and resolve the conflict locally by pushing a merge commit to your working branch.

See [CONTRIBUTING.md](CONTRIBUTING.md) for expectations regarding pull requests.

