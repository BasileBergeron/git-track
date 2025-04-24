git-track
Command/function trackgit in your console

Looking for an easy way to access your Git commit history and visually display the different projects? The lightweight trackgit command is designed to scan and display the latest commits found in a specified folder.
Description

This bash function is called git-track.sh, and it searches for every .git repository within a designated folder and displays essentials information : Project   Branch  Date    Author  Id  Commit.

If no path argument is provided, the function defaults to searching in ~/code.

After finding each .git repository, the function retrieves the 5 latest commits per repository as shown : 
Project / Branch / Date / Author / Id / Commit
The number of commits displayed can be customized using the -n <int> option. The function can be run using:

trackgit -n [COMMIT_NUM] [DIRECTORY]

Where:

    COMMIT_NUM is the number of commits you want to display (default: 5)

    DIRECTORY is the folder to be scanned (default: ~/code)

Setup

Before running the function, it is highly recommended to use an alias to easily access it from your terminal. Add the following alias in your shell configuration file (e.g., .bashrc, .zshrc):

alias trackgit="your_path/git-track.sh"

Make sure to replace your_path with the actual path where git-track.sh is located.
Usage

Once you've set up the alias, you can use the trackgit command to scan your Git repositories and display their latest commits.
Examples:

    Display the 5 latest commits in the default ~/code folder:

trackgit

Display the 10 latest commits in the ~/projects folder:

trackgit -n 10 ~/projects

Display the 3 latest commits in the current directory:

trackgit -n 3 .

Display the 5 latest commits in the ~/git_repos folder:

    trackgit ~/git_repos

Output

The command will output a table containing the following information:

    Project: The name of the Git repository (folder name).

    Branch: The current branch of the repository.

    Date: The date of the commit.

    Author: The author of the commit.

    Commit ID: The commit hash.

    Commit Message: The message associated with the commit.

Example output:

Scanning Git repositories in: /home/user/projects

Project              Branch        Date            Author               Id              Commit
----------------------------------------------------------------------------------------------
project-1            main          2025-04-24      John Doe             abc1234         Added new feature
project-1            dev           2025-04-23      John Doe             def5678         Bug fix
project-2            main          2025-04-22      Jane Smith           ghi9101         Update documentation

Requirements

    No special requirements besides a bash shell, a Git repository and access to the directories you want to scan.

Notes

    The script is designed to scan .git directories recursively, so it will look for all repositories inside the specified folder.

License

This project is licensed under the MIT License - see the LICENSE file for details.