#!/bin/sh

# Wait for d-bus to start
while [ ! -f '/var/run/dbus.pid' ]; do
  echo "Waiting for D-Bus to start..."
  sleep 1
done

# Set D-Bus environment variables
export DBUS_SESSION_BUS_ADDRESS=unix:path=/var/run/dbus.socket
export DBUS_SESSION_BUS_PID=`cat /var/run/dbus.pid`

echo "Starting VideoLAN Client."

# Start VLC with dummy interface and dbus enabled
exec /usr/bin/vlc \
  --verbose \
  --config /etc/vlcrc \
  --no-interact \
  --intf dummy \
  --control dbus \
  --no-plugins-cache
