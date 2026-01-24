#!/bin/bash
# tmux status bar left - adapted for WSL Arch

# Colors (user palette)
black="#1e222a"
green="#7EC7A2"
white="#abb2bf"
grey="#282c34"
blue="#61afef"
red="#e06c75"
orange="#caaa6a"
pink="#c678dd"
yellow="#EBCB8B"

# Icons
git_added_icon="󰐕"
git_modified_icon="󰏫"
git_updated_icon="󰁝"
git_deleted_icon="󰍴"
git_repo_icon="󰘬"
git_diff_icon="󰀦"
git_no_repo_icon="󰉋"
tmux_icon="󰆍"

# Tmux pill (bold green bookend, like right bar's load pill)
print_tmux_icon() {
    printf "#[fg=%s,bg=%s,bold] %s " "$black" "$green" "$tmux_icon"
}

# Get current pane directory (passed as argument from tmux, fallback to display-message)
get_pane_dir() {
    if [[ -n "$1" ]]; then
        echo "$1"
    else
        tmux display-message -p "#{pane_current_path}"
    fi
}

# Check if directory is a git repo
check_for_git_dir() {
    if [ "$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)" != "" ]; then
        echo "true"
    else
        echo "false"
    fi
}

# Check for uncommitted changes
check_for_changes() {
    if [ "$(check_for_git_dir)" == "true" ]; then
        if [ "$(git -C "$path" status -s 2>/dev/null)" != "" ]; then
            echo "true"
        else
            echo "false"
        fi
    else
        echo "false"
    fi
}

# Get current branch name (truncated to 20 chars)
get_branch() {
    if [ "$(check_for_git_dir)" == "true" ]; then
        printf "%.20s" "$(git -C "$path" rev-parse --abbrev-ref HEAD 2>/dev/null)"
    fi
}

# Count changes by type
get_changes() {
    declare -i added=0
    declare -i modified=0
    declare -i updated=0
    declare -i deleted=0

    while read -r line; do
        case "${line:0:1}" in
        'A') added+=1 ;;
        'M') modified+=1 ;;
        'R') modified+=1 ;;
        'U') updated+=1 ;;
        'D') deleted+=1 ;;
        '?') added+=1 ;;
        esac
        case "${line:1:1}" in
        'M') modified+=1 ;;
        'D') deleted+=1 ;;
        esac
    done <<< "$(git -C "$path" status -s 2>/dev/null)"

    output=""
    [ $added -gt 0 ] && output+="${added}$git_added_icon "
    [ $modified -gt 0 ] && output+="${modified}$git_modified_icon "
    [ $updated -gt 0 ] && output+="${updated}$git_updated_icon "
    [ $deleted -gt 0 ] && output+="${deleted}$git_deleted_icon "

    echo "$output"
}

# Git status with tmux formatting
git_status() {
    path=$(get_pane_dir "$1")

    if [ "$(check_for_git_dir)" == "true" ]; then
        branch=$(get_branch)

        if [ "$(check_for_changes)" == "true" ]; then
            changes=$(get_changes)
            # Has changes - show diff icon, changes, and branch in yellow
            printf "#[fg=%s,bg=%s,nobold] %s #[fg=%s,bg=%s] %s%s " "$black" "$yellow" "$git_diff_icon" "$white" "$grey" "$changes" "$branch"
        else
            # Clean repo - show repo icon and branch in green
            printf "#[fg=%s,bg=%s,nobold] %s #[fg=%s,bg=%s] %s " "$black" "$green" "$git_repo_icon" "$white" "$grey" "$branch"
        fi
    else
        # Not a git repo - folder icon pill
        printf "#[fg=%s,bg=%s,nobold] %s #[fg=#5c6370,bg=%s] ~ " "$white" "$grey" "$git_no_repo_icon" "$grey"
    fi
}

# Build the status line
main() {
    printf "%s%s#[default]" "$(print_tmux_icon)" "$(git_status "$1")"
}

main "$1"
