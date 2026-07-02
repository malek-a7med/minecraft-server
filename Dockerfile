# استخدام نسخة جافا مستقرة وخفيفة
FROM eclipse-temurin:17-jre-alpine

# تحديد مكان العمل جوة السيرفر
WORKDIR /minecraft

# نسخ ملف السيرفر مباشرة من جهازك بدل التحميل بالنت
COPY paper.jar /minecraft/paper.jar

# الموافقة على شروط ماين كرافت (EULA)
RUN echo "eula=true" > eula.txt

# فتح البورت الافتراضي لماين كرافت
EXPOSE 25565

# أمر تشغيل السيرفر مع تحديد الرام (مثال: 2 جيجا، تقدر تغيرها حسب خطتك)
CMD ["java", "-Xms2G", "-Xmx2G", "-jar", "paper.jar", "nogui"]
