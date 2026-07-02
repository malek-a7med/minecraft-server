# استخدام نسخة جافا مستقرة وخفيفة
FROM eclipse-temurin:17-jre-alpine

# تثبيت أداة curl لتنزيل الملفات بشكل مستقر
RUN apk add --no-cache curl

# تحديد مكان العمل
WORKDIR /minecraft

# تحميل ملف السيرفر مباشرة بشكل صامت (Silent) وموفر للرام
RUN curl -sSL -o paper.jar https://api.papermc.io/v2/projects/paper/versions/1.20.4/builds/496/downloads/paper-1.20.4-496.jar

# الموافقة على الشروط
RUN echo "eula=true" > eula.txt

# فتح البورت
EXPOSE 25565

# تشغيل السيرفر
CMD ["java", "-Xms2G", "-Xmx2G", "-jar", "paper.jar", "nogui"]
