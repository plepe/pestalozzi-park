#!/usr/bin/env node
var fs = require('fs')
var request = require('request')
var async = require('async')

var fileData = fs.readFileSync('list.txt').toString()
fileData = fileData.split(/\n/)

var cache = {}
var beingProcessed = {}

async.eachLimit(fileData, 5, function (entry, callback) {
  if (entry in cache) {
    showResult(entry)
    callback()
    return
  }

  if (entry in beingProcessed) {
    beingProcessed[entry].push(callback)
    return
  }
  beingProcessed[entry] = [ callback ]

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
         callCallbacks(beingProcessed[entry])
         return
      }

      if (!body.length) {
        cache[entry] = null
        console.error('No results for \"' + entry + '\" returned!')
        callCallbacks(beingProcessed[entry])
        return
      }

      cache[entry] = body[0]

      // beingProcessed[entry] contains callbacks - for each we have to print a
      // result
      beingProcessed[entry].forEach (function () {
        showResult(entry)
      })

      callCallbacks(beingProcessed[entry])
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

function callCallbacks (callbacks) {
  callbacks.forEach(function (callback) {
    callback()
  })
}
