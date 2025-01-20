# WARNING: Don't edit this file. All change will be removed after each app upgrade

import os

daemon = True
workers = 5
enable_stdio_inheritance = True

# default localhost:8000
bind = "127.0.0.1:__PORT_SEAHUB__"

# Pid
pids_dir = '/opt/seafile/pids'
pidfile = os.path.join(pids_dir, 'seahub.pid')

# for file upload, we need a longer timeout value (default is only 30s, too short)
timeout = 1200

limit_request_line = 8190
