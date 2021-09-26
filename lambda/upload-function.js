const AWS = require('aws-sdk');

const {
  /** AWS region */
  AWS_DEFAULT_REGION = 'us-east-1',
} = process.env;

AWS.config.update({ region: AWS_DEFAULT_REGION });

const ecs = new AWS.ECS();
const s3 = new AWS.S3();
const ec2 = new AWS.EC2();

// Values matching those in pipeline/run-fargate.sh
/** Project name */
const PROJECT_NAME = 'chunky-fargate';
/** Task definition family */
const FAMILY = 'chunky-fargate-td';
/** Task definition container name */
const TASK_DEF_NAME = `${PROJECT_NAME}-container-def`;
/** ECS cluster name */
const CLUSTER_NAME = `${PROJECT_NAME}-ecs-cluster`;

let GroupId, VpcId, SubnetId;

/**
 * Get the IDs of the relevant VPC and Security Group.
 *
 * @returns {object} GroupId and VpcId
 */
const getSecurityGroupAndVpcId = async () => {
  const res = await ec2.describeSecurityGroups({
    Filters: [{ Name: 'tag:Project', Values: [PROJECT_NAME] }],
  }).promise();
  
  const { GroupId, VpcId } = res.SecurityGroups[0];
  return { GroupId, VpcId };
};

/**
 * Get one subnet ID
 *
 * @returns {string} SubnetId
 */
const getSubnetId = async () => {
  const res = await ec2.describeSubnets({
    Filters: [{ Name: 'vpc-id', Values: [VpcId] }],
  }).promise();
  return res.Subnets[0].SubnetId;
};

/**
 * Run a Fargate task for a given scene.
 * https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/ECS.html#runTask-property
 * 
 * @param {string} world - World name.
 * @param {string} Bucket - Bucket name.
 * @param {object} scene - Scene from caller. 
 */
const runFargateForScene = async (world, Bucket, { name, targetSpp }) => {
  const res = await ecs.runTask({
    cluster: CLUSTER_NAME,
    taskDefinition: FAMILY,
    count: 1,
    launchType: 'FARGATE',
    networkConfiguration: {
      awsvpcConfiguration: {
        subnets: [SubnetId],
        securityGroups: [GroupId],
        assignPublicIp:'ENABLED',
      },
    },
    overrides: {
     containerOverrides: [{
       name: TASK_DEF_NAME,
       environment: [
          { name: 'WORLD_NAME', value: world },
          { name: 'SCENE_NAME', value: name },
          { name: 'TARGET_SPP', value: `${targetSpp}` },
          { name: 'BUCKET', value: Bucket },
        ]
      }]
    },
  }).promise();
  const { taskArn } = res.tasks[0];
  console.log({ name, targetSpp, taskArn });
};

/**
 * Main Lambda event handler.
 * Runs a task for each scene in the identified task file when a new world zip or task JSON is uploaded.
 * 
 * @param {object} event - S3 notification event.
 */
exports.handler = async (event) => {
  const { 
    object: { key },
    bucket: { name: Bucket },
  } = event.Records[0].s3;
  console.log({ Bucket, key });

  // Get uploaded file or task name
  const [newFileName] = (key.split('/').pop()).split('.');

  try {
    // Read all tasks and select the first relevant one based on world name
    const { Contents } = await s3.listObjects({ Bucket, Prefix: 'chunky-fargate/tasks/' }).promise();
    const [taskFile] = Contents.filter(p => p.Key.includes('json') && p.Key.includes(newFileName));
    if (!taskFile) {
      console.log(`No task found that includes ${newFileName}, not triggering`);
      return;
    }

    // Get task file JSON
    console.log({ taskFile: taskFile.Key });
    const { Body } = await s3.getObject({ Bucket, Key: taskFile.Key }).promise();
    const { world, scenes } = JSON.parse(Body.toString());
    console.log({ world, scenes });

    // Start the Fargate tasks
    ({ GroupId, VpcId } = await getSecurityGroupAndVpcId());
    SubnetId = await getSubnetId();
    await Promise.all(scenes.map(scene => runFargateForScene(world, Bucket, scene)));
    console.log('Finished');
  } catch (e) {
    console.log(e);
  }
};
