FROM java:8-jdk

RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -

RUN apt-get update && apt-get install --yes nodejs

RUN wget https://cli.run.pivotal.io/stable?release=linux64-binary -O /tmp/cf.tgz --no-check-certificate
RUN tar zxf /tmp/cf.tgz -C /usr/bin && chmod 755 /usr/bin/cf

RUN npm install -g gulp

ENV PORT=8080 \
    GRADLE_HOME=/usr/bin/gradle-2.14 \
    PATH=$PATH:/usr/bin/gradle-2.14/bin:/meta/.cli

EXPOSE 8080



ADD . /meta

WORKDIR /usr/bin

RUN wget -q https://services.gradle.org/distributions/gradle-2.14-bin.zip -O gradle.zip \
    && unzip -q gradle.zip \
    && rm gradle.zip \
    && curl -jksSLH "Cookie: oraclelicense=accept-securebackup-cookie" -o /tmp/unlimited_jce_policy.zip "http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip" \
    && unzip -jo -d ${JAVA_HOME}/jre/lib/security /tmp/unlimited_jce_policy.zip \
    && cd /meta \
    && gradle build \
    && gradle test \
    && git config --global user.name CI-BuildBot \
    && git config --global user.email svc_payments_ci \
    && tar -xzf cf-cli*.tgz -C /usr/bin/
    




