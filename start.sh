#!/bin/bash
if [ ! -f paper.jar ]; then
  echo "Downloading Paper Minecraft Server..."
  wget -O paper.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/497/downloads/paper-1.20.4-497.jar
fi
exec java -Xms768M -Xmx768M -jar paper.jar nogui
