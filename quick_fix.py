#!/usr/bin/env python3

# Read the file content
with open('/app/app.py.backup2', 'r') as f:
    content = f.read()

# Replace the problematic lines
content = content.replace(
    'if is_duplicate_notification(pushkey, notification):',
    'if False and is_duplicate_notification(pushkey, notification):'
)

content = content.replace(
    'if is_rate_limited(pushkey):',
    'if False and is_rate_limited(pushkey):'
)

# Write back to the file
with open('/app/app.py', 'w') as f:
    f.write(content)

print("✅ Fixed duplicate detection")
