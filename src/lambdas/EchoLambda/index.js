'use strict'

exports.handler = async function(event, context, callback) {
  if (event.hasOwnProperty('params') && event.params.hasOwnProperty('header')) {
    if (event.params.header.hasOwnProperty('User-Agent')) {
      const userAgent = event.params.header["user-agent"]; 
      const traceId = event.params.header["x-amzn-trace-id"]; 
      console.log('Echo Lambda invoked from user-agent \'' + userAgent + '\', with X-Amzn-Trace-Id value \'' + traceId + '\''); 
    } else {
      console.log('Echo Lambda invoked, but unable to access request headers in event object'); 
    } 
  }

  var response = {
    statusCode: 200,
    headers: {
      'Content-Type': 'text/html; charset=utf-8'
    },
    body: JSON.stringify({event: event, context: context}, null, 2)
  }

  callback(null, response)
}