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
    copy_to_clipboard "$file_name"
    echo "Diff saved in $file_name"
}

generate_commit() {
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local diff_file_name=$(mktemp /tmp/staged_diff.$timestamp.txt)
    local commit_file_name=$(mktemp /tmp/commit.$timestamp.txt)
    echo "Creating diff..."
    copy_diff $diff_file_name
    echo "Generating message..."
    diff_content=$(<"$diff_file_name")
    llm "Generate a git commit message based on the following diff: $diff_content" > "$commit_file_name"
    copy_to_clipboard "$commit_file_name"
    echo "Commit Message Generated:"
    echo cat "$commit_file_name"
    echo "Message copied to clipboard"
}
