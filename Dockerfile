FROM eclipse-temurin:21-jre-alpine

# تثبيت الأدوات الأساسية لتشغيل وتحميل الملفات
RUN apk add --no-cache bash wget

WORKDIR /app

# نسخ ملفات السيرفر
COPY start.sh .
COPY eula.txt .

# إعطاء صلاحية التشغيل للملف
RUN chmod +x start.sh

# تشغيل السيرفر
CMD ["./start.sh"]
