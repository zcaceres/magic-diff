copy_diff() {
    local file_name=$1
    git diff --cached > "$file_name"
    copy_to_clipboard "$file_name"
    echo "Diff saved in $file_name"
}

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
