FROM java:8

RUN apt-get purge -y python.*

ENV PORT=8080 \
    GRADLE_HOME=/usr/bin/gradle-2.14 \
    PATH=$PATH:/usr/bin/gradle-2.14/bin:/meta/.cli \
    PYTHON_VERSION=3.5.2 \
    PYTHON_PIP_VERSION=8.1.2 \
    LANG=C.UTF-8


EXPOSE 8080

ADD . /meta

WORKDIR /usr/bin

RUN wget -q https://services.gradle.org/distributions/gradle-2.14-bin.zip -O gradle.zip \
    &&
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

RUN set -ex \
  	&& buildDeps=' \
  		tcl-dev \
  		tk-dev \
  	' \
  	&& runDeps=' \
  		tcl \
  		tk \
  	' \
  	&& apt-get update && apt-get install -y $runDeps $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/* \
  	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
  	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
  	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
  	&& rm -r "$GNUPGHOME" python.tar.xz.asc \
  	&& mkdir -p /usr/src/python \
  	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
  	&& rm python.tar.xz \
  	\
  	&& cd /usr/src/python \
  	&& ./configure \
  		--enable-loadable-sqlite-extensions \
  		--enable-shared \
  	&& make -j$(nproc) \
  	&& make install \
  	&& ldconfig \
  	&& pip3 install --no-cache-dir --upgrade pip==$PYTHON_PIP_VERSION \
  	&& [ "$(pip list | awk -F '[ ()]+' '$1 == "pip" { print $2; exit }')" = "$PYTHON_PIP_VERSION" ] \
  	&& find /usr/local -depth \
  		\( \
  		    \( -type d -a -name test -o -name tests \) \
  		    -o \
  		    \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
  		\) -exec rm -rf '{}' + \
  	&& apt-get purge -y --auto-remove $buildDeps \
  	&& rm -rf /usr/src/python ~/.cache

RUN cd /usr/local/bin \
  	&& ln -s easy_install-3.5 easy_install \
  	&& ln -s idle3 idle \
  	&& ln -s pydoc3 pydoc \
  	&& ln -s python3 python \
  	&& ln -s python3-config python-config

CMD ["python3"]
