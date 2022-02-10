# Homer3
Homer3 is a open source MATLAB application used for analyzing fNIRS data to obtain estimates and maps of brain activation. It is a continuation of the work on the well-established HOMER2 software which itself evolved since the early 1990s, first as the Photon Migration Imaging Toolbox, then as HOMER.

Homer3 is developed and maintained by the [Boston University Neurophotonics Center](http://www.bu.edu/neurophotonics/).

To cite Homer3 in your research:

> ##### Huppert, T., Diamond, S., Franceschini, M., Boas, D. (2009). HomER: a review of time-series analysis methods for near-infrared spectroscopy of the brain. Applied optics 48(10). https://dx.doi.org/10.1364/ao.48.00d280

## Installation

Homer3 is composed only of MATLAB scripts, so the installation process for MATLAB users is as simple as downloading the code.

[Get the latest release of Homer3](https://github.com/BUNPC/Homer3/releases/latest/)

[Getting started with Homer3](https://github.com/BUNPC/Homer3/wiki/Getting-started-with-Homer3)

Note that cloning the repository or using the Download .zip button on the repository webpage WILL NOT download the submodule libraries that are a part of Homer3. Without these, the application will not run. These submodules must be downloaded manually from their respective repositories and placed in the \Homer3 folder.

## Support
Support for users of Homer3 is available via the [Homer3 & AtlasViewer community forum](https://openfnirs.org/community/homer3-forum/) hosted on openfnirs.org. This forum is for questions about how to use Homer3.

To report a bug or suggest a feature, please [create an issue](https://github.com/BUNPC/Homer3/issues/new/choose) here on GitHub.

## Documentation

Homer3 documentation is hosted via the [GitHub wiki](https://github.com/BUNPC/Homer3/wiki) and is a work in progress.

## Contributing to Homer3

We welcome contributions to Homer3 from the fNIRS community. See [CONTRIBUTING.md](.github/CONTRIBUTING.md) for development guidelines and [WORKFLOW.md](.github/WORKFLOW.md) for a walkthrough of the cloning and version control procedures recommended for development.

## License

Homer3 is [BSD licensed](https://opensource.org/licenses/BSD-3-Clause), but we ask that you cite the original publication in your research.

![Homer3](https://openfnirs.org/wp-content/uploads/2018/05/Figure_fNIRS2.jpg)

## Updating Shared Libraries

Homer3 and AtlasViewer no longer use the Git submodule utility to share the libraries DataTree and Utils because of the difficulty of merging git submodule references and other issues with GIT's submodule reference implementation. The standalone repositoties still exist but now Homer3 and AtlasViewer contain copies of the standalone repos. NOTE that the file .gitmodules still exists to specify what code in Homer3 and AtlasViwer is shared libraries; that is, what code has a corresponding standalone repos as its source. The file .gitmodules is used by internal utilities that can be run to update Homer3 and AtlasViwer versions of the libraries and insure that they match the lastest standaone version. 

DataTree and Utils (as well as Homer3 and AtlasViewer) have version files in their respective root folders called Version.txt with a simple 3-number version strings. Whenever a change is made to either the standalone version or the non-standalone versions of the libraries, the version number should be manually bumped. Then using the synSubmodules tool, the standalone and non-standalone versions should be made to match eachother. Homer3 and AtlasViewer have a tool called synSubmodules to do this easily. Here's an example of how to use it:

If making changes to Homer3/DataTree (vs the standalone repo, DataTree) 

	-- Make changes in Homer3/DataTree. 
	-- Bump up the version number for DataTree. Version number is a simple string in the Homer3/DataTree/Version.txt file
	-- Commit change to Homer3 
	-- cd to Homer3 root folder
	-- Run synSubmodules.m with no arguments. This will clone the standalone libraries (specified in Homer3/.gitmodules) to a folder called Homer3/submodules 
	   and copy the changes from the Homer3/DataTree to Homer3/submodules/DataTree
	-- Commit changes to standalone version under Homer3/submodules/DataTree
	-- Push changes to Homer3 and Homer3/submodules/DataTree.
	
	
If making change to standalone DataTree:

	-- Make changes in DataTree. 
	-- Bump up the version number in Homer3/DataTree/Version.txt.
	-- Commit changes
	
	
Then to update Homer3's (or AtlasViewer's procedure is same) shared libaries to the latest 

	-- Clone Homer3, cd <root folder>/Homer3, run setpaths
	-- Run syncSubmodules in <root folder>/Homer3 with no arguments
	-- Make any supporting changes in non-shared portion of Homer3 associated with the library changes. 
	-- Commit changes to Homer3
	-- Push changes to Homer3 remote repo
