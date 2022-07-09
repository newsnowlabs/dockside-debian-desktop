# dockside-debian-desktop

A basic Debian desktop for [Dockside](https://dockside.io/).

Install to Dockside, by writing the following (example) profile to `/data/config/profiles`:

```
{
   "version": 2,
   "name": "Debian Desktop",
   "active": true,
   "routers": [
      {
         "name": "vnc",
         "prefixes": [ "www" ],
         "domains": [ "*" ],
         "https": { "protocol": "http", "port": 8080 },
         "auth": [ "developer", "owner", "viewer", "user", "containerCookie", "public" ],
      }
   ],
   "networks": [ "bridge" ],
   "images": [ "newsnowlabs/dockside-debian-desktop:latest", "us.gcr.io/dockside-io/dockside-debian-desktop" ],
   "unixusers": ["dockside"],
   "mounts": {
      "tmpfs": [],
      "bind": [],
      "volume": [
         // Use this to share encrypted ssh keys in the named volume among team members.
          { "src": "dockside-ssh-keys", "dst": "/home/{ideUser}/.ssh" } ]
   },
   "lxcfs": true,
   "dockerArgs": [],
   "command": [
      "/bin/sh", "-c", "[ -x \"$(which sudo)\" ] || (apt update && apt -y install sudo); /usr/local/bin/websockify --daemon --web /opt/noVNC-1.3.0/ 0.0.0.0:8080 localhost:5901; vncserver -xstartup /usr/bin/openbox-session -desktop '{container.hostname}' :1; sleep infinity"
   ],
}
```
