#!/bin/bash
# This is a sample for unattended install for SQL Server on Linux
# Change sqlunattended.conf to control install params
# Script will detect distribution Rhel/SUSE/Ubuntu  and add respostories accordingly
# Supported Platforms: https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-release-notes

sqlinstall_rhel()
{
echo Adding Microsoft repositories...

#remove existing repo
sudo rm -rf /etc/yum.repos.d/mssql-server.repo
# Add Repo from config file
sudo curl -o /etc/yum.repos.d/mssql-server.repo $RHEL_SQLSERVER_REPO
sudo curl -o /etc/yum.repos.d/msprod.repo $RHEL_SQLTOOLS_REPO


echo Installing SQL Server...
sudo yum install -y mssql-server

echo Running mssql-conf setup...
INSTALL_CMD+='/opt/mssql/bin/mssql-conf -n setup accept-eula'
eval $INSTALL_CMD

#sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD \
#     MSSQL_PID=$MSSQL_PID \
#     /opt/mssql/bin/mssql-conf -n setup accept-eula

echo Installing mssql-tools and unixODBC developer...
sudo ACCEPT_EULA=Y yum install -y mssql-tools unixODBC-devel

# Add SQL Server tools to the path by default:
echo Adding SQL Server tools to your path...
echo PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

# Optional SQL Server Agent installation:
if [[ $INSTALL_SQL_AGENT == [Yy][eE][sS]  ]];
then
  echo Installing SQL Server Agent...
  sudo yum install -y mssql-server-agent
fi

# Optional SQL Server Full Text Search installation:
if [[ $INSTALL_SQL_FULLTEXT == [Yy][eE][sS]  ]]
then
    echo Installing SQL Server Full-Text Search...
    sudo yum install -y mssql-server-fts
fi
if [[ $INSTALL_HA == [Yy][eE][sS]  ]];
then
  echo Installing SQL Server HA..
  sudo yum install -y pacemaker pcs fence-agents-all resource-agents
  sudo yum install -y mssql-server-ha
fi

# Configure firewall to allow TCP port 1433:
echo Configuring firewall to allow traffic on port $SQL_PORT...
FIREWALL_CMD="sudo firewall-cmd --zone=public --add-port=$SQL_PORT/tcp --permanent"
eval $FIREWALL_CMD
#sudo firewall-cmd --zone=public --add-port=1433/tcp --permanent
sudo firewall-cmd --reload

}

sqlinstall_ubuntu()
{
# remove existing preview repo
  sudo add-apt-repository -r 'deb [arch=amd64] https://packages.microsoft.com/ubuntu/16.04/mssql-server xenial main'

# add Repo from config file
  sudo curl https://packages.microsoft.com/keys/microsoft.asc | sudo apt-key add -
  repoargs="$(curl $UBUNTU_SQLSERVER_REPO)"
  sudo add-apt-repository -r "${repoargs}"
  sudo add-apt-repository "${repoargs}"
# repoargs="$(curl https://packages.microsoft.com/config/ubuntu/16.04/prod.list)"
  repoargs="$(curl $UBUNTU_SQLTOOLS_REPO)"
  sudo add-apt-repository -r "${repoargs}"
  sudo add-apt-repository "${repoargs}"

  echo Running apt-get update -y...
  sudo apt-get update -y 

  echo Installing SQL Server...
  sudo apt-get install -y mssql-server

  echo Running mssql-conf setup...
  INSTALL_CMD+='/opt/mssql/bin/mssql-conf -n setup accept-eula'
  eval $INSTALL_CMD

  #sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD \
#	     MSSQL_PID=$MSSQL_PID \
 #                 /opt/mssql/bin/mssql-conf -n setup accept-eula

  echo Installing mssql-tools and unixODBC developer...
  sudo ACCEPT_EULA=Y apt-get install -y mssql-tools unixodbc-dev

  # Add SQL Server tools to the path by default:
  echo Adding SQL Server tools to your path...
  echo PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
  echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

  # Optional SQL Server Agent installation:
 if [[ $INSTALL_SQL_AGENT == [Yy][eE][sS]  ]];
 then
	  echo Installing SQL Server Agent...
	    sudo apt-get install -y mssql-server-agent
 fi

# Optional SQL Server Full Text Search installation:
  if [[ $INSTALL_SQL_FULLTEXT == [Yy][eE][sS] ]];
  then
    echo Installing SQL Server Full-Text Search...
    sudo apt-get install -y mssql-server-fts
  fi

  if [[ $INSTALL_HA == [Yy][eE][sS]  ]];
  then
     echo Installing SQL Server HA..
     sudo apt-get install -y pacemaker pcs fence-agents-all resource-agents
     sudo apt-get install -y mssql-server-ha
  fi 

  # Configure firewall to allow TCP port 1433:
  echo Configuring UFW to allow traffic on port $SQL_PORT...
 
   FIREWALL_CMD="sudo ufw allow $SQL_PORT/tcp"
   eval $FIREWALL_CMD 
   #sudo ufw allow 1433/tcp
   sudo ufw reload

}

