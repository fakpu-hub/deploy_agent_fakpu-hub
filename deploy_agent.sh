#!/bin/bash
chmod u+x deploy_agent.sh
## FEATURE 1
# To check if the dependencies are installed
check_dependencies()
{
    if ! command -v python3 > /dev/null 2>&1
    then
        echo "Error: python3 is not installed."
        exit 1
    
    fi

    if ! command -v zip > /dev/null 2>&1
    then
        echo "Error: zip is not installed."
        exit 1
    
    fi
}
# Function to check if the project already exists
checker_function()
{
if [ -d "$PROJECT_DIR" ]
then
    # It exists
    read -r -p "Project exists already. Overwrite? (y/n): " answer
    if [ "$answer" = "y" ]
        then
            rm -rf "$PROJECT_DIR"
            mkdir "$PROJECT_DIR"
    elif [ "$answer" = "n" ]
        then
            echo "Deployment cancelled."
            exit 1
    else
        echo "Please enter either y or n. Watch your letter casing: "
        checker_function
        return
    
    fi
else
    # It doesn't exist
    mkdir "$PROJECT_DIR"
    echo "Project deployment successful"

fi

}

## Logic
# Creates default roster
create_template_roster()
{
    read -r -p "How many students? " student_count
    if [[ ! "$student_count" =~ ^[1-9][0-9]*$ ]]
        then
            echo "Invalid input. Please enter a positive whole number."
            create_template_roster
            return
    fi

    if [ "$student_count" -gt 10 ]
        then
            echo "Too many students. Maximum is 10."
            create_template_roster
            return
    fi

    head -n $((student_count + 1)) templates/assets.csv > "$PROJECT_DIR/Helpers/assets.csv"
    
    TOTAL_SESSIONS=5
}

#Creates a new roster
create_fresh_roster()
{
    read -r -p "How many students? " student_count
    echo "$student_count students"

    if [[ ! "$student_count" =~ ^[1-9][0-9]*$ ]]
    then
        echo "Invalid input. Please enter a positive whole number."
        create_fresh_roster
        return
    
    fi

    names=("Alice Johnson" "Bob Smith" "Charlie Brown" "David Wilson" "Emma Davis" "Frank Miller" "Grace Wilson" "Henry Brown" "Ivy Taylor" "Jack Adams")
    emails=("alice@example.com" "bob@example.com" "charlie@example.com" "david@example.com" "emma@example.com" "frank@example.com" "grace@example.com" "henry@example.com" "ivy@example.com" "jack@example.com")

    echo "Email,Names,Attendance Count,Absence Count" > "$PROJECT_DIR/Helpers/assets.csv"
    # To make sure the request doesn't exceed the student amount
    if [ "$student_count" -gt "${#names[@]}" ]
    then
        echo "Too many students. Maximum is ${#names[@]}."
        create_fresh_roster
        return
    
    fi

    for ((i=0; i<student_count; i++))
    do
        echo "${emails[$i]},${names[$i]},0,0" >> "$PROJECT_DIR/Helpers/assets.csv"
    done
    
       TOTAL_SESSIONS=1
}
# Select option A or B
create_roster()
{
    echo "How would you like to create the roster?"
    echo "A. Copy from template"
    echo "B. Generate fresh roster"

    read -r -p "Choose A or B: " choice

    if [ "$choice" = "A" ]
    then
        create_template_roster
    elif [ "$choice" = "B" ]
    then
        create_fresh_roster
    else
        echo "Please choose A or B."
        create_roster
        return
    
    fi
    
}


## Updating the thresholds
update_thresholds()
{
    read -r -p "Would you like to update the thresholds? (y/n): " answer

    if [ "$answer" = "y" ]
    then
        read -r -p "Warning threshold [75]: " warning_threshold
        read -r -p "Failure threshold [50]: " failure_threshold

        if [ -z "$warning_threshold" ]
        then
            warning_threshold=75
        elif [[ ! "$warning_threshold" =~ ^[1-9][0-9]*$ ]] || [ "$warning_threshold" -gt 100 ]
        then
            echo "Invalid warning threshold. Enter a positive number from 1 to 100."
            update_thresholds
            return
        
        fi

        if [ -z "$failure_threshold" ]
        then
            failure_threshold=50
        elif [[ ! "$failure_threshold" =~ ^[1-9][0-9]*$ ]] || [ "$failure_threshold" -gt 100 ]
        then
            echo "Invalid failure threshold. Enter a positive number from 1 to 100."
            update_thresholds
            return
        
        fi

        sed -i "s/\"warning\": [0-9]*/\"warning\": $warning_threshold/" "$PROJECT_DIR/Helpers/config.json"

        sed -i "s/\"failure\": [0-9]*/\"failure\": $failure_threshold/" "$PROJECT_DIR/Helpers/config.json"

        echo "Thresholds updated."
    
    fi

}

