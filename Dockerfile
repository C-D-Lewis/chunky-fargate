FROM ubuntu:18.04

WORKDIR /chunky

# Environment variables
ENV MC_VERSION="1.16.4"

# For tzdata dependency
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# Dependencies
RUN apt-get update && apt-get install -y default-jdk libopenjfx-java libcontrolsfx-java jq wget unzip awscli

# Chunky files
COPY ChunkyLauncher.jar /chunky/ChunkyLauncher.jar

# Initialize Chunky and Minecraft textures
RUN cd /chunky
RUN java -Dchunky.home="$(pwd)" -jar ChunkyLauncher.jar --update
RUN java -Dchunky.home="$(pwd)" -jar ChunkyLauncher.jar -download-mc $MC_VERSION

# Pipeline
COPY pipeline /chunky/pipeline

# Scenes that will be used
COPY scenes /chunky/scenes

ENTRYPOINT ["./pipeline/fetch-render-upload.sh"]