sqlinstall_sles()
{
echo Adding Microsoft repositories...

#remove existing repo 
sudo zypper removerepo 'packages-microsoft-com-mssql-server'
#add repo from Config file.
sudo zypper addrepo -fc $SLES_SQLSERVER_REPO
sudo zypper addrepo -fc $SLES_SQLTOOLS_REPO
sudo zypper --gpg-auto-import-keys refresh

#Add the SLES v12 SP2 SDK to obtain libsss_nss_idmap0
sudo SUSEConnect -p sle-sdk/12.2/x86_64

echo Installing SQL Server...
sudo zypper install -y mssql-server

echo Running mssql-conf setup...
INSTALL_CMD+='/opt/mssql/bin/mssql-conf -n setup accept-eula'
eval $INSTALL_CMD
#sudo MSSQL_SA_PASSWORD=$MSSQL_SA_PASSWORD \
#     MSSQL_PID=$MSSQL_PID \
#     /opt/mssql/bin/mssql-conf -n setup accept-eula

echo Installing mssql-tools and unixODBC developer...
sudo ACCEPT_EULA=Y zypper install -y mssql-tools unixODBC-devel

# Add SQL Server tools to the path by default:
echo Adding SQL Server tools to your path...
echo PATH="$PATH:/opt/mssql-tools/bin" >> ~/.bash_profile
echo 'export PATH="$PATH:/opt/mssql-tools/bin"' >> ~/.bashrc

if [[ $INSTALL_SQL_AGENT == [Yy][eE][sS]  ]];
then
 echo Installing SQL Server Agent...
  sudo zypper install -y mssql-server-agent
fi

if [[ $INSTALL_SQL_AGENT == [Yy][eE][sS]  ]];
then
  echo Installing SQL Server Full-Text Search...
    sudo zypper install -y mssql-server-fts
fi
if [[ $INSTALL_HA == [Yy][eE][sS]  ]];
then
   echo Installing SQL Server HA..
   echo "Please install the SUSE Linux High availability extension first "
   echo "https://www.suse.com/documentation/sle-ha-12/singlehtml/install-quick/install-quick.html#sec.ha.inst.quick.installation"
    sudo zypper install -y mssql-server-ha
fi


# Configure firewall to allow TCP port 1433:
echo Configuring SuSEfirewall2 to allow traffic on port $SQL_PORT...
FIREWALL_CMD="sudo SuSEfirewall2 open INT TCP $SQL_PORT"
eval $FIREWALL_CMD
#sudo SuSEfirewall2 open INT TCP 1433
sudo SuSEfirewall2 stop
sudo SuSEfirewall2 start
}


sql_connect()
{
  echo "Testing SQL Connectivity to $SQL_SERVER_NAME..."
        MAX_ATTEMPTS=3
        attempt_num=1
        sqlconnect=0
        while [ $attempt_num -le $MAX_ATTEMPTS ]
        do
		echo ""
                /opt/mssql-tools/bin/sqlcmd -S$SQL_SERVER_NAME -Usa -P$MSSQL_SA_PASSWORD -Q"select @@version" 2>&1 >/dev/null
                if [[ $? -eq 0 ]]; then
                        sqlconnect=1
                        echo "SQL Connectivity test suceeded..."
                        break
                else
                        echo "Connectivity to SQL Attempt ${attempt_num} of ${MAX_ATTEMPTS}, Retrying"
                fi
                attempt_num=$(( attempt_num + 1 ))

	done

return $sqlconnect
}

sql_auto_configure_tempdb()
{
 #Move current location of Tempdb files and configure tempdb additional files
  cp -f ./AddTempdb.template ./AddTempdb.sql 
  echo "Moving Tempdb files to $SQL_TEMPDB_DATA_FOLDER and $SQL_TEMPDB_LOG_FOLDER ..."
  sed -i "s|##datapath##|$SQL_TEMPDB_DATA_FOLDER|gI" AddTempdb.sql 
  sed -i "s|##logpath##|$SQL_TEMPDB_LOG_FOLDER|gI" AddTempdb.sql 
  sed -i "s|##datasize##|$SQL_TEMPDB_DATA_FILE_SIZE_MB|gI" AddTempdb.sql 
  sed -i "s|##logsize##|$SQL_TEMPDB_LOG_FILE_SIZE_MB|gI" AddTempdb.sql 
  sudo  chown mssql:mssql $SQL_TEMPDB_DATA_FOLDER 
  sudo chown mssql:mssql $SQL_TEMPDB_LOG_FOLDER 
  /opt/mssql-tools/bin/sqlcmd -S$SQL_SERVER_NAME -Usa -P$MSSQL_SA_PASSWORD -i"AddTempdb.sql" -o"AddTempdb.out"
  
}

