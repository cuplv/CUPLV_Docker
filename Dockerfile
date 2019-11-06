FROM ubuntu:16.04

RUN mkdir /home/root
WORKDIR /home/root/
RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install default-jdk -y
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64
RUN apt-get install -y scala git
RUN apt-get install -y wget curl
RUN apt-get install -y apt-transport-https ca-certificates
RUN apt-get update --fix-missing
RUN apt-get install -y cmake
# Sbt
#RUN wget www.scala-lang.org/files/archive/scala-2.13.0.deb
#RUN dpkg -i scala*.deb
RUN echo "deb https://dl.bintray.com/sbt/debian /" | tee -a /etc/apt/sources.list.d/sbt.list
RUN curl -sL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x2EE0EA64E40A89B84B2DF73499E82A75642AC823" | apt-key add
RUN apt-get update
RUN apt-get install sbt

# Python 2
RUN apt-get install -y python
RUN apt-get install -y python-pip
RUN apt-get install -y python-sqlalchemy
RUN pip install protobuf

# Google protobuffer
RUN  apt-get install -y curl unzip autoconf automake libtool
RUN curl -OL https://github.com/google/protobuf/releases/download/v3.5.0/protobuf-all-3.5.0.zip \
    && unzip protobuf-all-3.5.0.zip \
    && cd protobuf-3.5.0 \
    && ./autogen.sh

RUN cd protobuf-3.5.0 \
    && ./configure \
    && make \
    && make install

RUN cd protobuf-3.5.0/ \
    && ldconfig

RUN rm -rf protobuf-3.5.0 protobuf-all-3.5.0.zip

# Microsoft z3
ENV Z3_VERSION "4.5.0"
# install debian packages
RUN apt-get update -qq -y \
 && apt-get install binutils g++ make ant -y \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
#
# download, compile and install Z3
 && Z3_DIR="$(mktemp -d)" \
 && cd "$Z3_DIR" \
 && wget -qO- https://github.com/Z3Prover/z3/archive/z3-${Z3_VERSION}.tar.gz | tar xz --strip-components=1 \
 && python scripts/mk_make.py --java \
 && cd build \
 && make \
 && make install \
 && cd / \
 && rm -rf "$Z3_DIR"

RUN apt-get update
RUN apt-get install -y glpk-utils libglpk-dev
RUN pip install nose

RUN apt-get install -y python-cffi
RUN pip install six
RUN apt-get install -y libssl-dev
RUN mkdir app \
    && cd app \
    && curl -OL https://github.com/libgit2/libgit2/archive/v0.27.0.tar.gz \
    && ls \
    && tar xzf v0.27.0.tar.gz \
    && cd libgit2-0.27.0/ \
    && mkdir build && cd build \
    && cmake .. \
    && cmake --build . --target install \
    && ldconfig \
    && rm -rf /app
RUN pip install pygit2
RUN apt-get install time

# 7. Android SDK
# Set up environment variables
ENV ANDROID_HOME="/home/biggroum/android-sdk-linux" \
    SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip" \
    GRADLE_URL="https://services.gradle.org/distributions/gradle-4.5.1-all.zip"

USER biggroum
WORKDIR /home/biggroum

# Download Android SDK
RUN mkdir "$ANDROID_HOME" .android \
  && cd "$ANDROID_HOME" \
  && curl -o sdk.zip $SDK_URL \
  && unzip sdk.zip \
  && rm sdk.zip \
  && yes | $ANDROID_HOME/tools/bin/sdkmanager --licenses

# Install Gradle
RUN wget $GRADLE_URL -O gradle.zip \
  && unzip gradle.zip \
  && mv gradle-4.5.1 gradle \
  && rm gradle.zip \
  && mkdir .gradle

ENV PATH="/home/biggroum/gradle/bin:${ANDROID_HOME}/tools:${ANDROID_HOME}/platform-tools:${PATH}"

# Install platform tools
RUN cd android-sdk-linux/tools/bin \
    && ./sdkmanager "platform-tools" "platforms;android-10" "platforms;android-11" "platforms;android-12" "platforms;android-13" "platforms;android-14" "platforms;android-15" "platforms;android-16" "platforms;android-17" "platforms;android-18" "platforms;android-19" "platforms;android-20" "platforms;android-21" "platforms;android-22" "platforms;android-23" "platforms;android-24" "platforms;android-25" "platforms;android-26" "platforms;android-27" "platforms;android-7" "platforms;android-8" "platforms;android-9"

CMD ["/bin/bash"]
