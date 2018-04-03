#! /bin/sh

### BEGIN INIT INFO
# Provides:          listen-for-shutdown.py
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
### END INIT INFO

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    echo "Starting alligator"
    nohup python3 /usr/local/bin/alligator/main.py > /dev/null&
    ;;
  stop)
    echo "Stopping alligator"
    pkill -f /usr/local/bin/alligator/main.py
    ;;
  *)
    echo "Usage: /etc/init.d/alligator {start|stop}"
    exit 1
    ;;
esac

exit 0