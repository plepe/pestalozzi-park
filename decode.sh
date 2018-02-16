#!/usr/bin/env node
var fs = require('fs')
var request = require('request')
var async = require('async')

var fileData = fs.readFileSync('list.txt').toString()
fileData = fileData.split(/\n/)

async.eachLimit(fileData, 5, function (entry, callback) {
  var options = {
    url: 'https://nominatim.openstreetmap.org/search/' + encodeURIComponent(entry) + '?format=json',
    headers: {
      'User-Agent': 'request'
    }
  }

  request(options,
    function (error, response, body) {
      try {
        body = JSON.parse(body)
      } catch(err) {
         console.error("Can\'t read result for \"" + entry + "\":", body)
         callback()
         return
      }

      if (!body.length) {
        console.error('No results for \"' + entry + '\" returned!')
        callback()
        return
      }

      var result = body[0]
      console.log(result.lat + ', ' + result.lon)

      callback()
    }
  )
}, function () {
  console.error('Finished!')
})
