#!/usr/bin/env python3
"""
Pre-tool-use hook that blocks destructive bash commands.
Intercepts dangerous commands before execution and logs blocked attempts.

Installation:
  mkdir -p ~/.claude/hooks
  cp pre_tool_use.py ~/.claude/hooks/pre_tool_use.py
  chmod +x ~/.claude/hooks/pre_tool_use.py
"""
import json, os, re, sys
from datetime import datetime, timezone

DANGEROUS_PATTERNS = [
    (r'rm\s+-rf\s+/', 'Blocking rm -rf / - would delete system files'),
    (r'rm\s+-rf\s+\S+', 'Blocking rm -rf - would recursively delete files'),
    (r'DROP\s+TABLE', 'Blocking DROP TABLE - would destroy database table'),
    (r'git\s+push\s+--force', 'Blocking git push --force - would overwrite remote history'),
    (r'TRUNCATE\s+', 'Blocking TRUNCATE - would empty database table'),
    (r'DELETE\s+FROM\s+\w+\s*;', 'Blocking DELETE FROM without WHERE - would delete all rows'),
    (r'DELETE\s+FROM\s+\w+\s+WHERE\s+1\s*=\s*1', 'Blocking DELETE FROM WHERE 1=1'),
    (r':\(\)\{\s*:\|:&\s*\};:', 'Blocking fork bomb - would crash system'),
    (r'mkfs\.\w+\s+/dev/', 'Blocking mkfs on device - would format disk'),
    (r'>\s*/dev/sd', 'Blocking redirect to device - could corrupt disk'),
]

LOG_FILE = os.path.expanduser('~/.claude/hooks/blocked.log')

def ensure_log_dir():
    os.makedirs(os.path.dirname(LOG_FILE), exist_ok=True)

def log_blocked(command, reason):
    ensure_log_dir()
    timestamp = datetime.now(timezone.utc).isoformat()
    project_path = os.getcwd()
    log_entry = f"[{timestamp}] BLOCKED | cmd={command} | reason={reason} | path={project_path}\n"
    with open(LOG_FILE, 'a', encoding='utf-8') as f:
        f.write(log_entry)

def check_command(command):
    for pattern, reason in DANGEROUS_PATTERNS:
        if re.search(pattern, command, re.IGNORECASE):
            return True, reason
    return False, ''

def main():
    try:
        input_data = json.loads(sys.stdin.read()) if not sys.stdin.isatty() else {}
    except json.JSONDecodeError:
        input_data = {}
    
    command = input_data.get('command', '') or input_data.get('input', '')
    if not command:
        command = os.environ.get('CLAUDE_COMMAND', '')
    
    if not command:
        print(json.dumps({"allowed": True, "reason": "No command to check"}))
        return
    
    is_dangerous, reason = check_command(command)
    
    if is_dangerous:
        log_blocked(command, reason)
        print(json.dumps({
            "allowed": False,
            "reason": reason,
            "command": command,
            "suggestion": "This command matches a dangerous pattern. Use a safer alternative."
        }))
    else:
        print(json.dumps({"allowed": True, "reason": "Command is safe"}))

if __name__ == '__main__':
    main()
