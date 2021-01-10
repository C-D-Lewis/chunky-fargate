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

## Set up Fargate

The Docker container can be used to run a render job remotely on AWS Fargate.

First, deploy the basic infrastructure:

> You may need to select a new backend S3 bucket in `terraform/main.tf`.

```shell
cd terraform

# Specity required variables
# Output S3 bucket (same as OUTPUT_BUCKET below, but just the bucket name)
export TF_VAR_output_bucket=...

terraform init
terraform apply
```

Next, push the most recently built image (with up to date scenes) to ECR:

> The first push with the dependency layer will take a while, but subsequent
> updates to the image should not.

```shell
# AWS credentials
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

./pipeline/push-image.sh
```

## Run a remote render

> If you haven't already, add a statement to the Bucket Policy of the output
> bucket allowing the Task Role access.

Create a new Task Definition in the created ECS service, which will run the
Docker container:

```shell
# URL where world files zip can be found
export WORLD_URL=...
# Name of scene to render
export SCENE_NAME=...
# Target samples per pixel
export TARGET_SPP=...
# Bucket where output PNG can be saved
export OUTPUT_BUCKET=...

# Create the Fargate task
./pipeline/run-fargate.sh
```

The output PNG will be available in `$OUTPUT_BUCKET` as per a normal Docker run.
