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
        exit 0
    fi
}

copy_diff() {
    local file_name=$1
    git diff --cached > "$file_name"

    if [ -s "$file_name" ]; then
        echo "Generating commit message..."
    else
        echo "No changes detected. Please stage some files before using magic_diff."
        rm "$file_name"  # Clean up the empty diff file
        exit 0
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

        llm "Generate a git commit message based on the following diff. Do NOT include any markdown backticks or quotation marks because that will break the message. You can use light formatting like lists if needed. Here is the diff: $diff_content" > "$commit_file_name"

        copy_to_clipboard "$commit_file_name"
        echo "Message copied to clipboard"

        rm "$diff_file_name"

        if [ -f "$commit_file_name" ]; then
            rm "$commit_file_name"
        fi
    else
        echo "Failed to create or find diff file."
        exit 0
    fi
}
