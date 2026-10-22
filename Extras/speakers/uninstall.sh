#!/bin/bash
for l in com.blade18.speakers com.blade18.speakers.wake; do
  sudo launchctl bootout system /Library/LaunchDaemons/$l.plist 2>/dev/null || true
  sudo mv /Library/LaunchDaemons/$l.plist /tmp/ 2>/dev/null || true
done
sudo mv /usr/local/bin/blade18-speakers.sh /tmp/ 2>/dev/null || true
echo "removed (files moved to /tmp)"
