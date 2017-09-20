'use strict';

const AWS = require('aws-sdk');
const crypto = require('crypto');
const dynamoDb = new AWS.DynamoDB.DocumentClient();
const response = require ('../helpers/response.js');

const create = (requestBody, callback) => {
  const timestamp = new Date().getTime();
  const data = JSON.parse(requestBody);
  
  if ((!data.email) || typeof data.email !== 'string') {
    response.returnError(400, 'Email is required', callback);
    return;
  }
  
  const apiKeyValue = crypto.randomBytes(20).toString('hex');
  const params = {
    TableName: process.env.TABLE_NAME,
    Item: {
      createdAt: timestamp,
      email: data.email,
      value: apiKeyValue
    }
  };
  
  dynamoDb.put(params, (error, result) => {
    if (error) {
      console.error(error);
      response.returnError(500, 'Failed to save new API Key.', callback);
      return;
    }
    
    response.returnSuccess(null, callback);
    return;
  });
};

module.exports.handler = (event, context, callback) => {
  create(event.body, callback);
};
