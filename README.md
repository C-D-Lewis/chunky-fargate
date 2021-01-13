# chunky-fargate

![](sample.png)

Dockerized image + pipeline for the [Chunky](https://chunky.llbit.se/) Minecraft
render on AWS Fargate, with S3 as an input and output store.

* [Setup](#setup)
* [Run locally](#run-locally)
* [Run in Docker](#run-in-docker)
* [Set up Fargate](#set-up-fargate)
* [Run a remote render task](#run-a-remote-render-task)
* [Render scenes in parallel](#render-scenes-in-parallel)

### TODO

- Trigger a task from an S3 world files upload.
- Notification when a render task completes.
- Pipeline for RPi.


## Setup

1. Download `ChunkyLauncher.jar` from the
[Chunky website](https://chunky.llbit.se/).

2. Set up at least one scene in the Chunky GUI, then copy the scene's directory
   to this project in a local `./scenes` directory
   (at least the JSON file included).


## Run locally

Install some dependencies (Java + JavaFX):

```shell
sudo apt-get install default-jdk libopenjfx-java libcontrolsfx-java jq
```

Copy a scene to a local `./scenes` directory, then render the scene to a target
SPP:

```shell
./pipeline/render-scene.sh $worldDir $sceneName $targetSpp
```

> Optionally, restart the render from 0 SPP, and update the world files by
> adding the `--restart` option.

The output PNG snapshot will be saved by Chunky in the scene directory.


## Run in Docker

The Docker image is used to fetch a world and scene from S3, render the scene,
and upload the output PNG snapshot to the same S3 bucket.

First, build the Docker image:

```shell
docker build -t chunky-fargate .
```

Next, select an S3 bucket and create a top-level `chunky-fargate` directory,
where all concerned world, scene, and output render files will be located.

Upload the scene JSON file to the S3 bucket in a `scenes` subdirectory. The
scenes in the bucket must point to the worlds present in the `worlds`
subdirectory. For example:

```
s3://$BUCKET/
  - chunky-fargate/
    - worlds/
      - village-world.zip
    - scenes/
      - village-church-interior.json
```

Then run the Docker image, supplying all the required parameters as environment
variables. This will pull the world `$WORLD_NAME`, and fetch and render
the scene `$SCENE_NAME`, using the AWS credentials specified, and finally push
the output render PNG snapshot to `$BUCKET/$SCENE_NAME/$DATE`:

```shell
docker run \
  -e WORLD_NAME \
  -e SCENE_NAME \
  -e TARGET_SPP \
  -e BUCKET \
  -e AWS_DEFAULT_REGION \
  -e AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY \
  chunky-fargate
```


## Set up Fargate

The Docker container can also be used to run a render job remotely on AWS
Fargate, a serverless compute platform.

> If you haven't, choose or create an S3 bucket for the project to use, and
> create a top-level `chunky-fargate` directory, where all concerned world,
> scene, and output render files will be located.

Next, set your own pre-existing S3 bucket name in the `terraform/main.tf` file
for your Terraform state files.

Then, create the basic infrastructure resources required (ECR, ECS, IAM, etc.)
by running Terraform:

```shell
cd terraform

# Specity required variables
# Output S3 bucket (same as $BUCKET above)
export TF_VAR_bucket=...

# AWS credentials to use
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

terraform init
terraform apply
```

Build the Docker image:

```shell
docker build -t chunky-fargate .
```

Push the most recently built image to ECR:

> The first push with the dependency layer will take a while, but subsequent
> updates to the image should not.

```shell
./pipeline/push-image.sh
```

If you haven't already, add a statement to the Bucket Policy of the output
S3 bucket allowing the Task Role access, similar to the following:

```json
{
  "Sid": "Stmt1610292864520",
  "Effect": "Allow",
  "Principal": {
    "AWS": "arn:aws:iam::$ACCOUNT_ID:role/chunky-fargate-task-role"
  },
  "Action": [
    "s3:GetObject",
    "s3:PutObject",
    "s3:ListBucket"
  ],
  "Resource": [
    "arn:aws:s3:::$BUCKET/*",
    "arn:aws:s3:::$BUCKET"
  ]
}
```


## Run a remote render task

Now the fun part!

Run a Fargate task to perform the render of the chosen world and scene:

```shell
# Create the Fargate task
./pipeline/run-fargate.sh
```

You will be asked for the following which may change for each render task:

* World name - Name of the world files zip file.
* Scene name - Name of scene in `scenes` to render.
* Target SPP - Target samples per pixel.
* Output S3 bucket - Bucket where output PNG can be saved.

For example:

```
$ ./pipeline/run-fargate.sh

World name: render-test-world
Scene name: render-test-scene
Target SPP: 100
S3 bucket: s3://public-files.chrislewis.me.uk

Fetching required resources...
Creating task...
Started: arn:aws:ecs:us-east-1:617929423658:task/chunky-fargate-ecs-cluster/5ee16ddc0c6f4e07b31879afa88c8002
```

The output PNG will be available in `$BUCKET` as per a normal Docker run.

If you add or change a scene, don't forget to update the scene JSON file in S3.


## Render scenes in parallel

TODO: tasks.json

As usual, once each task completes all the output PNG files will be found in S3.
