#!/usr/bin/env node
var fs = require('fs')
var request = require('request')

var fileData = fs.readFileSync('list.txt').toString()
fileData = fileData.split(/\n/)

fileData.forEach(function (entry) {
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
         console.error("Can\'t read result:", body)
         return
      }

      if (!body.length) {
        console.error('No results returned!')
        return
      }

      var result = body[0]
      console.log(result.lat + ', ' + result.lon)
    }
  )
})
