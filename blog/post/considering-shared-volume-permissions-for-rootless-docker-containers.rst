.. title:: Considering shared volume permissions for rootless docker containers
.. slug::
.. date:: 2025-01-25 15:26:57 UTC
.. description::

I am writing this post after a long interval. I hope I can keep it up!
This is a just hint for me for the future :)

Things need to be considered
----------------------------

I have a server with a web service running in Docker containers.
The service is mainly just for me, so I simply manage the resources with Docker
Compose.

By updating the version of the Docker images for new changes, the containers
started working in Docker's rootless mode. Specifically, these containers
now work with `UID` and `GID` both set to `1000` by default.

That's a good thing for security! But I needed to figure out how to change the
ownership of the volumes shared between these containers and the host.

The `docker-compose.yaml` is something like this:

.. code:: yaml

   services:
     xxx-server:
       image: grauwoelfchen/xxx-server:v4.0.4
       ...
       volumes:
         - xxx-log:/var/log/xxx/
         - xxx-data:/var/data/xxx/
       ...

     xxx-worker:
       image: grauwoelfchen/xxx-worker:v4.0.4
       ...
       volumes:
         - xxx-log:/var/log/xxx/
       ...

   volumes:
     xxx-log:
       driver: local
       driver_opts:
         o: bind
         type: none
         device: /var/lib/xxx/log

     xxx-data:
       driver: local
       driver_opts:
         o: bind
         type: none
         device: /var/lib/xxx/data
    ...

Simply put, I am just mounting these directories on `/var/lib/xxx/{yyy,zzz}`
into these containers.


What should I do?
-----------------

To be able to run containers with non-users, I don't want to set the
container user to `root`. And I don't want to directly share the ownership of
the directories between the container user and the user (UID: 1000) on host.

Is there a good practice for this?

It seems that we cannot specify the ownership of these volumes on
mount (as opposed to mounting any physical volumes on host). I couldn't find
any way or options.

On the other hand, I also want to restrict the access to the actual
directories on host. Before this change, this was only available for `root`, as
the containers worked with `root`.


The solution
------------

It turns out that (as a compromise) I ended up creating a system-like user only
for this service on host and gave it the access to the directories, and made it
to the container user.

.. code:: zsh

   # e.g. 1007
   % sudo useradd \
     --no-create-home \
     --user-group \
     --uid 1007 \
     --shell /sbin/nologin \
     --home-dir /dev/null \
     --comment "" \
     <NAME>

   % cat docker-compose.yaml
   ...
   services:
     xxx-server:
       image: grauwoelfchen/xxx-server:v4.0.4
       ...
       user: "1007:1007"
       ...
       volumes:
         - xxx-log:/var/log/xxx/
         - xxx-data:/var/data/xxx/
       ...

     xxx-worker:
       image: grauwoelfchen/xxx-worker:v4.0.4
       ...
       user: "1007:1007"
       ...
       volumes:
         - xxx-log:/var/log/xxx/
       ...


Since I wanted to use something larger than `1000` for this user's UID/GID
(for a conventional reason), I created a normal user without login, instead of
the system user.

According to `man`, the UID/GID values for system user seem to be limited to
less than `101` by default.

.. code:: text

	 SYS_GID_MAX (number), SYS_GID_MIN (number)
			 Range of group IDs used for the creation of system groups by useradd, groupadd, or newusers.

			 The default value for SYS_GID_MIN (resp.  SYS_GID_MAX) is 101 (resp.  GID_MIN-1).

	 SYS_UID_MAX (number), SYS_UID_MIN (number)
			 Range of user IDs used for the creation of system users by useradd or newusers.

			 The default value for SYS_UID_MIN (resp.  SYS_UID_MAX) is 101 (resp.  UID_MIN-1).

This special user has access to the directories:

.. code:: zsh

   % cat /etc/passwd | less
   ...
   <USER>:x:1007:1007:<COMMENT>:/dev/null:/sbin/nologin

   % ch /var/lib/xxx
   % sudo chown -R <USER>:wheel .

   % ls -la /var/lib/xxx
   total 24
   drwxr-xr-x  5 <USER> wheel 4096 Jan 25 14:01 .
   drwxr-xr-x 30 root   root  4096 Jan  6 18:01 ..
   drwxr-xr-x  2 <USER> wheel 4096 May  4  2024 .cache
   drwxr-xr--  4 <USER> wheel 4096 May 21  2024 data
   drwxr-xr--  2 <USER> wheel 4096 Jan 25 13:48 log


The containers now work without any permission problems.
If I find a better way, I'll update this.
