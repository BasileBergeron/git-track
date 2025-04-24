#!/bin/bash

NUM_COMMITS=5
SEARCH_DIR=$(realpath "${1:-$HOME/code}")

echo "Scanning Git repositories in: $SEARCH_DIR"
echo

printf "%-30s %-15s %-20s %s\n" "📁 Project" "🖧 Branch" "🕒 Date" "📝 Commit"
printf "%0.s-" {1..90}; echo # visual separator

find "$SEARCH_DIR" -type d -name ".git" | while read gitdir; do
    repo_dir=$(dirname "$gitdir")
    project_name=$(basename "$repo_dir")
    cd "$repo_dir" || continue

    for branch in main dev; do
        # Vérifie si la branche existe
        if git show-ref --verify --quiet refs/heads/"$branch"; then
            git log "$branch" -n $NUM_COMMITS --pretty=format:"$project_name|$branch|%ad|%s" --date=short 2>/dev/null | while IFS="|" read -r name br date msg; do
                printf "%-30s %-15s %-20s %s\n" "$name" "$br" "$date" "$msg"
            done
        fi
    done
done
