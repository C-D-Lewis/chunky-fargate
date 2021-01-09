# chunky-fargate

Dockerized image + pipeline for Chunky Minecraft rendering, with S3 as a store.

## Setup

1. Download `ChunkyLauncher.jar` from the
[Chunky website](https://chunky.llbit.se/).

2. Set up at least one scene in the Chunky GUI, then copy the scene's directory
   to this project in a `./scenes` directory.

3. Install some dependencies:

    ```shell
    sudo apt-get install default-jdk libopenjfx-java libcontrolsfx-java jq
    ```

3. Render the scene to a target SPP:

    ```shell
    ./render-scene.sh $worldDir $sceneName $targetSpp
    ```

Optionally, restart the render from 0 SPP, and update the world files:

```shell
./render-scene.sh $worldDir $sceneName $targetSpp --restart
```

## Run in Docker

Build the image:

```shell
docker build -t chunky-fargate .
```

Then run, supplying all required parameters. This will pull the world zip from
`$WORLD_URL` and render scene `$SCENE_NAME` and use the AWS credentials
specified to push the output render PNG snapshot to `$BUCKET/$SCENE_NAME/$DATE`:

```shell
docker run \
  -e WORLD_URL \
  -e SCENE_NAME \
  -e TARGET_SPP \
  -e BUCKET \
  -e AWS_DEFAULT_REGION \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  chunky-fargate
```
