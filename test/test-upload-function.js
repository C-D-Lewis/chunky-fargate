const f = require(`${__dirname}/../lambda/upload-function`);

const event = {
  Records: [{
    s3: {
      bucket: { name: 'public-files.chrislewis.me.uk' },
      object: { key: 'chunk-fargate/worlds/render-test-world.zip' },
    },
  }],
};

const main = async () => {
  await f.handler(event);
};

main();
