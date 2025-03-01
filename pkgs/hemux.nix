{pkgs, ...}:
pkgs.writeShellApplication {
  name = "hemux";
  runtimeInputs = [pkgs.tmux];
  text = ''
    # Define the file to store the last executed command
    LAST_CMD_FILE="/tmp/hemux_last_command"
    # Function to execute a command in a new or existing tmux pane
    execute_command() {
        cmd="$1"
        # Check the number of tmux panes
        PANES=$(tmux list-panes | wc -l)
        if [ "$PANES" -eq 1 ]; then
            # If only one pane exists, split the window and run the command in the new pane
            tmux split-window -h -l '30%'
            tmux select-pane -t 1
        fi

        tmux send-keys -t 2 "$cmd" Enter
        echo "$cmd" > "$LAST_CMD_FILE"
    }

    # Check for the '-r' flag to rerun the last command
    if [ "$1" = "-r" ]; then
        if [ -f "$LAST_CMD_FILE" ]; then
            last_cmd=$(cat "$LAST_CMD_FILE")
            execute_command "$last_cmd"
        else
            echo "No command found to rerun."
        fi
    elif [ "$1" = "-s" ]; then
        shift
        echo "$*" > "$LAST_CMD_FILE"
    else
        # Execute the provided command
        execute_command "$*"
    fi

  '';
}
