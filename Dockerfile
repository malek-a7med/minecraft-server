# =====================================================
# Minecraft Paper 1.21.1 — Dockerfile
# Optimized for Railway Free Plan (1 GB RAM)
# =====================================================

FROM eclipse-temurin:21-jre-alpine

# تثبيت الأدوات: curl (تحميل ملفات) + jq (تحليل JSON من Paper API) + bash
RUN apk add --no-cache curl bash libstdc++ jq

WORKDIR /minecraft

# نسخ ملفات الإعداد إلى الصورة
COPY server.properties .
COPY spigot.yml .
COPY eula.txt .
COPY config/ config/
COPY start.sh .
RUN chmod +x start.sh

# إنشاء مجلد البلجنات
RUN mkdir -p plugins

# فتح البورت
EXPOSE 25565

# تشغيل السيرفر (يُنزَّل Paper والبلجنات تلقائياً عند أول تشغيل)
ENTRYPOINT ["./start.sh"]
