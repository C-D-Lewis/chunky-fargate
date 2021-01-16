const AWS = require('aws-sdk');

const {
  AWS_REGION,
  AWS_DEFAULT_REGION,
} = process.env;

AWS.config.update({ region: AWS_REGION || AWS_DEFAULT_REGION });

const ecs = new AWS.ECS();
const s3 = new AWS.S3();

// Values matching those in pipeline/run-fargate.sh
const PROJECT_NAME = 'chunky-fargate';
const FAMILY = 'chunky-fargate-td';
const TASK_DEF_NAME = `${PROJECT_NAME}-container-def`;
const CLUSTER_NAME = `${PROJECT_NAME}-ecs-cluster`;

/**
 * Run a Fargate task for a given scene.
 * https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/ECS.html#runTask-property
 * 
 * @param {string} world - World name.
 * @param {string} Bucket - Bucket name.
 * @param {object} scene - Scene from caller. 
 */
const runFargateForScene = async (world, Bucket, { name, targetSpp }) => {
  const runTaskRes = await ecs.runTask({
    cluster: CLUSTER_NAME,
    taskDefinition: FAMILY,
    count: 1,
    launchType: 'FARGATE',
    networkConfiguration: {
      awsvpcConfiguration: {
        subnets: ['$SUBNET_ID'],
        securityGroups: ['$SECURITY_GROUP_ID'],
        assignPublicIp:'ENABLED',
      },
    },
    overrides: {
     containerOverrides: [{
       name: TASK_DEF_NAME,
       environment: [
          { name: 'WORLD_NAME', value: world },
          { name: 'SCENE_NAME', value: name },
          { name: 'TARGET_SPP', value: targetSpp },
          { name: 'BUCKET', value: Bucket },
        ]
      }]
    },
  }).promise();
  console.log({ name, targetSpp, runTaskRes });
};

/**
 * Main Lambda event handler.
 * 
 * @param {object} event - S3 notification event.
 */
exports.handler = async (event) => {
  const { 
    object: { key },
    bucket: { name: Bucket },
  } = event.Records[0].s3;
  console.log({ Bucket, key });

  // Get uploaded file name
  const [newFileName] = (key.split('/').pop()).split('.');

  try {
    // Read all tasks and select the relevant one to render
    const listObjectsParms = { Bucket, Prefix: 'chunky-fargate/tasks/' };
    const { Contents } = await s3.listObjects(listObjectsParms).promise();
    const [taskFile] = Contents.filter(p => p.Key.includes('json') && p.Key.includes(newFileName));
    console.log({ taskFile: taskFile.Key });

    // Get task file JSON
    const getObjectParams = { Bucket, Key: taskFile.Key };
    const getObjectRes = await s3.getObject(getObjectParams).promise();
    const { world, scenes } = JSON.parse(getObjectRes.Body.toString());
    console.log({ world, scenes });

    // Start the Fargate tasks
    await Promise.all(scenes.map(scene => runFargateForScene(world, Bucket, scene)));
    console.log('Finished');
  } catch (e) {
    console.log(e);
  }
};
