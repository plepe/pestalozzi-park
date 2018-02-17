#!/usr/bin/env node
/* dependencies */
var fs = require('fs')
var request = require('request')
var async = require('async')

/* read file 'list.txt' and split into lines */
var fileData = fs.readFileSync('list.txt').toString()
fileData = fileData.split(/\n/)

/* initialize variables:
 * - hash map 'uniqueEntries' will contain each unique address from
 *   list.txt as key and count of appearances as value, e.g.
 *   { "address1": 5, "address2": 1 }
 */
var uniqueEntries = {}
/* - hash map 'results' will contain each successfully resolved address as key and the (first) result from Nominatim as value, e.g.
 *   { "address1": { "lat": 48.1989256, "lon": 16.3698784, ... }, ... }
 */
var results = {}

/* create the uniqueEntries hash map */
fileData.forEach(function (entry) {
  if (entry in uniqueEntries) {
    uniqueEntries[entry]++
  } else {
    uniqueEntries[entry] = 1
  }
})

/* for each address (but not more than 5 simultaneously -> eachLimit waits
 * until each function calls the 'callback' method) - at the end call the
 * final function ... */
async.eachLimit(Object.keys(uniqueEntries), 5,
function (entry, callback) {
  /* prepare options to 'request' */
  var options = {
    url: 'https://nominatim.openstreetmap.org/search/' + encodeURIComponent(entry) + '?format=json',
    headers: {
      'User-Agent': 'request'
    }
  }

  /* request result from Nominatim API */
  request(options,
    function (error, response, body) {
      /* try to parse answer - on error case, print error to stderr */
      try {
        body = JSON.parse(body)
      } catch(err) {
         console.error("Can\'t read result for \"" + entry + "\":", body)
         callback()
         return
      }

      /* if result is empty, print error to stderr */
      if (!body.length) {
        console.error('No results for \"' + entry + '\" returned!')
        callback()
        return
      }

      /* success! -> save result in 'results' hash map */
      results[entry] = body[0]

      callback()
    }
  )
},
/* will be called when all entries have been resolved */
function () {
  /* for each entry in the fileData array ... */
  fileData.forEach(function (entry) {

    /* print the result, if available */
    var result = results[entry]
    if (result) {
      console.log(result.lat + ', ' + result.lon)
    }
  })
})
