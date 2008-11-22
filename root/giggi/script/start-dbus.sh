#!/bin/sh

# Make run directory, if it doesn't exist
mkdir -p /var/run

# Create the machine identifier
mkdir -p /var/lib/dbus/
if [ ! -f  /var/lib/dbus/machine-id ]; then
  echo "Setting D-Bus Machine ID."
  dbus-uuidgen > /var/lib/dbus/machine-id
fi

# Delete old PID files
if [ -f /var/run/dbus.pid ]; then
  echo "Removing old D-Bus process ID file."
  rm /var/run/dbus.pid
fi

echo "Starting D-Bus daemon."

exec dbus-daemon --config-file=/etc/dbus.conf --nofork
