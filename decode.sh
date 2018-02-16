#!/usr/bin/env node
var fs = require('fs')
var request = require('request')
var async = require('async')

var fileData = fs.readFileSync('list.txt').toString()
fileData = fileData.split(/\n/)

var uniqueEntries = {}
var results = {}

fileData.forEach(function (entry) {
  if (entry in uniqueEntries) {
    uniqueEntries[entry]++
  } else {
    uniqueEntries[entry] = 1
  }
})

async.eachLimit(Object.keys(uniqueEntries), 5, function (entry, callback) {
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

      results[entry] = body[0]

      callback()
    }
  )
}, function () {
  // function will be called when all entries have been requested
  fileData.forEach(function (entry) {
    var result = results[entry]
    if (result) {
      console.log(result.lat + ', ' + result.lon)
    }
  })
})
