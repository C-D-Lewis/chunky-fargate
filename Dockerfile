FROM ubuntu:18.04

WORKDIR /chunky

# For tzdata dependency
ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Europe/London

# Dependencies
RUN apt-get update && apt-get install -y default-jdk libopenjfx-java libcontrolsfx-java jq wget unzip awscli

# Chunky files
COPY ChunkyLauncher.jar /chunky/ChunkyLauncher.jar
COPY render-scene.sh /chunky/render-scene.sh
COPY fetch-world.sh /chunky/fetch-world.sh
COPY upload-snapshot.sh /chunky/upload-snapshot.sh
COPY pipeline.sh /chunky/pipeline.sh

# Scenes that will be used
COPY scenes /chunky/scenes

# Environment variables
ENV MC_VERSION="1.16.4"

# Initialize Chunky and Minecraft textures
RUN cd /chunky
RUN java -Dchunky.home="$(pwd)" -jar ChunkyLauncher.jar --update
RUN java -Dchunky.home="$(pwd)" -jar ChunkyLauncher.jar -download-mc $MC_VERSION

# docker run -e WORLD_URL -e SCENE_NAME -e TARGET_SPP -e BUCKET -e AWS_DEFAULT_REGION -e AWS_ACCESS_KEY_ID -e AWS_SECRET_ACCESS_KEY chunky-fargate
ENTRYPOINT ["./pipeline.sh"]
