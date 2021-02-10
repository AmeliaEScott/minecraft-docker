# You need to have a runserver.sh file in your server directory.
# This default version will be copied in if you didn't provide one.
# Arguments:
#  -jar: Required argument to java command
#  -Xmx2G: Maximum memory to allocate to Java
#  -Xms1G: Starting memory to allocate to Java
#  /server/server.jar: This is where the auto-update script will store the latest server jar.
#    You can put your own server jar anywhere in the /server directory, but make sure to disable auto-updating
#    by unsetting the MC_VERSION environment variable, and update your custom runserver.sh accordingly.
#  nogui: This tells the (vanilla) server to run in pure command line mode.

cd /server
java -Xmx2G -Xms1G -jar /server/server.jar nogui