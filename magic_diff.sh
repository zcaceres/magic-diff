copy_to_clipboard() {
    local file_name=$1
    if command -v pbcopy &> /dev/null; then
        cat "$file_name" | pbcopy
    elif command -v xclip &> /dev/null; then
        cat "$file_name" | xclip -selection clipboard
    elif command -v clip &> /dev/null; then
        cat "$file_name" | clip
    else
        echo "Clipboard tool not found, couldn't save $file_name"
    fi
}

copy_diff() {
    local file_name=$1
    git diff --cached > "$file_name"

    # Check if there are any changes in the staged files
    if [ -s "$file_name" ]; then
        echo "Diff saved in $file_name"
    else
        echo "No changes detected. Please stage some files before using magic_diff."
        rm "$file_name"  # Clean up the empty diff file
        exit 1
    fi
}

magic_diff() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local diff_file_name=$(mktemp /tmp/staged_diff.$timestamp.txt)
    local commit_file_name=$(mktemp /tmp/commit.$timestamp.txt)
    echo "Creating diff..."
    copy_diff $diff_file_name
    echo "Generating message..."

    sleep 1

    if [ -f "$diff_file_name" ]; then
        diff_content=$(<"$diff_file_name")

        # Check llm command existence
        if ! command -v llm &> /dev/null; then
            echo "llm command not found. Please ensure it's installed and in your PATH."
            exit 1
        fi

        llm "Generate a git commit message based on the following diff: $diff_content" > "$commit_file_name"

        copy_to_clipboard "$commit_file_name"

        echo "Commit Message Generated:"
        cat "$commit_file_name"
        echo "Message copied to clipboard"
    else
        echo "Failed to create or find diff file."
        exit 1
    fi
}
