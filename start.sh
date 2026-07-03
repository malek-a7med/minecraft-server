#!/bin/bash
set -euo pipefail

# =====================================================
# Minecraft Paper 1.21.1 — Start Script
# Optimized for Railway Free Plan (1 GB RAM)
# =====================================================

PAPER_VERSION="1.21.1"
PAPER_JAR="paper.jar"
PLUGINS_DIR="plugins"

mkdir -p "$PLUGINS_DIR"

# ---- دالة مساعدة: تحقق أن الملف جار Java صالح (أكبر من 1MB) ----
is_valid_jar() {
  local f="$1"
  [ -f "$f" ] && [ "$(wc -c < "$f")" -gt 1048576 ]
}

# ---- تحميل Paper (يستخدم fill.papermc.io API v3 لجلب أحدث بناء) ----
if ! is_valid_jar "$PAPER_JAR"; then
  echo "[START] Resolving latest Paper ${PAPER_VERSION} build from fill.papermc.io..."

  BUILDS_JSON=$(curl -fsSL --retry 3 --retry-delay 3 --max-time 30 \
    "https://fill.papermc.io/v3/projects/paper/versions/${PAPER_VERSION}/builds")

  # الحصول على رابط التحميل المباشر من آخر بناء (server:default)
  PAPER_URL=$(echo "$BUILDS_JSON" | jq -r '.[-1].downloads["server:default"].url')

  if [ -z "$PAPER_URL" ] || [ "$PAPER_URL" = "null" ]; then
    echo "[ERROR] Could not resolve Paper download URL from fill.papermc.io API."
    echo "        تأكد أن النسخة ${PAPER_VERSION} متوفرة وأن الاتصال بالإنترنت يعمل."
    exit 1
  fi

  echo "[START] Downloading Paper ${PAPER_VERSION}..."
  rm -f "$PAPER_JAR"
  curl -fsSL --retry 3 --retry-delay 3 --max-time 120 -o "$PAPER_JAR" "$PAPER_URL"

  if ! is_valid_jar "$PAPER_JAR"; then
    echo "[ERROR] Downloaded paper.jar is invalid or corrupt. Aborting."
    rm -f "$PAPER_JAR"
    exit 1
  fi
  echo "[START] Paper downloaded successfully."
fi

# ---- دالة تحميل البلجنات مع تحقق ----
download_plugin() {
  local name="$1"
  local url="$2"
  local dest="${PLUGINS_DIR}/${name}.jar"
  local min_size="${3:-51200}"   # 50KB حد أدنى افتراضي

  if ! { [ -f "$dest" ] && [ "$(wc -c < "$dest")" -gt "$min_size" ]; }; then
    echo "[PLUGINS] Downloading ${name}..."
    rm -f "$dest"
    curl -fsSL --retry 3 --retry-delay 3 --max-time 60 -L -o "$dest" "$url"
    if ! { [ -f "$dest" ] && [ "$(wc -c < "$dest")" -gt "$min_size" ]; }; then
      echo "[WARN] ${name}.jar looks invalid after download — check the URL:"
      echo "       $url"
    else
      echo "[PLUGINS] ${name} downloaded successfully."
    fi
  fi
}

# ViaVersion 5.10.0 — بيخلي أي إصدار جافا يدخل السيرفر
download_plugin "ViaVersion" \
  "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaVersion/versions/5.10.0/PAPER/ViaVersion-5.10.0.jar" \
  51200

# ViaBackwards 5.10.0 — بيضيف دعم الإصدارات الأقدم من 1.21.1
download_plugin "ViaBackwards" \
  "https://hangarcdn.papermc.io/plugins/ViaVersion/ViaBackwards/versions/5.10.0/PAPER/ViaBackwards-5.10.0.jar" \
  51200

# Floodgate — لازم ينزل قبل Geyser (Geyser بيعتمد عليه)
download_plugin "Floodgate-Spigot" \
  "https://download.geysermc.org/v2/projects/floodgate/versions/latest/builds/latest/downloads/spigot" \
  51200

# Geyser-Spigot — بيخلي البيدروك (موبايل/Xbox/مكرك) يدخل على نفس بورت الجافا
download_plugin "Geyser-Spigot" \
  "https://download.geysermc.org/v2/projects/geyser/versions/latest/builds/latest/downloads/spigot" \
  51200

# playit-minecraft v0.2.0 — نفق عام بديل للبورت بدون فتح بورت في الراوتر
download_plugin "playit-minecraft-plugin" \
  "https://github.com/playit-cloud/playit-minecraft-plugin/releases/download/v0.2.0/playit-minecraft-plugin.jar" \
  51200

# AuthMe 5.7.0 — Login system for offline-mode servers (متوافق مع 1.21.1)
download_plugin "AuthMe" \
  "https://github.com/AuthMe/AuthMeReloaded/releases/download/5.7.0/AuthMe-5.7.0.jar" \
  51200

# EssentialsX 2.22.0 — Commands, homes, spawn, economy base
download_plugin "EssentialsX" \
  "https://github.com/EssentialsX/Essentials/releases/download/2.22.0/EssentialsX-2.22.0.jar" \
  51200

# ---- قبول EULA ----
echo "eula=true" > eula.txt

# =====================================================
# Java GC Flags — Aikar's Flags (مُعدَّلة لـ 1 جيجا RAM)
# Xmx768M: يترك ~256MB لـ JVM native + metaspace + OS
# =====================================================
JAVA_FLAGS=(
  # ---- Heap ----
  # Xms256M: بيخلي الـ JVM يبدأ خفيف ويكبر حسب الحاجة بدل ما يحجز 512MB فوراً
  -Xms256M
  -Xmx768M

  # ---- G1GC — أفضل GC لتقليل تأخيرات ماين كرافت ----
  -XX:+UseG1GC
  -XX:+ParallelRefProcEnabled
  -XX:MaxGCPauseMillis=200
  -XX:+UnlockExperimentalVMOptions
  -XX:+DisableExplicitGC
  # AlwaysPreTouch اتشال: كان بيحجز كل الـ heap pages فوراً عند الـ startup
  # وده كان بيسبب spike في الـ RAM مع Geyser initialization
  -XX:G1NewSizePercent=30
  -XX:G1MaxNewSizePercent=40
  -XX:G1HeapRegionSize=8M
  -XX:G1ReservePercent=20
  -XX:G1HeapWastePercent=5
  -XX:G1MixedGCCountTarget=4
  -XX:InitiatingHeapOccupancyPercent=15
  -XX:G1MixedGCLiveThresholdPercent=90
  -XX:G1RSetUpdatingPauseTimePercent=5
  -XX:SurvivorRatio=32
  -XX:+PerfDisableSharedMem
  -XX:MaxTenuringThreshold=1

  # ---- تحسينات إضافية ----
  -Dusing.aikars.flags=https://mcflags.emc.gs
  -Daikars.new.flags=true
  -Dpaper.playerconnection.keepalive=30

  # ---- تقليل استخدام Metaspace ----
  -XX:MetaspaceSize=64M
  -XX:MaxMetaspaceSize=256M
)

echo "[START] Launching Paper ${PAPER_VERSION}..."

# JAVA_TOOL_OPTIONS بيتضبط من ريلواي على -Xms3G -Xmx3G وده بيكراش الكونتينر (3GB > 1GB RAM)
# بنمسحه عشان flags بتاعتنا تشتغل
unset JAVA_TOOL_OPTIONS

exec java "${JAVA_FLAGS[@]}" -jar "$PAPER_JAR" nogui
