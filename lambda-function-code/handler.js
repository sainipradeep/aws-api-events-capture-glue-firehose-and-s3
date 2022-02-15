"use strict";
var AWS = require('aws-sdk');
var config = require('./config');
exports.lambda_handler = async (event, context) => {
    try {
        var kinesis = new AWS.Kinesis({ region: config.kinesis.region });
        let body = event['Records'][0]['body'];
        body = body.substring(0, body.length - 1);
        body = JSON.stringify(JSON.parse(body)['body-json'])
        return _writeToKinesis(kinesis, body)
    } catch (e) {
        return e
    }
};

async function _writeToKinesis(kinesis, body) {
    var sensor = 'sensor-' + Math.floor(Math.random() * 100000);
    var recordParams = {
        Data: body,
        PartitionKey: sensor,
        StreamName: config.stream
    };

    return new Promise((resolve, reject)=>{
        kinesis.putRecord(recordParams, function (err, data) {
            if (err) {
                console.log("error", err)
                reject(err)
            }
            else {
                resolve(data)
            }
        });
    })
    
}