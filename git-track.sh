#!/bin/bash

# Config : nombre de commits à afficher
NUM_COMMITS=5
SEARCH_DIR=${1:-$HOME/code} # Par défaut : ~/code

echo "🔍 Scanning Git repositories in: $SEARCH_DIR"
echo

# En-tête
printf "%-30s %-15s %-20s %s\n" "📁 Projet" "🌿 Branche" "🕒 Date" "📝 Commit"
printf "%0.s-" {1..90}; echo

# Boucle sur tous les dossiers avec un .git
find "$SEARCH_DIR" -type d -name ".git" | while read gitdir; do
    repo_dir=$(dirname "$gitdir")
    cd "$repo_dir" || continue

    branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    git log -n $NUM_COMMITS --pretty=format:"$repo_dir|$branch|%ad|%s" --date=short 2>/dev/null | while IFS="|" read -r dir br date msg; do
        printf "%-30s %-15s %-20s %s\n" "$(basename "$dir")" "$br" "$date" "$msg"
    done
done
