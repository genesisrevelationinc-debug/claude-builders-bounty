#!/bin/bash

echo "Fetching latest commits since last tag..."
git log --oneline $(git describe --tags --abbrev=0 @~)..@ > /tmp/commits.txt

echo "Generating changelog..."
python3 -c "
import subprocess
import shlex

def get_git_log():
    # Get commits since last tag
    result = subprocess.run(shlex.split('git log --onetch
    return result.stdout.decode('utf-8')
"

def parse_commit_messages(commit_messages):
    return commit_messages.split()

def get_last_tag():
    result = subprocess.run(shlex.split('git describe --tags --abbrev=0 @~'), capture_output=True, text=True)
    return result.returncode == 0 and result.stdout.decode('utf-8').strip() or None

def main():
    # Get the last tag
    last_tag = get_last_tag()
    if not last_tag:
        print('No tags found')
        return
    
    # Get the commits since the last tag
    commit_messages = parse_commit_messages  # Placeholder for actual commit messages
    return commit_messages
"
    return

if __name__ == '__main__':
    main()