sql_cpu_affinity()
{
 echo "Changing SQL Server affinity.."
 sqlstr="declare @numanodes int, @sqlstr nvarchar(4000);  \
	select @numanodes=count(*) from sys.dm_os_memory_nodes where memory_node_id <> 64 ; \
	SET @sqlstr = 'ALTER SERVER CONFIGURATION SET PROCESS AFFINITY NUMANODE = 0 TO ' + cast((@numanodes-1) as nvarchar(100)); \
exec (@sqlstr) "
 
 /opt/mssql-tools/bin/sqlcmd -S$SQL_SERVER_NAME -Usa -P$MSSQL_SA_PASSWORD -Q"$sqlstr" -o"sqlAffinity.out"

}



mssqlconf_traceflags()
{
TRACEFLAGS=`echo $MSSQLCONF_TRACEFLAGS | sed -e 's/,/ /ig'` 
sudo /opt/mssql/bin/mssql-conf traceflag $TRACEFLAGS on

}

validate_params()
{
 if [[ -z "$MSSQL_SA_PASSWORD" ]];
 then
    echo Environment variable MSSQL_SA_PASSWORD must be set for unattended install
    exit 1
 else
   INSTALL_CMD='sudo MSSQL_SA_PASSWORD="'$MSSQL_SA_PASSWORD'" '
 fi
   INSTALL_CMD+='MSSQL_PID="'$MSSQL_PID'" '

 if [[ ! -z "$SQL_TEMPDB_DATA_FOLDER" ]];
 then
	if [[ ! -d "$SQL_TEMPDB_DATA_FOLDER"  &&  "$SQL_TEMPDB_DATA_FOLDER" != "/var/opt/mssql/data" ]];
	then
		echo "TempDB data directory $SQL_TEMPDB_DATA_FOLDER  does not exist"
		exit 1
	fi
 fi

 if [[ ! -z "$SQL_TEMPDB_LOG_FOLDER" ]];
 then
        if [[ ! -d "$SQL_TEMPDB_LOG_FOLDER"  &&  "$SQL_TEMPDB_LOG_FOLDER" != "/var/opt/mssql/data" ]];

        then
        	echo "Tempdb Log directory $SQL_TEMPDB_LOG_FOLDER  does not exist"
		exit 1
        fi
 fi
 
 if [[ ! -z "$MSSQL_DATA_DIR" ]];
 then
	if [[ ! -d "$MSSQL_DATA_DIR" &&  "$MSSQL_DATA_DIR" != "/var/opt/mssql/data" ]];
	then
        	echo "User data  directory $MSSQL_DATA_DIR  does not exist"
	        exit 1
        else
		INSTALL_CMD+='MSSQL_DATA_DIR="'$MSSQL_DATA_DIR'" '
        fi
 fi

 if [[ ! -z "$MSSQL_LOG_DIR" ]];
 then
	 if [[ ! -d "$MSSQL_LOG_DIR" &&  "$MSSQL_LOG_DIR" != "/var/opt/mssql/data" ]];
	 then
        	echo "User log  directory $MSSQL_LOG_DIR  does not exist"
	        exit 1
	 else
		INSTALL_CMD+='MSSQL_LOG_DIR="'$MSSQL_LOG_DIR'" '
	 fi
 fi

 if [[ ! -z "$MSSQL_DUMP_DIR" ]];
 then
	 if [[ ! -d "$MSSQL_DUMP_DIR" &&  "$MSSQL_DUMP_DIR" != "/var/opt/mssql/log" ]];
	 then
        	echo "User log  directory $MSSQL_DUMP_DIR  does not exist"
	        exit 1
	 else
		INSTALL_CMD+='MSSQL_DUMP_DIR="'$MSSQL_DUMP_DIR'" '
	 fi
 fi


 #default Port
 SQL_PORT=1433
 SQL_SERVER_NAME="localhost,$SQL_PORT"
 if [[ ! -z $MSSQL_TCP_PORT  &&  $MSSQL_TCP_PORT != 1433 ]]
 then
	INSTALL_CMD+='MSSQL_TCP_PORT='$MSSQL_TCP_PORT' '
        SQL_SERVER_NAME="localhost,$MSSQL_TCP_PORT"
	SQL_PORT=$MSSQL_TCP_PORT
 fi

 if [[ ! -z $MSSQL_LCID ]];
 then
        INSTALL_CMD+='MSSQL_LCID='$MSSQL_LCID' '
 fi
 if [[ ! -z $MSSQL_COLLATION ]];
 then
        INSTALL_CMD+='MSSQL_COLLATION="'$MSSQL_COLLATION'" '
 fi
 if [[ ! -z $MSSQL_MEMORY_LIMIT_MB ]];
 then
        INSTALL_CMD+='MSSQL_MEMORY_LIMIT_MB='$MSSQL_MEMORY_LIMIT_MB' '
 fi
 
}


