/* global L:const, XMLHttpRequest:const */

window.onload = function () {
  var map = L.map('map').setView([47.37570075, 15.0805552521008], 15)

  L.tileLayer('//{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    attribution: 'Map data &copy; <a href="http://openstreetmap.org">OpenStreetMap</a> contributors',
    maxZoom: 18
  }).addTo(map)

  function reqListener () {
    var fileData = this.responseText.split(/\n/)
    var points = []

    fileData.forEach(function (row) {
      var m = row.match(/^([0-9]*\.[0-9]*), ([0-9]*\.[0-9]*)$/)
      if (m) {
        points.push([ m[1], m[2], 1 ])
      }
    })

    L.heatLayer(points, { radius: 25 }).addTo(map)
  }

  var oReq = new XMLHttpRequest()
  oReq.addEventListener('load', reqListener)
  oReq.open('GET', 'result.csv?adfasf')
  oReq.send()
}
