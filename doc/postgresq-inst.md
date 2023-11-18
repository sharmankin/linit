Referring to its official page, PostgreSQL is said to be a powerful, open source object-relational database system with over 35 years of active development that has earned it a strong reputation for reliability, feature robustness, and performance. Version 15 was released on 13-10-2022 and builds on the performance improvements of recent releases with noticeable gains for managing workloads in both local and distributed deployments, including improved sorting. More information about the new features in this release are found on this release page.

In the brief guide, we are going to install PostgreSQL 15 on Rocky Linux 9 / AlmaLinux 9 so that you can enjoy the improved performance that your applications will enjoy. Let’s get this done:
Step 1: Prep up your server

In this first step, you know we cannot do anything on an empty slate. Let us clean up our room and get the rudimentary furniture in. We will update the system and install a couple of packages we will need in this session. They include packages like the good editor, file fetching tools and such. Run the following commands to get us going:

```bash
sudo dnf update -y && sudo dnf install curl vim wget -y
```
Step 2: Install and setup the repository RPM

We will need this repository so that we can be able to get our Postgres packages. Install it as follows:

```bash
sudo dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-9-x86_64/pgdg-redhat-repo-latest.noarch.rpm
```

Step 3: Disable the built-in PostgreSQL module

In this step, we are going to disable the default module which will install a different version of Postgres if left unchecked.

```bash
sudo dnf -qy module disable postgresql
```

Step 4: Install PostgreSQL

When you are done disabling the default module, proceed and install PostgreSQL 15 client and server by running the command below:

sudo dnf install -y postgresql15-server

That will install the PostgreSQL server and client together with all other dependencies. When the installation process is complete, let us confirm the version of PostgreSQL installed using the command below:

$ psql --version

psql (PostgreSQL) 15.0

Step 5: Initialize the PostgreSQL Database

Due to policies for Red Hat family distributions, the PostgreSQL installation will not be enabled for automatic start or have the database initialised automatically. To make your database installation complete, you need to initialise your database and make sure it starts at boot time. Let us therefore initialise the PostgreSQL database:

Run the command below:

$ sudo /usr/pgsql-15/bin/postgresql-15-setup initdb
Initializing database ... OK

Next, we will enable Postgres server to start when we boot out machine. Run the following commands to enable and start the database server.

sudo systemctl enable postgresql-15
sudo systemctl start postgresql-15

I know what you are thinking, you can go ahead and check its status!

$ systemctl status postgresql-15
● postgresql-15.service - PostgreSQL 15 database server
     Loaded: loaded (/usr/lib/systemd/system/postgresql-15.service; enabled; vendor preset: disabled)
     Active: active (running) since Fri 2022-10-21 16:32:54 CEST; 6s ago
       Docs: https://www.postgresql.org/docs/15/static/
    Process: 47251 ExecStartPre=/usr/pgsql-15/bin/postgresql-15-check-db-dir ${PGDATA} (code=exited, status=0/SUCCESS)
   Main PID: 47256 (postmaster)
      Tasks: 7 (limit: 11119)
     Memory: 17.5M
        CPU: 39ms
     CGroup: /system.slice/postgresql-15.service
             ├─47256 /usr/pgsql-15/bin/postmaster -D /var/lib/pgsql/15/data/
             ├─47257 "postgres: logger "
             ├─47258 "postgres: checkpointer"

Step 6: Connect to PostgreSQL Database

Next, we will get to see how we shall connect to our database. For some context so that we do not get confused, when PostgreSQL is installed, a default database user called postgres is auto-created. This user has no password by default and hence none is passed during log in. So we will change into the “postgres” user first, then login like so

sudo su - postgres

Then login by running the following postgres command to login

$ psql

And you should be ushered into the database as follows:

psql (15.0)
Type "help" for help.

postgres=#

And now you can continue invoking your Postgres-related commands as well as perform queries at that terminal. But before that, you have already noticed that our server is not safe, we need to authenticate the “postgres” user so that no one can get access to the server just like that.
Step 7: Add a password to the postgres user

As a user with sudo privileges, run the following command to configure postgres user password:

$ sudo passwd postgres
Changing password for user postgres.
New password: <Enter-Password>
Retype new password: <Re-Enter-Password>
passwd: all authentication tokens updated successfully

Let us try changing into postgres user and you will be prompted for the password.

$ sudo su - postgres
Password:
Last login: Sun Oct 22 13:37:38 CEST 2022 on pts/0

Run the client command:

$ psql

psql (15.0)
Type "help" for help.

postgres=#

At this juncture, once you get to switch to postgres user, you can still be able to log into the PostgreSQL database without a password. So, let us change that, right.

While inside the database terminal, run the following query to alter the password:

postgres=# \password
Enter new password for user "postgres": <Enter-Your-Password>
Enter it again: <Re-Enter-Your-Password>

Step 8: Configure Postgres

We are going to allow login to our database from localhost or any other source that you are going to see fit. For that, we are going to edit the configuration file and make some modifications. Open up the configuration file and edit as follows:

$ sudo vim /var/lib/pgsql/15/data/pg_hba.conf

## CHAGE THE FOLLOWNG LINES.
## You can add extra hosts if you like

local   all             all                                     scram-sha-256
# IPv4 local connections:
host    all             all             127.0.0.1/32            scram-sha-256

Hen restart the server

 sudo systemctl restart postgresql-15

After that, let us try to login now

$ psql -U postgres --password -h 127.0.0.1
Password:
psql (15.0)
Type "help" for help.

postgres=#

And right there, we can celebrate!