## ERROR HANDILING MEASURES
handle_interrupt()
{
    echo
    echo "Deployment interrupted."

    if [ -d "$PROJECT_DIR" ]
    then
        zip -r "${PROJECT_DIR}_archive.zip" "$PROJECT_DIR"
        echo "Incomplete project archived as ${PROJECT_DIR}_archive.zip"
    fi

    exit 1
}

deploy()
{
    trap 'handle_interrupt' SIGINT SIGTSTP

    check_dependencies
    # Prompts the user to input a username and creates a directory with it
    read -r -p "Project name: " username
    echo "You entered: $username"
    echo "Deployment starting..."
    PROJECT_DIR="attendance_tracker_$username"

    checker_function

    mkdir "$PROJECT_DIR/Helpers"
    mkdir "$PROJECT_DIR/reports"

    cp templates/attendance_checker.py "$PROJECT_DIR/"
    cp templates/config.json "$PROJECT_DIR/Helpers/"

    create_roster
    # Updates total sessions
    sed -i "s/\"total_sessions\": [0-9]*/\"total_sessions\": $TOTAL_SESSIONS/" "$PROJECT_DIR/Helpers/config.json"

    update_thresholds
    # Updates file permissions
    chmod +x "$PROJECT_DIR/attendance_checker.py"
    chmod 600 "$PROJECT_DIR/Helpers/config.json"

    echo "Deployment complete."
    echo "Starting application..."

    trap - SIGINT SIGTSTP
    (
        cd "$PROJECT_DIR"
        echo "absent.log not found."
    
        python3 attendance_checker.py
    )
}


## FEATURE 2
run_application()
{
    read -r -p "Project name: " username

    PROJECT_DIR="attendance_tracker_$username"

    if [ ! -d "$PROJECT_DIR" ]
    then
        echo "Project does not exist."
        return 1
    
    fi

    cd "$PROJECT_DIR" || return 1

    python3 attendance_checker.py
}

## FEATURE 3
archive_logs()
{
    read -r -p "Project name: " username

    PROJECT_DIR="attendance_tracker_$username"

    if [ ! -d "$PROJECT_DIR" ]
    then
        echo "Project does not exist."
        return 1
    
    fi

    timestamp=$(date +%Y%m%d_%H%M%S)

    mkdir -p "$PROJECT_DIR/archives/attendance"
    mkdir -p "$PROJECT_DIR/archives/absent"

    if [ -f "$PROJECT_DIR/reports/attendance.log" ]
    then
        cp "$PROJECT_DIR/reports/attendance.log" "$PROJECT_DIR/archives/attendance/attendance_$timestamp.log"
        echo "Attendance log archived."
    else
        echo "attendance.log not found."
    
    fi

    if [ -f "$PROJECT_DIR/reports/absent.log" ]
    then
        cp "$PROJECT_DIR/reports/absent.log" "$PROJECT_DIR/archives/absent/absent_$timestamp.log"
        echo "Absent log archived."
    else
        echo "absent.log not found."
    
    fi
}


## TIME TO RUN THE FINAL CODE
main()
{
    echo "1. Deploy application"
    echo "2. Run application"
    echo "3. Archive logs"
    echo "4. Exit"

    read -r -p "Choose an option: " choice

    if [ "$choice" = "1" ]
    then
        deploy
    elif [ "$choice" = "2" ]
    then
        run_application
    elif [ "$choice" = "3" ]
    then
        archive_logs
    elif [ "$choice" = "4" ]
    then
        exit 0
    else
        echo "Invalid option. Please enter from 1 - 4"
        main 
        return
    
    fi

}

main
