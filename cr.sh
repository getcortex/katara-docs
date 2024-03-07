
        # Function to display usage information
        usage() {
            echo "Usage: $0 -t <title> -b <message_body> [-f]"
            echo "  -t: Issue title"
            echo "  -b: Issue body"
            echo "  -f: Force push without confirmation"
            exit 1
        }

        # Parse arguments for title, message body, and force flag
        force_push=0
        while getopts ":t:b:f" opt; do
            case ${opt} in
                t )
                    title=$OPTARG
                    ;;
                b )
                    body=$OPTARG
                    ;;
                f )
                    force_push=1
                    ;;
                \? )
                    usage
                    ;;
            esac
        done

        # Check if both title and body are provided
        if [ -z "$title" ] || [ -z "$body" ]; then
            usage
        fi

        # Create the GitHub issue using the `gh` CLI
        issue_url=$(gh issue create --title "$title" --body "$body" --repo "username/repository" --web)

        # Extract the issue number from the URL
        issue_number=$(echo $issue_url | grep -oE '[0-9]+$')

        # Echo the issue URL
        echo "Issue URL: $issue_url"

        # Perform Git operations
        git add *
        git commit -m "Fixes #$issue_number"

        # Push changes with or without confirmation based on the force_push flag
        if [ $force_push -eq 1 ]; then
            git push
        else
            read -p "Are you sure you want to push the changes? (y/n) " confirm
            if [[ $confirm == [yY] ]]; then
                git push
            else
                echo "Push aborted."
            fi
        fi
