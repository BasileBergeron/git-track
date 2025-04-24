
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


#TODO : Trier par date et par projet
#TODO : Ajouter option -p project_name ou -b branch_name 



#!/usr/bin/env bash

# Author: Basile Bergeron, 2025
# Github: https://github.com/BasileBergeron/git-track

# TODO : Select multiple branch


NUM_COMMITS=5
BRANCH=""
DEFAULT_DIR="$HOME/code"
VALID_BRANCHES=("main" "dev" "feature" "bugfix")

# TODO : fix bug with the number of displayed commit

usage() {
  cat <<EOF
Usage: trackgit [-n NUM_COMMITS] [-b BRANCH] [DIRECTORY]

Options:
  -n <int>      Number of commits to display per project (default: 5)
  -b <branch>   Choose branch to scan (default: main dev)
                [Valid branch]   :  ${VALID_BRANCHES[*]})
                Only one branch can be specified, for now
  --help        Help on function usage
Arguments:
  DIRECTORY    Root directory to scan (default: ~/code)

Examples:
  trackgit -n 10 ~/my_project
  trackgit ~/my_project
  trackgit -n 6
  trackgit

EOF
}


check_branch_input() {
    local input_branch="$*"
    for branch in ${input_branch}; do
        if [[ " ${VALID_BRANCHES[@]} " =~ " ${branch} " ]]; then
            continue
        else
            echo "Warning: Invalid branch => '$branch'"
            echo "Valid branches are: ${VALID_BRANCHES[*]}"
            return 1
        fi
    done
}

parse_args() {
  while getopts ":n:b:" opt; do
    case $opt in
      n)
        [[ "$OPTARG" =~ ^[0-9]+$ ]] && NUM_COMMITS="$OPTARG" || {
          echo "Option input error : Invalid number for -n"
          usage
          exit 1
        }
        ;;
      b)
        if [[ -z "$OPTARG" ]]; then
          echo "Error: Missing branch name after -b"
          usage
          exit 1
        fi
        check_branch_input ${OPTARG}
        BRANCH=${OPTARG}
        ;;
      *)
        usage
        exit 1
        ;;
    esac
  done

  shift $((OPTIND - 1))
  SEARCH_DIR=$(realpath "${1:-$DEFAULT_DIR}")
}

scan_repos() {
  local tmp_errors=$(mktemp)

  echo -e "\nScanning Git repositories in: $SEARCH_DIR\n"
  printf "%-20s %-10s %-15s %-20s %-15s %s\n" "Project" "Branch" "Date" "Author" "Id" "Commit"
  printf "%0.s-" {1..130}; echo


  while IFS= read -r gitdir; do
    repo_dir=$(dirname "$gitdir")
    project_name=$(basename "$repo_dir")

    cd "$repo_dir" 2>/dev/null || {
      echo "Warning : Cannot enter $repo_dir" >> "$tmp_errors"
      continue
    }

    if [ -z "$BRANCH" ]; then
        branches_to_scan=("main" "dev")
    else
        branches_to_scan=$BRANCH
        read -r -a branches_to_scan <<< "$branches_to_scan"
    fi


    for branch in "${branches_to_scan[@]}"; do
        fetch_and_display_commits "$branch" "$project_name"
    done

  done < <(find "$SEARCH_DIR" -type d -name ".git" 2>>"$tmp_errors")

  if grep -q "Permission denied" "$tmp_errors"; then    
    echo -e "\n\nWarning :Inaccessible directories:"
    grep "Permission denied" "$tmp_errors"
  fi

  rm -f "$tmp_errors"
}

fetch_and_display_commits() {
  local branch=$1
  local project_name=$2

  if git rev-parse --verify --quiet "$branch" >/dev/null; then
    git log ${branch} -n $((NUM_COMMITS + 1)) --date=short --pretty=format:"$project_name|$branch|%ad|%an|%h|%s" 2>/dev/null |
    while IFS="|" read -r name br date author hash msg; do
      printf "%-20s %-10s %-15s %-20s %-15s %s\n" "$name" "$br" "$date" "$author" "$hash" "$msg"
    done
  fi
}

main() {
  if [[ "$1" == "--help" || "$1" == "-h" ]]; then
    usage
    exit 0
  fi

  parse_args "$@"


  if ! find ${SEARCH_DIR} -type d -name ".git" 2>/dev/null | grep -q .; then
    echo "Warning : No Git repositories found in: ${SEARCH_DIR}"
    exit 1
  fi

  scan_repos
}

main "$@"








