#!/bin/bash

# notion.sh
# A script to manage events and reminders
# Skyler Cheung
# 2023-04-25

# The command to run is ./notion.sh

view_commitments() {
    echo "Calendar events:"
    cat events.txt

    echo "Reminders:"
    cat reminders.txt
}

validate_date() {
    local date_regex='^[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}$'
    if [[ $1 =~ $date_regex ]]; then
        return 0
    else
        return 1
    fi
}

validate_category() {
    local category_regex='^[a-zA-Z]+$'
    if [[ $1 =~ $category_regex ]]; then
        return 0
    else
        return 1
    fi
}

validate_priority() {
    local priority_regex='^(high|medium|low)$'
    if [[ $1 =~ $priority_regex ]]; then
        return 0
    else
        return 1
    fi
}

add_event() {
    while true; do
        read -rp "Enter start time (yyyy-mm-dd hh:mm): " start_time
        if ! validate_date "$start_time"; then
            echo "Invalid date format. Please try again."
        else
            break
        fi
    done

    while true; do
        read -rp "Enter end time (yyyy-mm-dd hh:mm): " end_time
        if ! validate_date "$end_time"; then
            echo "Invalid date format. Please try again."
        else
            break
        fi
    done

    read -rp "Enter title: " title

    while true; do
        read -rp "Enter location: " location
        if ! validate_category "$location"; then
            echo "Invalid location. Please try again."
        else
            break
        fi
    done

    while true; do
        read -rp "Is this a recurring event? (yes or no): " recurring
        if [[ $recurring != "yes" && $recurring != "no" ]]; then
            echo "Invalid input. Please enter yes or no."
        else
            break
        fi
    done

    while true; do
        read -rp "Enter category: " category
        if ! validate_category "$category"; then
            echo "Invalid category. Please try again."
        else
            break
        fi
    done

    while true; do
        read -rp "Enter priority (high, medium, low): " priority
        if ! validate_priority "$priority"; then
            echo "Invalid priority. Please try again."
        else
            break
        fi
    done

    read -rp "Enter notes: " notes

    echo "$start_time | $end_time | $title | $location | $recurring | $category | $priority | $notes" >>events.txt

    echo "Event added successfully."
}

# modify_event() {
# # Prompt user for the event to modify
# read -p "Enter the title of the event you want to modify: " search_term

# # Find the matching event in the file
# grep -i "$search_term" events.txt >temp.txt
# if [[ $(wc -l <temp.txt) -eq 0 ]]; then
#     echo "No event found with title '$search_term'"
#     rm temp.txt
#     return

# elif [[ $(wc -l <temp.txt) -gt 1 ]]; then
#     echo "Multiple events found with title '$search_term':"
#     cat temp.txt
#     echo "Please enter the event ID of the event you want to modify:"
#     read id
#     sed -i "${id}s/^.*$/$(get_event_data)/" events.txt
# else
#     sed -i "$(get_event_id) s/^.*$/$(get_event_data)/" events.txt
# fi

# rm temp.txt
# echo "Event modified successfully!"

modify_event() {
    read -p "Enter search term: " term
    echo "Matching events:"
    grep -in "$term" events.txt

    read -p "Enter ID of event to modify: " id
    event=$(sed -n "${id}p" events.txt)

    read -p "Enter new title (press enter to keep existing title): " title
    if [ -n "$title" ]; then
        event=$(echo "$event" | sed "s/^.*\t/${title}\t/")
    fi

    read -p "Enter new start time (yyyy-mm-dd hh:mm) (press enter to keep existing time): " start_time
    if [ -n "$start_time" ]; then
        event=$(echo "$event" | sed "s/^\S*\t[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}\t/${start_time}\t/")
    fi

    read -p "Enter new end time (yyyy-mm-dd hh:mm) (press enter to keep existing time): " end_time
    if [ -n "$end_time" ]; then
        event=$(echo "$event" | sed "s/^\S*\t\S*\t[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} [0-9]\{2\}:[0-9]\{2\}\t/${end_time}\t/")
    fi

    read -p "Enter new description (press enter to keep existing description): " description
    if [ -n "$description" ]; then
        event=$(echo "$event" | sed "s/^\S*\t\S*\t\S*\t/${description}\t/")
    fi

    sed -i "${id}s/.*/${event}/" events.txt
    echo "Event modified successfully."
}

