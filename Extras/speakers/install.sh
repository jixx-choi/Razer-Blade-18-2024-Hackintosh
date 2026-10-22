#!/bin/bash
# Installs the speaker init script, runs it at boot, and (if sleepwatcher is installed) after wake.
set -e
cd "$(dirname "$0")"
sudo mkdir -p /usr/local/bin
sudo install -m 755 blade18-speakers.sh /usr/local/bin/blade18-speakers.sh
sudo install -m 644 -o root -g wheel com.blade18.speakers.plist /Library/LaunchDaemons/com.blade18.speakers.plist
sudo launchctl bootout system /Library/LaunchDaemons/com.blade18.speakers.plist 2>/dev/null || true
sudo launchctl bootstrap system /Library/LaunchDaemons/com.blade18.speakers.plist

SW=$(command -v sleepwatcher || true)
[ -z "$SW" ] && for p in /usr/local/sbin/sleepwatcher /opt/homebrew/sbin/sleepwatcher; do [ -x "$p" ] && SW=$p; done
if [ -n "$SW" ]; then
  cat > /tmp/com.blade18.speakers.wake.plist <<PL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Label</key><string>com.blade18.speakers.wake</string>
  <key>ProgramArguments</key><array>
    <string>$SW</string><string>-w</string><string>/usr/local/bin/blade18-speakers.sh</string>
  </array>
  <key>RunAtLoad</key><true/><key>KeepAlive</key><true/>
</dict></plist>
PL
  sudo install -m 644 -o root -g wheel /tmp/com.blade18.speakers.wake.plist /Library/LaunchDaemons/
  sudo launchctl bootout system /Library/LaunchDaemons/com.blade18.speakers.wake.plist 2>/dev/null || true
  sudo launchctl bootstrap system /Library/LaunchDaemons/com.blade18.speakers.wake.plist
  echo "wake hook installed ($SW)"
else
  echo "sleepwatcher not found: speakers are initialised at boot only (brew install sleepwatcher, then run this again)"
fi
echo "installed. log: /var/log/blade18-speakers.log"
