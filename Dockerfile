# استخدام نسخة جافا 21 (لأن ماين كرافت 1.21.1 بتطلب جافا 21 على الأقل)
FROM eclipse-temurin:21-jre-alpine

# تثبيت أداة curl لتنزيل الملفات بشكل مستقر
RUN apk add --no-cache curl

# تحديد مكان العمل
WORKDIR /minecraft

# تحميل ملف سيرفر Paper لنسخة 1.21.1 بشكل صامت وخفيف
RUN curl -sSL -o paper.jar https://api.papermc.io/v2/projects/paper/versions/1.21.1/builds/130/downloads/paper-1.21.1-130.jar

# الموافقة على الشروط
RUN echo "eula=true" > eula.txt

# فتح البورت
EXPOSE 25565

# تشغيل السيرفر
CMD ["java", "-Xms1024M", "-Xmx1536M", "-jar", "paper.jar", "nogui"]
