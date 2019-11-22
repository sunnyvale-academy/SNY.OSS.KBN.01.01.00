## How to build and push this image

# docker build -t sunnyvale/resource-tester:1.0 . 
# docker login
# docker push sunnyvale/resource-tester:1.0

FROM openjdk:11.0-jdk

ADD app/ /app/

ENV JAVA_OPTS -Xms50m 

ENTRYPOINT /usr/local/openjdk-11/bin/java $JAVA_OPTS -XX:+PrintCommandLineFlags -XX:MaxRAMFraction=1 /app/TestResources.java


