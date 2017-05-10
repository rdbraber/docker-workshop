# Creating an Docker image that contains an Oracle 12.2 database

Currently also Oracle supports running their RDMBS in a Docker container, although it's limited to [development](https://github.com/oracle/docker-images/issues/348) environments.

Scripts for creating different Docker images for Oracle software can be found on [Github](https://github.com/oracle/docker-images).

By the way, the step to download the database zip file only works on an student environment I've created. If you want to follow the steps in this document, you can download the zipfile linuxx64_12201_database.zip from [Oracle](http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html). After you've downloaded the file, make sure you place it in the directory ~/docker-images/OracleDatabase/dockerfiles/12.2.0.1.

The first step is to pull these scripts:

~~~
# cd ~
# git clone https://github.com/oracle/docker-images.git
~~~

Go to the directory docker-images/OracleDatabase/dockerfiles/12.2.0.1/ and download the zip file that contains the database software:

~~~
# cd ~/docker-images/OracleDatabase/dockerfiles/12.2.0.1/
# wget http://10.0.2.2/linuxx64_12201_database.zip
~~~

Oracle has provided scripts to create an image, which makes it a lot easier for us. We only have to use this script with a couple of parameters:

~~~
# cd ~/docker-images/OracleDatabase/dockerfiles
# ./buildDockerImage.sh -v 12.2.0.1 -s
~~~

The parameters mean that we are going to create a version 12.2.0.1 (-v) standard (-s) edition image.
This scripts uses the following Dockerfile to create the image. This process takes some time. 

~~~
# LICENSE CDDL 1.0 + GPL 2.0
#
# Copyright (c) 1982-2017 Oracle and/or its affiliates. All rights reserved.
#
# ORACLE DOCKERFILES PROJECT
# --------------------------
# This is the Dockerfile for Oracle Database 12c Release 1 Enterprise Edition
#
# REQUIRED FILES TO BUILD THIS IMAGE
# ----------------------------------
# (1) linuxx64_12201_database.zip
#     Download Oracle Database 12c Release 12 Standard Edition 2 for Linux x64
#     from http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html
#
# HOW TO BUILD THIS IMAGE
# -----------------------
# Put all downloaded files in the same directory as this Dockerfile
# Run:
#      $ docker build -t oracle/database:12.2.0.1-se2 .
#
# Pull base image
# ---------------
FROM oraclelinux:7-slim

# Maintainer
# ----------
MAINTAINER Gerald Venzl <gerald.venzl@oracle.com>

# Environment variables required for this build (do NOT change)
# -------------------------------------------------------------
ENV ORACLE_BASE=/opt/oracle \
    ORACLE_HOME=/opt/oracle/product/12.2.0.1/dbhome_1 \
    INSTALL_FILE_1="linuxx64_12201_database.zip" \
    INSTALL_RSP="db_inst.rsp" \
    CONFIG_RSP="dbca.rsp.tmpl" \
    PWD_FILE="setPassword.sh" \
    PERL_INSTALL_FILE="installPerl.sh" \
    RUN_FILE="runOracle.sh" \
    START_FILE="startDB.sh" \
    CREATE_DB_FILE="createDB.sh" \
    SETUP_LINUX_FILE="setupLinuxEnv.sh" \
    CHECK_SPACE_FILE="checkSpace.sh" \
    INSTALL_DB_BINARIES_FILE="installDBBinaries.sh"

# Use second ENV so that variable get substituted
ENV INSTALL_DIR=$ORACLE_BASE/install \
    PATH=$ORACLE_HOME/bin:$ORACLE_HOME/OPatch/:/usr/sbin:$PATH \
    LD_LIBRARY_PATH=$ORACLE_HOME/lib:/usr/lib \
    CLASSPATH=$ORACLE_HOME/jlib:$ORACLE_HOME/rdbms/jlib

# Copy binaries
# -------------
COPY $INSTALL_FILE_1 $INSTALL_RSP $PERL_INSTALL_FILE $SETUP_LINUX_FILE $CHECK_SPACE_FILE $INSTALL_DB_BINARIES_FILE $INSTALL_DIR/
COPY $RUN_FILE $START_FILE $CREATE_DB_FILE $CONFIG_RSP $PWD_FILE $ORACLE_BASE/

RUN chmod ug+x $INSTALL_DIR/*.sh && \
    sync && \
    $INSTALL_DIR/$CHECK_SPACE_FILE && \
    $INSTALL_DIR/$SETUP_LINUX_FILE

# Install DB software binaries
USER oracle
RUN $INSTALL_DIR/$INSTALL_DB_BINARIES_FILE SE2

USER root
RUN $ORACLE_BASE/oraInventory/orainstRoot.sh && \
    $ORACLE_HOME/root.sh && \
    rm -rf $INSTALL_DIR

USER oracle
WORKDIR /home/oracle

VOLUME ["$ORACLE_BASE/oradata"]
EXPOSE 1521 5500

# Define default command to start Oracle Database.
CMD exec $ORACLE_BASE/$RUN_FILE
~~~

After the script is finished you should have a new image:

~~~
# docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
oracle/database     12.2.0.1-se2        fea916f6593f        2 minutes ago       14.8GB
~~~

We should now be able to start the container:

~~~
# docker run -d --name OracleDB --shm-size=1g -p 1521:1521 -p 8080:8080 -e ORACLE_PWD=Oracle01 oracle/database:12.2.0.1-se2
~~~

First see if the container is really started:

~~~
# docker ps -a
CONTAINER ID        IMAGE                          COMMAND                  CREATED              STATUS              PORTS                                                      NAMES
72bcf2601515        oracle/database:12.2.0.1-se2   "/bin/sh -c 'exec ..."   About a minute ago   Up About a minute   0.0.0.0:1521->1521/tcp, 0.0.0.0:8080->8080/tcp, 5500/tcp   OracleDB
~~~

The first time the container is started, a new database is created. The datafiles will be placed inside the volume specified in the Dockerfile. 

You can watch the progress of the creation of the database with the `docker logs -f` command:

~~~
# docker logs -f OracleDB
ORACLE PASSWORD FOR SYS, SYSTEM AND PDBADMIN: Oracle01

LSNRCTL for Linux: Version 12.2.0.1.0 - Production on 10-MAY-2017 08:38:15

Copyright (c) 1991, 2016, Oracle.  All rights reserved.

Starting /opt/oracle/product/12.2.0.1/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 12.2.0.1.0 - Production
System parameter file is /opt/oracle/product/12.2.0.1/dbhome_1/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/72bcf2601515/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 12.2.0.1.0 - Production
Start Date                10-MAY-2017 08:38:15
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/product/12.2.0.1/dbhome_1/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/72bcf2601515/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))
The listener supports no services
The command completed successfully
[WARNING] [DBT-10102] The listener configuration is not selected for the database. EM DB Express URL will not be accessible.
   CAUSE: The database should be registered with a listener in order to access the EM DB Express URL.
   ACTION: Select a listener to be registered or created with the database.
Copying database files
1% complete
13% complete
25% complete
Creating and starting Oracle instance
26% complete
30% complete
31% complete
35% complete
38% complete
39% complete
41% complete
Completing Database Creation
42% complete
43% complete
44% complete
46% complete
47% complete
50% complete
Creating Pluggable Databases
55% complete
75% complete
Executing Post Configuration Actions
100% complete
Look at the log file "/opt/oracle/cfgtoollogs/dbca/ORCLCDB/ORCLCDB.log" for further details.

SQL*Plus: Release 12.2.0.1.0 Production on Wed May 10 08:44:09 2017

Copyright (c) 1982, 2016, Oracle.  All rights reserved.


Connected to:
Oracle Database 12c Standard Edition Release 12.2.0.1.0 - 64bit Production

SQL>
System altered.

SQL>
Pluggable database altered.

SQL> Disconnected from Oracle Database 12c Standard Edition Release 12.2.0.1.0 - 64bit Production
#########################
DATABASE IS READY TO USE!
#########################
Completed: alter pluggable database ORCLPDB1 open
2017-05-10T08:44:08.824250+00:00
ORCLPDB1(3):CREATE SMALLFILE TABLESPACE "USERS" LOGGING  DATAFILE  '/opt/oracle/oradata/ORCLCDB/ORCLPDB1/users01.dbf' SIZE 5M REUSE AUTOEXTEND ON NEXT  1280K MAXSIZE UNLIMITED  EXTENT MANAGEMENT LOCAL  SEGMENT SPACE MANAGEMENT  AUTO
ORCLPDB1(3):Completed: CREATE SMALLFILE TABLESPACE "USERS" LOGGING  DATAFILE  '/opt/oracle/oradata/ORCLCDB/ORCLPDB1/users01.dbf' SIZE 5M REUSE AUTOEXTEND ON NEXT  1280K MAXSIZE UNLIMITED  EXTENT MANAGEMENT LOCAL  SEGMENT SPACE MANAGEMENT  AUTO
ORCLPDB1(3):ALTER DATABASE DEFAULT TABLESPACE "USERS"
ORCLPDB1(3):Completed: ALTER DATABASE DEFAULT TABLESPACE "USERS"
2017-05-10T08:44:09.651901+00:00
ALTER SYSTEM SET control_files='/opt/oracle/oradata/ORCLCDB/control01.ctl' SCOPE=SPFILE;
   ALTER PLUGGABLE DATABASE ORCLPDB1 SAVE STATE
Completed:    ALTER PLUGGABLE DATABASE ORCLPDB1 SAVE STATE
~~~

Once the creation of the database is started, we should be able to connect to it with sqlplus, which is also in the same container:

~~~
# docker exec -ti OracleDB sqlplus system@ORCLCDB

SQL*Plus: Release 12.2.0.1.0 Production on Wed May 10 08:48:32 2017

Copyright (c) 1982, 2016, Oracle.  All rights reserved.

Enter password:

Connected to:
Oracle Database 12c Standard Edition Release 12.2.0.1.0 - 64bit Production

SQL>
~~~

We should now be able to query the database:

~~~
SQL> select name from v$database;

NAME
---------
ORCLCDB
~~~

If we would like to stop the container, use the `docker stop` command:

~~~
# docker stop OracleDB
OracleDB
~~~

Now if we start the container again, it should start a lot faster than the first time, since the database doesn't have to be created:

~~~
# docker start OracleDB
OracleDB
# docker logs -f OracleDB
Starting /opt/oracle/product/12.2.0.1/dbhome_1/bin/tnslsnr: please wait...

TNSLSNR for Linux: Version 12.2.0.1.0 - Production
System parameter file is /opt/oracle/product/12.2.0.1/dbhome_1/network/admin/listener.ora
Log messages written to /opt/oracle/diag/tnslsnr/72bcf2601515/listener/alert/log.xml
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1)))
Listening on: (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))

Connecting to (DESCRIPTION=(ADDRESS=(PROTOCOL=IPC)(KEY=EXTPROC1)))
STATUS of the LISTENER
------------------------
Alias                     LISTENER
Version                   TNSLSNR for Linux: Version 12.2.0.1.0 - Production
Start Date                10-MAY-2017 08:57:12
Uptime                    0 days 0 hr. 0 min. 0 sec
Trace Level               off
Security                  ON: Local OS Authentication
SNMP                      OFF
Listener Parameter File   /opt/oracle/product/12.2.0.1/dbhome_1/network/admin/listener.ora
Listener Log File         /opt/oracle/diag/tnslsnr/72bcf2601515/listener/alert/log.xml
Listening Endpoints Summary...
  (DESCRIPTION=(ADDRESS=(PROTOCOL=ipc)(KEY=EXTPROC1)))
  (DESCRIPTION=(ADDRESS=(PROTOCOL=tcp)(HOST=0.0.0.0)(PORT=1521)))
The listener supports no services
The command completed successfully

SQL*Plus: Release 12.2.0.1.0 Production on Wed May 10 08:57:12 2017

Copyright (c) 1982, 2016, Oracle.  All rights reserved.

Connected to an idle instance.

SQL> ORACLE instance started.

Total System Global Area 1610612736 bytes
Fixed Size		    8793304 bytes
Variable Size		  520094504 bytes
Database Buffers	 1073741824 bytes
Redo Buffers		    7983104 bytes
Database mounted.
Database opened.
SQL> Disconnected from Oracle Database 12c Standard Edition Release 12.2.0.1.0 - 64bit Production
#########################
DATABASE IS READY TO USE!
#########################
db_recovery_file_dest_size of 12780 MB is 0.00% used. This is a
user-specified limit on the amount of space that will be used by this
database for recovery-related files, and does not reflect the amount of
space available in the underlying filesystem or ASM diskgroup.
2017-05-10T08:57:21.223785+00:00
Pluggable database ORCLPDB1 opened read write
Starting background process CJQ0
2017-05-10T08:57:21.862410+00:00
CJQ0 started with pid=38, OS id=141
Completed: ALTER DATABASE OPEN
~~~

If you would like the data to be persistent, you could use the volume (-v) parameter when you create the container. Create the oracle user on the host that runs Docker with the same uid and gid as the one in the container:

~~~
# groupadd -g 54321 oinstall
# groupadd -g 54322 dba
# useradd -u 54321 -g oinstall -G dba oracle
~~~

This should also have created the home directory for the oracle account:

~~~
# ls -ld /home/oracle
drwx------. 5 oracle dba 119 May 10 09:44 /home/oracle
~~~

Now start the container with the following extra parameter (-v):

~~~
# docker run -d --name OracleDB --shm-size=1g -p 1521:1521 -p 8080:8080 -e ORACLE_PWD=Oracle01 -v /home/oracle:/opt/oracle/oradata oracle/database:12.2.0.1-se2
~~~

The database is created again, but now the datafiles are created in the directory /home/oracle and are persistent:

~~~
# ls -l /home/oracle/
total 0
drwxr-xr-x. 3 oracle dba  21 May 10 09:44 dbconfig
drwxr-x---. 3 oracle dba  21 May 10 09:38 fast_recovery_area
drwxr-x---. 4 oracle dba 210 May 10 09:40 ORCLCDB
~~~

If we now would stop the container, delete it and start it again, the same datafiles will be used and the start of the container is a lot faster:

~~~
# docker stop OracleDB
OracleDB
# docker rm OracleDB
OracleDB
# docker run -d --name OracleDB --shm-size=1g -p 1521:1521 -p 8080:8080 -e ORACLE_PWD=Oracle01 -v /home/oracle:/opt/oracle/oradata oracle/database:12.2.0.1-se2
~~~