get_event_id() {
    grep -ni "$search_term" events.txt | cut -d: -f1
}

get_event_data() {
    read -p "Enter the new event date (YYYY-MM-DD): " date
    while [[ ! $date =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; do
        read -p "Invalid date format. Please enter date in YYYY-MM-DD format: " date
    done

    read -p "Enter the new event time (HH:MM): " time
    while [[ ! $time =~ ^[0-9]{2}:[0-9]{2}$ ]]; do
        read -p "Invalid time format. Please enter time in HH:MM format: " time
    done

    read -p "Is the event recurring? (y/n): " recurring
    while [[ ! $recurring =~ ^[yn]$ ]]; do
        read -p "Invalid input. Please enter 'y' or 'n': " recurring
    done

    read -p "Enter the new event priority (low/medium/high): " priority
    while [[ ! $priority =~ ^low|medium|high$ ]]; do
        read -p "Invalid priority level. Please enter 'low', 'medium', or 'high': " priority
    done

    read -p "Enter the new event location: " location
    read -p "Enter the new event category: " category
    read -p "Enter any additional notes: " notes

    echo "$date,$time,$search_term,$location,$recurring,$priority,$category,$notes"
}

delete_event() {
    read -p "Enter search term: " term
    echo "Matching events:"
    grep -in "$term" events.txt

    read -p "Enter ID of event to delete: " id
    id=$(echo "${id}" | tr -d '\n')
    sed -i "${id}d" events.txt

    echo "Event deleted successfully."
}

add_reminder() {
    while true; do
        read -p "Enter deadline (yyyy-mm-dd hh:mm): " deadline
        if ! validate_date "$deadline"; then
            echo "Invalid date format. Please try again."
        else
            break
        fi
    done

    read -p "Enter title: " title

    while true; do
        read -p "Enter category: " category
        if ! validate_category "$category"; then
            echo "Invalid category. Please try again."
        else
            break
        fi
    done

    while true; do
        read -p "Enter priority (high, medium, low): " priority
        if ! validate_priority "$priority"; then
            echo "Invalid priority. Please try again."
        else
            break
        fi
    done

    read -p "Enter notes: " notes

    echo "$deadline | $title | $category | $priority | $notes" >>reminders.txt

    echo "Reminder added successfully."
}

modify_reminder() {
    # echo "Please select the reminder ID you want to modify:"
    grep -in "$id" reminders.txt
    read -p "Reminder ID: " id
    reminder=$(grep "^$id," "$REMINDER_FILE")

    if [ -z "$reminder" ]; then
        echo "Reminder with ID $id not found."
        return 1
    fi

    echo "Enter new values for the following reminder characteristics (leave blank to keep current value):"
    read -p "Reminder title [$REMINDER_TITLE]: " new_title
    read -p "Reminder category [$REMINDER_CATEGORY]: " new_category
    read -p "Reminder priority (high/medium/low) [$REMINDER_PRIORITY]: " new_priority
    read -p "Reminder deadline (YYYY-MM-DD HH:MM) [$REMINDER_DEADLINE]: " new_deadline
    read -p "Reminder notes [$REMINDER_NOTES]: " new_notes

    # Validate inputs
    if [ -n "$new_deadline" ]; then
        validate_datetime "$new_deadline" || return 1
    fi

    # Replace old reminder with new reminder
    if [ -n "$new_title" ]; then
        sed -i "s/^$id,.*/$id,$new_title,$new_category,$new_priority,$new_deadline,$new_notes/" "$REMINDER_FILE"
    fi
    if [ -n "$new_category" ]; then
        sed -i "s/^$id,.*/$id,$REMINDER_TITLE,$new_category,$new_priority,$new_deadline,$new_notes/" "$REMINDER_FILE"
    fi
    if [ -n "$new_priority" ]; then
        sed -i "s/^$id,.*/$id,$REMINDER_TITLE,$new_category,$new_priority,$new_deadline,$new_notes/" "$REMINDER_FILE"
    fi
    if [ -n "$new_deadline" ]; then
        sed -i "s/^$id,.*/$id,$REMINDER_TITLE,$new_category,$new_priority,$new_deadline,$new_notes/" "$REMINDER_FILE"
    fi
    if [ -n "$new_notes" ]; then
        sed -i "s/^$id,.*/$id,$REMINDER_TITLE,$new_category,$new_priority,$new_deadline,$new_notes/" "$REMINDER_FILE"
    fi

    echo "Reminder with ID $id has been modified:"
    grep "^$id," "$REMINDER_FILE"
}

delete_reminder() {
    read -p "Enter a keyword to search for the reminder: " keyword
    results=$(grep -i "$keyword" reminders.txt)

    # Check if there are any reminders with the keyword
    if [[ -z $results ]]; then
        echo "No reminders found with keyword '$keyword'"
        return 1
    fi

    echo "Select the reminder you want to delete by entering its ID:"
    echo "$results" | awk -F '|' '{ printf("%s\t%s\t%s\n", $1, $2, $3) }'

    read -p "Enter the ID of the reminder you want to delete: " id

    # Check if the ID entered is valid
    if [[ ! $id =~ ^[0-9]+$ ]]; then
        echo "Invalid ID. Please enter a valid ID."
        return 1
    fi

    # Check if the ID exists in the reminders file
    if ! grep -q "^$id|" reminders.txt; then
        echo "Reminder with ID $id does not exist."
        return 1
    fi

    # Delete the reminder with the specified ID
    sed -i.bak "/^$id|/d" reminders.txt
    echo "Reminder with ID $id has been deleted."
}

search_commitments() {
    read -p "Enter search query: " query

    # Search for query in events file
    echo "Results from events file:"
    grep -i "$query" "events.txt"

    # Search for query in reminders file
    echo "Results from reminders file:"
    grep -i "$query" "reminders.txt"
}

filter_commitments() {
    # Ask the user which category to filter by
    echo "Which category would you like to filter by?"
    select category in ${CATEGORIES[@]} "Cancel"; do
        case $category in
        "Cancel")
            echo "Filtering cancelled."
            return
            ;;
        *)
            # Use awk to filter events by category and format the output
            awk -v cat="$category" -v OFS="\t" -v FS="\t" '$4 == cat {print $1, $2, $3, $4, $5, $6, $7, $8, $9}' "$EVENT_FILE"
            return
            ;;
        esac
    done
}

