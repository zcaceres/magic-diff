copy_to_clipboard() {
    local file_name=$1
    if command -v pbcopy &> /dev/null; then
        cat "$file_name" | pbcopy
    elif command -v xclip &> /dev/null; then
        cat "$file_name" | xclip -selection clipboard
    elif command -v clip &> /dev/null; then
        cat "$file_name" | clip
    elif command -v wl-copy &> /dev/null; then
        cat "$file_name" | wl-copy
    else
        echo "Clipboard tool not found, couldn't save $file_name"
    fi
}

copy_diff() {
    local file_name=$1
    local exclusions=()

    # List of lock files to potentially exclude
    local lock_files=(
        "package-lock.json" "yarn.lock" "pnpm-lock.yaml" "composer.lock"
        "Gemfile.lock" "Cargo.lock" "Pipfile.lock" "poetry.lock"
        "packages.lock.json" "go.sum" "build.sbt.lock" "mix.lock"
        "pubspec.lock" "Package.resolved" "cabal.project.freeze" "deps.edn"
        "rebar.lock" "opam.locked" "gradle.lockfile"
    )

    # Build exclusion list based on existing files
    for lock_file in "${lock_files[@]}"; do
        if git ls-files "$lock_file" --error-unmatch &> /dev/null; then
            exclusions+=("':!$lock_file'")
        fi
    done

    # Construct and execute the git diff command
    if [ ${#exclusions[@]} -eq 0 ]; then
        git diff --cached > "$file_name"
    else
        eval "git diff --cached ${exclusions[*]}" > "$file_name"
    fi

    if [ -s "$file_name" ]; then
        echo "Generating commit message..."
    else
        echo "No changes detected. Please stage some files before using magic_diff."
        rm "$file_name"  # Clean up the empty diff file
    fi
}

magic_diff() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local diff_file_name=$(mktemp /tmp/magic_diff_staged_diff.$timestamp.txt)
    local commit_file_name=$(mktemp /tmp/magic_diff_commit.$timestamp.txt)
    copy_diff $diff_file_name

    if [ -f "$diff_file_name" ]; then
        diff_content=$(<"$diff_file_name")

        # Check llm command existence
        if ! command -v llm &> /dev/null; then
            echo "llm command not found. Please ensure it's installed and in your PATH."
        fi

        llm "Generate a git commit message based on the following diff. Do NOT include any backticks (\`) or quotation marks of any kind because that will BREAK the message. DO NOT INCLUDE BACKTICK OR QUOTATION MARK CHARACTERS. You can ONLY use light formatting like lists if needed. Here is the diff: $diff_content" > "$commit_file_name"

        copy_to_clipboard "$commit_file_name"
        echo "Message copied to clipboard"

        rm "$diff_file_name"

        if [ -f "$commit_file_name" ]; then
            rm "$commit_file_name"
        fi
    else
        echo "Failed to create or find diff file."
    fi
}
