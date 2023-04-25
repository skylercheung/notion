Notion: managing events and reminders

How to use: from a terminal window in the same folder as the .sh script, run ./notion.sh
	    follow the guide, entering numbers for each feature

Brief description of each feature/function

- view_commitments(): This function displays all existing events and reminders.
- add_event(): This function prompts the user for details and add a new event to the commitments list.
- modify_event(): This function allows the user to modify an existing event.
- delete_event(): This function allows the user to delete an existing event.
- add_reminder(): This function prompts the user for details and add a new reminder to the commitments list.
- modify_reminder(): This function allows the user to modify an existing reminder.
- delete_reminder(): This function allows the user to delete an existing reminder.
- search_commitments(): This function allows the user to search for specific events or reminders based on their title, location, or category.
- filter_commitments(): This function allows the user to filter events or reminders based on their characteristics such as date/time, priority, recurring, or category.
- import_ics(): This function reads calendar information from .ics format and add events and reminders to the commitments list.
- export_ics(): This function exports all events and reminders into .ics format.

Known bugs:
- deleting events/reminders (something to do with sed?)
- exporting/importing .ics (does not complete the output file)
- modifying reminders (faulty grep command line?)

Future:
- combining the search and filter capability
- better UI (not just text-based)
- thoroughly testing notifications