import_ics() {
    read -p "Enter the filename of the .ics file to import: " ics_file

    if [ ! -f "$ics_file" ]; then
        echo "Error: File does not exist"
        return 1
    fi

    while read -r line; do
        if [[ "$line" =~ ^SUMMARY: ]]; then
            title=${line#*:}
        elif [[ "$line" =~ ^LOCATION: ]]; then
            location=${line#*:}
        elif [[ "$line" =~ ^DTSTART: ]]; then
            start_time=$(echo "${line#*:}" | sed 's/T/ /; s/Z//')
        elif [[ "$line" =~ ^DTEND: ]]; then
            end_time=$(echo "${line#*:}" | sed 's/T/ /; s/Z//')
        elif [[ "$line" =~ ^DESCRIPTION: ]]; then
            notes=${line#*:}
        elif [[ "$line" =~ ^RRULE:FREQ= ]]; then
            frequency=${line#*=}
        elif [[ "$line" =~ ^PRIORITY: ]]; then
            priority=${line#*:}
        elif [[ "$line" == "END:VEVENT" ]]; then
            # write to events file
            echo "[$(date '+%Y-%m-%d %H:%M:%S')] Added event '$title'" >>"$LOG_FILE"
            echo "$title,$location,$start_time,$end_time,$notes,$frequency,$priority" >>"$EVENT_FILE"
            # reset variables for next event
            title=""
            location=""
            start_time=""
            end_time=""
            notes=""
            frequency=""
            priority=""
        fi
    done <"$ics_file"

    echo "Successfully imported events from $ics_file."
}

export_ics() {
    # Prompt user for name of export file
    read -rp "Enter the name of the export file: " export_file

    # Add .ics extension to export file name if not already included
    if [[ $export_file != *.ics ]]; then
        export_file="$export_file.ics"
    fi

    # Create export file in the same directory as the script
    export_path="$(dirname "${BASH_SOURCE[0]}")/$export_file"
    touch "$export_path"

    # Write events to export file
    echo "BEGIN:VCALENDAR" >>"$export_path"
    echo "VERSION:2.0" >>"$export_path"
    echo "PRODID:-//My Calendar//EN" >>"$export_path"

    while read -r line; do
        # Extract event data
        id=$(echo "$line" | awk -F '|' '{print $1}')
        date=$(echo "$line" | awk -F '|' '{print $2}')
        title=$(echo "$line" | awk -F '|' '{print $3}')
        location=$(echo "$line" | awk -F '|' '{print $4}')
        recurring=$(echo "$line" | awk -F '|' '{print $5}')
        priority=$(echo "$line" | awk -F '|' '{print $6}')
        category=$(echo "$line" | awk -F '|' '{print $7}')
        notes=$(echo "$line" | awk -F '|' '{print $8}')

        # Format event data for export file
        echo "BEGIN:VEVENT" >>"$export_path"
        echo "DTSTART:$date" >>"$export_path"
        echo "SUMMARY:$title" >>"$export_path"
        echo "LOCATION:$location" >>"$export_path"
        echo "RRULE:FREQ=$recurring" >>"$export_path"
        echo "PRIORITY:$priority" >>"$export_path"
        echo "CATEGORIES:$category" >>"$export_path"
        echo "DESCRIPTION:$notes" >>"$export_path"
        echo "END:VEVENT" >>"$export_path"
    done <"$EVENT_FILE"

    # Write reminders to export file
    while read -r line; do
        # Extract reminder data
        id=$(echo "$line" | awk -F '|' '{print $1}')
        date=$(echo "$line" | awk -F '|' '{print $2}')
        title=$(echo "$line" | awk -F '|' '{print $3}')
        recurring=$(echo "$line" | awk -F '|' '{print $4}')
        priority=$(echo "$line" | awk -F '|' '{print $5}')
        notes=$(echo "$line" | awk -F '|' '{print $6}')

        # Format reminder data for export file
        echo "BEGIN:VTODO" >>"$export_path"
        echo "DTSTART:$date" >>"$export_path"
        echo "SUMMARY:$title" >>"$export_path"
        echo "RRULE:FREQ=$recurring" >>"$export_path"
        echo "PRIORITY:$priority" >>"$export_path"
        echo "DESCRIPTION:$notes" >>"$export_path"
        echo "END:VTODO" >>"$export_path"
    done <"$REMINDER_FILE"

    # End the export file
    echo "END:VCALENDAR" >>"$export_path"

    echo "Export to $export_file complete!"
}

notify() {
    local notify_time=$1
    local message=$2
    echo "$message" | at $notify_time
    echo "Notification scheduled for $notify_time: $message"
}

while true; do
    clear
    echo "Notion: Your very own commitments manager"
    echo "1. View commitments"
    echo "2. Add events"
    echo "3. Modify events"
    echo "4. Delete events"
    echo "5. Add reminders"
    echo "6. Modify reminders"
    echo "7. Delete reminders"
    echo "8. Search commitments"
    echo "9. Filter commitments"
    echo "9. Import calendar"
    echo "10. Export calendar"
    echo "11. Quit"

    read -p "Enter your choice: " choice
    case $choice in
    1) view_commitments ;;
    2) add_event ;;
    3) modify_event ;;
    4) delete_event ;;
    5) add_reminder ;;
    6) modify_reminder ;;
    7) delete_reminder ;;
    8) search_commitments ;;
    9) filter_commitments ;;
    10) import_ics ;;
    10) export_ics ;;
    11) exit ;;
    *) echo "Invalid choice. Please try again. " ;;
    esac

    read -p "Press Enter to continue..." dummy

done
