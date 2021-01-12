# chunky-fargate

![](sample.png)

Dockerized image + pipeline for Chunky Minecraft rendering on AWS Fargate, with
S3 as an output render PNG store.

* [Setup](#setup)
* [Run locally](#run-locally)
* [Run in Docker](#run-in-docker)
* [Set up Fargate](#set-up-fargate)
* [Run a remote render task](#run-a-remote-render-task)

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

Install some dependencies:

```shell
sudo apt-get install default-jdk libopenjfx-java libcontrolsfx-java jq
```

Copy a scene to a local `./scenes` directory:

```
mkdir -r scenes

cp -r /mnt/c/Users/Chris/.chunky/scenes/render-test-scene scenes/
```

Render the scene to a target SPP:

```shell
./pipeline/render-scene.sh $worldDir $sceneName $targetSpp
```

> Optionally, restart the render from 0 SPP, and update the world files by
> adding the `--restart` option.

The output PNG snapshot will be saved in the scene directory, for example:

```
scenes/render-test-scene/snapshots/render-test-scene-100.png
```


## Run in Docker

The Docker image is used to fetch a world and scene, render the scene, and
upload the output PNG snapshot to an S3 bucket in a `mc-renders` directory.

Build the image:

```shell
docker build -t chunky-fargate .
```

Upload the scene JSON file to the S3 bucket in a `mc-scenes` directory. The
scenes in the bucket must point to the worlds present in the `mc-worlds` bucket
directory. For example:

```
s3://chunky-rendering-bucket/
  - mc-worlds/
    - village-world.zip
  - mc-scenes/
    - village-church-interior.json
```

Then run, supplying all the required parameters. This will pull the world zip
from `$WORLD_URL`, and fetch and render scene `$SCENE_NAME`, using the AWS
credentials specified, and finally push the output render PNG snapshot to
`$OUTPUT_BUCKET/$SCENE_NAME/$DATE`:

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

The Docker container can be used to run a render job remotely on AWS Fargate,
downloading the world from a specified URL, and uploading the output PNG
snapshot to a specified S3 bucket.

First, set your own pre-existing S3 bucket name in the `terraform/main.tf` file
for your Terraform state files.

Then, create the basic infrastructure resources required (ECR, ECS, IAM, etc.):

> When you're done with this project, remember to `terraform destroy` to remove
> all the created infrastructure resources.

```shell
cd terraform

# Specity required variables
# Output S3 bucket (same as OUTPUT_BUCKET above)
export TF_VAR_output_bucket=...
# AWS credentials
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

terraform init
terraform apply
```

Build the Docker image, if you haven't already done so:

```shell
docker build -t chunky-fargate .
```

Next, push the most recently built image to ECR:

> The first push with the dependency layer will take a while, but subsequent
> updates to the image should not.

```shell
# AWS credentials
export AWS_DEFAULT_REGION=us-east-1
export AWS_ACCESS_KEY_ID=...
export AWS_SECRET_ACCESS_KEY=...

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
    "arn:aws:s3:::$OUTPUT_BUCKET/*",
    "arn:aws:s3:::$OUTPUT_BUCKET"
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

* World URL - URL where world files zip can be found.
* Scene name - Name of scene in `scenes` to render.
* Target SPP - Target samples per pixel.
* Output S3 bucket - Bucket where output PNG can be saved.

The output PNG will be available in `$OUTPUT_BUCKET` as per a normal Docker run.

If you add or change a scene, don't forget to update the scene JSON file in S3.
