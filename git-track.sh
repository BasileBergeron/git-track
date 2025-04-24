
#!/usr/bin/env bash
# function trackgit for git commit display
#
# This is a Bash function called "trakgit" that is designed to display a easy-to-read multiple repo commits.
# It takes optional arguments to specify the number of displayed commits or to specify the project to seek informations.
# If no arguments are provided, the function uses the defaults setting, wich are displaying the last 5 commits of every git repository founded in ~/code.
#
# This bash script allows to download a file from Github storage https://github.com/BasileBergeron/git-track
#
# Usage :
#       Usage: trackgit alias(~/git-track.sh)) [-n NUM_COMMITS] [DIRECTORY]
# Options:
#       -n <int>   Number of commits to display per project (default: 5)"
# Arguments:
#       DIRECTORY       Root directory to be scanned (default: ~/code)"
# Examples:
#       trackgit -n 10 ~/your_project    # Show the last 10 commits of ~/your_project"
#       trackgit ~/your_project          # Show the last 5 (default) commit of ~/your_project"
#       trackgit -n 6                    # Show the last 6 commits per project in ~/code (default)"
#       trackgit                         # Show the last 5 (default) commits per project in ~/code (default)"


# Author: Basile Bergeron, 2025
# Github: https://github.com/BasileBergeron/git-track



NUM_COMMITS=5


usage() {
  echo "Usage: trackgit alias(~/git-track.sh)) [-n NUM_COMMITS] [DIRECTORY]"
  echo
  echo "Options:"
  echo "    -n <int>   Number of commits to display per project (default: 5)"
  echo
  echo "Arguments:"
  echo "    DIRECTORY       Root directory to be scanned (default: ~/code)"
  echo
  echo "Examples:"
  echo "    trackgit -n 10 ~/your_project    # Show the last 10 commits of ~/your_project"
  echo "    trackgit ~/your_project          # Show the last 5 (default) commit of ~/your_project"
  echo "    trackgit -n 6                    # Show the last 6 commits per project in ~/code (default)"
  echo "    trackgit                         # Show the last 5 (default) commits per project in ~/code (default)"
}

while getopts ":n:" opt; do
    case $opt in
        n)
            if [[ ! "$OPTARG" =~ ^[0-9]+$ ]]; then
                echo
                echo "Error: Please provide a valid number for -n." >&2
                usage
                exit 1
            fi
            NUM_COMMITS=$OPTARG
            ;;
        *)
            usage
            ;;
    esac
done


shift $((OPTIND -1)) 
SEARCH_DIR=$(realpath "${1:-$HOME/code}")

if ! find "$SEARCH_DIR" -type d -name ".git" | grep -q .; then
    echo "No Git repository found in: $SEARCH_DIR"
    exit 1 
fi

echo -e "\nScanning Git repositories in: $SEARCH_DIR\n"
printf "%-20s %-13s %-15s %-20s %-15s %s\n" "Project" "Branch" "Date" "Author" "Id" "Commit"
printf "%0.s-" {1..130}; echo


find "$SEARCH_DIR" -type d -name ".git" | while read gitdir; do
    repo_dir=$(dirname "$gitdir")
    project_name=$(basename "$repo_dir")
    cd "$repo_dir" || continue

    for branch in main dev; do
        if git show-ref --verify --quiet refs/heads/"$branch"; then
            git log "$branch" -n $NUM_COMMITS --pretty=format:"$project_name|$branch|%ad|%an|%h|%s" --date=short 2>/dev/null | while IFS="|" read -r name br date author hash msg; do
                printf "%-20s %-10s %-15s %-21s %-15s %s\n" "$name" "$br" "$date" "$author" "$hash" "$msg"
            done
        fi
    done
done
