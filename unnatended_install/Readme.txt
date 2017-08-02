Unattended Install Readme
=========================
This script allows unattended install of SQL Server on Linux, SQL Agent, FTS, also allows configuring various configuration parameters, modifying Tempdb files and locations during install.
1. Download the script
   git clone  https://github.com/denzilribeiro/datadiagnostics.git

2. To prevent Sudo password prompts
   sudo chown root:root sqlunattended.sh
   sudo chmod 4755 sqlunattended.sh

3. Modify sqlunattended.conf file to specify the configuration options required including what components to install, directories of data/log files etc.

4. Run the unattended install
   /bin/bash ./sqlunattended.sh

