#!/bin/bash
# تحميل ملف Paper 1.20.4 لو مش موجود
if [ ! -f paper.jar ]; then
  echo "Downloading Paper Minecraft Server..."
  curl -o paper.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/497/downloads/paper-1.20.4-497.jar
fi

# تشغيل السيرفر بجافا
exec java -Xms768M -Xmx768M -jar paper.jar nogui