CONFIG_FILE="./sqlunattended.conf"
echo "Reading configuration values from Config file $CONFIG_FILE"
if [[ -f $CONFIG_FILE ]]; then
	. $CONFIG_FILE
fi

# Specify all the defaults here if not specified in config file.
####################################################
MSSQL_SA_PASSWORD=${MSSQL_SA_PASSWORD:-""}
MSSQL_PID=${MSSQL_PID:-"evaluation"}
INSTALL_SQL_AGENT=${INSTALL_SQL_AGENT:-"NO"}
INSTALL_SQL_FULLTEXT=${INSTALL_SQL_FULLTEXT:-"NO"}
INSTALL_SQL_USER=${SQL_INSTALL_USER:-"NO"}
INSTALL_SQL_USER_PASSWORD=${SQL_INSTALL_USER_PASSWORD:-""}
SQL_CPU_AFFINITY=${SQL_CPU_AFFINITY:-"YES"}
SQL_CONFIGURE_TEMPDB_FILES=${SQL_CONFIGURE_TEMPDB_FILES:=-"YES"}
SQL_TEMPDB_DATA_FOLDER=${SQL_TEMPDB_DATA_FOLDER:-"/var/opt/mssql/data"}
SQL_TEMPDB_LOG_FOLDER=${SQL_TEMPDB_LOG_FOLDER:-"/var/opt/mssql/data"}
SQL_TEMPDB_DATA_FILE_SIZE_MB=${SQL_TEMPDB_DATA_FILE_SIZE_MB:-"1024"}
SQL_TEMPDB_LOG_FILE_SIZE_MB=${SQL_TEMPDB_LOG_FILE_SIZE_MB:-"1024"}
##############################################################


echo "Validating configuration file parameters..."
validate_params

linuxdistro=`sudo cat /etc/os-release | grep -i '^ID=' | head -n1 | awk -F'=' '{print $2}' | sed 's/"//g'`
echo Linux Distribution: $linuxdistro
# Tar command zips all log files specified, to add any other log files add to end of the command.
case $linuxdistro in 
	"ubuntu" | "debian")
         sqlinstall_ubuntu
      ;;

      "rhel" | "centos")
          sqlinstall_rhel
      ;;
	"sles")
	  sqlinstall_sles
	  ;;

      *) ;;
esac

# Restart SQL Server after installing:
 echo "Restarting SQL Server..."
 sudo systemctl restart mssql-server
 sleep 10

 echo "Attempting to connect to SQL Server for Post install configurations..."
 sql_connect
 if [[ $? -ne 1 ]]; 
 then
         echo "Connection to SQL Server instance failed, Post install SQL scripts not run..."
 else
	if [[ $SQL_CONFIGURE_TEMPDB_FILES == [Yy][eE][sS]  ]];
	then
		  echo "Configuring Tempdb..."
		  sql_auto_configure_tempdb
	fi
	if [[ $SQL_CPU_AFFINITY == [Yy][eE][sS]  ]];
        then
		  echo "Configuring CPU Affinity..."
                  sql_cpu_affinity
        fi

 fi

 # If HA is installed, have to enable it after install
 if [[ $INSTALL_HA == [Yy][eE][sS]  ]];
 then
    sudo /opt/mssql/bin/mssql-conf set hadr.hadrenabled  1
 fi

 if [ ! -z $MSSQLCONF_TRACEFLAGS ]
 then
	echo "Configuring Trace flags.."
	mssqlconf_traceflags
 fi

# Add permissions to DATA/LOG directory if custom directory
 if [[ ! -d "$MSSQL_DATA_DIR" &&  "$MSSQL_DATA_DIR" != "/var/opt/mssql/data" ]];
 then
    sudo  chown mssql:mssql $MSSQL_DATA_DIR
 
 fi

 if [[ ! -d "$MSSQL_LOG_DIR" &&  "$MSSQL_DATA_DIR" != "/var/opt/mssql/data" ]];
 then
    sudo  chown mssql:mssql $MSSQL_LOG_DIR
 fi


 #Restart SQL Server after all configs
 echo "Restarting SQL Server..."
 sudo systemctl restart mssql-server

 if [ ! -z $POST_INSTALL_SQL_SCRIPT ]
 then
	echo "Running Post install SQL Script $POST_INSTALL_SQL_SCRIPT ..."
	 /opt/mssql-tools/bin/sqlcmd -S$SQL_SERVER_NAME -Usa -P$MSSQL_SA_PASSWORD -i"$POST_INSTALL_SQL_SCRIPT" -o"PostInstallSQLScript.out"
 fi

