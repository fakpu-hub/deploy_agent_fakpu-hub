Student Attendance Tracker Deployment Agent

Author: Felix Chifumnanya Akpu · Repo: deploy_agent_fakpu-hub · Env: Ubuntu 26.04 LTS on WSL

Bash tool to deploy, run, and archive logs for the Student Attendance Tracker. Handles Ctrl+C/Ctrl+Z interruptions during deployment.

Requires: Bash, Python 3, zip, Unix-like environment.

Run
Use bash
chmod u+x deploy_agent.sh
./deploy_agent.sh

Enter a number to pick a feature:

1. Deploy application
2. Run application
3. Archive logs
4. Exit

Each option exits after completing.

Deploy (Option 1)

Creates:

attendance_tracker_{name}/
├── attendance_checker.py
├── Helpers/{assets.csv, config.json}
└── reports/

Choose a roster:

A. Copies a Template — 1–10 students from templates/assets.csv, total_sessions = 5
B. Create a Fresh — 1–10 generated students, counts start at 0, total_sessions = 1

Then set thresholds (defaults Warning 75 / Failure 50 — press Enter to keep, or enter 1–100).

Run (Option 2)

Enter the project name; runs python3 attendance_checker.py.

Archive Logs (Option 3)

Moves reports/ logs into timestamped copies under:

archives/
├── attendance/
└── absent/

e.g. attendance_20260930_103015.log. Originals stay in reports/; missing logs don't crash it.

How Interrupt Handling

Ctrl+C (SIGINT) / Ctrl+Z (SIGTSTP) during deployment zip whatever's been created so far into attendance_tracker_{name}_archive.zip, then remove the incomplete directory.

To test: start a deployment, interrupt it mid-way with each signal, then confirm the loose directory is gone and the zip contains only the files created before the interrupt.

Testing

Verified manually: deployment (both roster types), threshold changes, running the app, log archiving + missing-log handling, Ctrl+C/Ctrl+Z interrupts, and zip creation.

Deployed structure was checked with ls -R (or tree) against the expected layout, and config.json was inspected to confirm correct threshold/session values.

Demo Video Link: https://drive.google.com/file/d/1lKCM1rEOzx5CbhJcA19D3oOHBphou3qm/view?usp=drive_link

NOTE: The repository contains test attempts and the information showed in the logs maybe affected and influenced by the previous test attempts.
