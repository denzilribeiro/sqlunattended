# SQL Server on Linux Unattended install

For SQL Server on Linux, there are several capabilities that are useful in unattended install scenarios:
- You can specify environment variables prior to the install that are picked up by the install process, to enable customization of SQL Server settings such as TCP port, Data/Log directories, etc.
- You can pass command line options to Setup.
- You can create a script that installs SQL Server and then customizes parameters post-install with the mssql-conf utility.
 
Here is a sample script that would further ease the unattended install process, and would allow you to:
- Have one script across multiple distributions
- Choose the components installed (SQL Server, SQL Agent, SQL FTS, SQL HA)
- Configure common install parameters via a config file
- Set up some SQL Server on Linux best practices we have documented such as tempdb configuration and processor affinity, which are not part of the core install
- Enable you to specify a custom post-install .sql file to run once SQL Server is installed
      

Steps to run the script:

1.	Download the script:   
      git clone https://github.com/denzilribeiro/sqlunattended.git
      
2.	To prevent sudo password prompts during unattended install:
        sudo chown root:root sqlunattended.sh
        sudo chmod 4755 sqlunattended.sh
3.	Modify the sqlunattended.conf file to specify the configuration options required, including what components to install, data/log directories, etc. Here is a snippet from the sqlunattended.conf:
        #Components to install
        INSTALL_SQL_AGENT=YES
        INSTALL_FULLTEXT=NO
        INSTALL_HA=NO

        # This will set SQL processor affinity for all CPUs, we have seen perf improvements doing that on Linux
        SQL_CPU_AFFINITY=YES
        # This creates 8 tempdb files if NumCPUS>=8, or as many tempdb files as there are CPUs if NumCPUS<8
        SQL_CONFIGURE_TEMPDB_FILES=YES
        SQL_TEMPDB_DATA_FOLDER=/mnt/data
        SQL_TEMPDB_LOG_FOLDER=/mnt/log
        SQL_TEMPDB_DATA_FILE_SIZE_MB=500
        SQL_TEMPDB_LOG_FILE_SIZE_MB=100

4.	Run the unattended install
        /bin/bash sqlunattended.sh
