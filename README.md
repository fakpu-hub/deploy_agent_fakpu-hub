# deploy_agent_fakpu-hub

Student Attendance Tracker Deployment Agent

Author: Felix Chifumnanya Akpu
Repository: deploy_agent_fakpu-hub
Environment: Ubuntu 26.04 LTS on WSL

Project Overview

deploy_agent.sh is a Bash deployment tool for the Student Attendance Tracker.

It provides three features:

Deploy application
Run application
Archive logs

It also handles Ctrl+C and Ctrl+Z interruptions during deployment.

Requirements
Bash
Python 3
zip
Ubuntu/WSL or another Unix-like environment
Running the Script
chmod u+x deploy_agent.sh
./deploy_agent.sh

The menu provides:

1. Deploy application
2. Run application
3. Archive logs
4. Exit

Each operation exits after completion.

Deployment

The deployment creates:

attendance_tracker_{name}/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/

The user chooses between two roster options:

Option A: Template

Copies between 1 and 10 students from templates/assets.csv.

The template represents 4 previous sessions, so total_sessions is set to 5.

Option B: Fresh Roster

Generates between 1 and 10 students using predefined student data.

Attendance and absence counts start at 0, and total_sessions is set to 1.

Thresholds

The default thresholds are:

Warning: 75
Failure: 50

Users can keep the defaults by pressing Enter or enter values from 1 to 100.

Running the Application

Select option 2 and enter the project name.

The script runs:

python3 attendance_checker.py
Archiving Logs

Option 3 archives existing logs into:

archives/
├── attendance/
└── absent/

Files are given timestamps such as:

attendance_20260930_103015.log

Original logs remain in reports/.

Missing logs are handled without crashing.

Signal Handling

During deployment:

Ctrl+C triggers SIGINT
Ctrl+Z triggers SIGTSTP

If deployment is interrupted, the incomplete project is compressed into:

attendance_tracker_{name}_archive.zip
Testing

The following were successfully tested:

✅ Deployment
✅ Template roster
✅ Fresh roster
✅ Threshold modification
✅ Running the application
✅ Log archiving
✅ Missing log handling
✅ Ctrl+C interruption
✅ Ctrl+Z interruption
✅ ZIP creation of incomplete deployments
