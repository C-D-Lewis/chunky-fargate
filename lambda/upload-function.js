exports.handler = async (event) => {
  const { key } = event.Records[0].s3.object;
  console.log({ key });
};
