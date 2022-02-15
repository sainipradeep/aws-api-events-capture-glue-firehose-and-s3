var config = module.exports = {
    kinesis: {
        region: 'ap-south-1'
    },
    stream: 'testing-kinesis-stream',
    shards: 1,
    waitBetweenDescribeCallsInSeconds: 5
};