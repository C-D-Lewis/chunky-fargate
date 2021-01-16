const AWS = require('aws-sdk');
const ecs = new AWS.ECS();
const s3 = new AWS.S3();

// https://docs.aws.amazon.com/AWSJavaScriptSDK/latest/AWS/ECS.html#runTask-property

exports.handler = async (event) => {
  const { 
    object: { key },
    bucket: { name: bucketName },
  } = event.Records[0].s3;
  console.log({ bucketName, key });

  // Get uploaded file name
  const [newFileName] = (key.split('/').pop()).split('.');

  // Read all tasks
  const listObjectsParms = { Bucket: bucketName, Prefix: 'chunky-fargate/tasks/' };
  const { Contents } = await s3.listObjects(listObjectsParms).promise();

  // Select the relevant ones to render
  const taskFiles = Contents
    .filter(p => p.Key.includes('json'))
    .filter(p => p.Key.includes(newFileName));
  console.log({ taskFiles: taskFiles.map(p => p.Key) });
  return;

  const runTaskRes = await ecs.runTask({

  }).promise();
};
