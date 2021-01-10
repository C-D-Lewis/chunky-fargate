# chunky-fargate

Dockerized image + pipeline for Chunky Minecraft rendering, with S3 as a store.

TODO: Terraform/script to start as ECS Fargate tasks.

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

Optionally, restart the render from 0 SPP, and update the world files by adding
the `--restart` option.


## Run in Docker

The Docker image is used to fetch a world, render a scene, and upload the output
PNG snapshot to an S3 bucket.

Build the image:

```shell
docker build -t chunky-fargate .
```

Then run, supplying all required parameters. This will pull the world zip from
`$WORLD_URL` and render scene `$SCENE_NAME`, using the AWS credentials
specified to push the output render PNG snapshot to `$OUTPUT_BUCKET/$SCENE_NAME/$DATE`:

```shell
docker run \
  -e WORLD_URL \
  -e SCENE_NAME \
  -e TARGET_SPP \
  -e OUTPUT_BUCKET \
  -e AWS_DEFAULT_REGION \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  chunky-fargate
```

## Run on Fargate

The Docker container can be used to run a render job remotely on AWS Fargate.

First, deploy the basic infrastructure:

> You may need to select a new S3 bucket in `terraform/main.tf`.

```
cd terraform

terraform init
terraform apply
```

Next, create a new Task Definition in the created ECS service, which will run
the Docker container:

```
# Set render variables
export WORLD_URL=...
export SCENE_NAME=...
export TARGET_SPP=...
export OUTPUT_BUCKET=...

# Create the Fargate task
./pipeline/run-fargate.sh
```

The output PNG will be available in `$OUTPUT_BUCKET` as per a normal Docker run.
