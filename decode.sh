#!/usr/bin/env node
var fs = require('fs')
var request = require('request')
var async = require('async')

var fileData = fs.readFileSync('list.txt').toString()
fileData = fileData.split(/\n/)

var cache = {}

async.eachLimit(fileData, 5, function (entry, callback) {
  if (entry in cache) {
    showResult(entry)
    callback()
    return
  }

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
         cache[entry] = null
         console.error("Can\'t read result for \"" + entry + "\":", body)
         callback()
         return
      }

      if (!body.length) {
        cache[entry] = null
        console.error('No results for \"' + entry + '\" returned!')
        callback()
        return
      }

      cache[entry] = body[0]
      showResult(entry)

      callback()
    }
  )
}, function () {
  console.error('Finished!')
})

function showResult (entry) {
  if (!(entry in cache) || cache[entry] === null) {
    return
  }

  var result = cache[entry]
  console.log(result.lat + ', ' + result.lon)
}
