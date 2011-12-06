  var map = null;
  var chart = null;
  
  var geocoderService = null;
  var elevationService = null;
  var directionsService = null;
  
  var mousemarker = null;
  var markers = [];
  var polyline = null;
  var elevations = null;
  
  var SAMPLES = 256;
  // Load the Visualization API and the piechart package.
  google.load("visualization", "1", {packages: ["columnchart"]});
  
  
  function initialize(lat1, lon1, lat2, lon2) {
  
    var myLatlng = new google.maps.LatLng(15, 0);
    var myOptions = {
      zoom: 1,
      center: myLatlng,
      mapTypeId: google.maps.MapTypeId.TERRAIN
    }

    map = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
    chart = new google.visualization.ColumnChart(document.getElementById('chart_div'));
    
    geocoderService = new google.maps.Geocoder();
    elevationService = new google.maps.ElevationService();
    directionsService = new google.maps.DirectionsService();

    /*google.maps.event.addListener(map, 'click', function(event) {
      addMarker(event.latLng, true);
    });*/
    
    google.visualization.events.addListener(chart, 'onmouseover', function(e) {
      if (mousemarker == null) {
        mousemarker = new google.maps.Marker({
          position: elevations[e.row].location,
          map: map,
          icon: "http://maps.google.com/mapfiles/ms/icons/green-dot.png"
        });
      } else {
        mousemarker.setPosition(elevations[e.row].location);
      }
    });

    load_map(lat1, lon1, lat2, lon2);

  }
  
  // Takes an array of ElevationResult objects, draws the path on the map
  // and plots the elevation profile on a GViz ColumnChart
  function plotElevation(results) {
    elevations = results;
    
    var path = [];
    for (var i = 0; i < results.length; i++) {
      path.push(elevations[i].location);
    }
    
    if (polyline) {
      polyline.setMap(null);
    }
    
    polyline = new google.maps.Polyline({
      path: path,
      strokeColor: "#000000",
      map: map});
    
    var data = new google.visualization.DataTable();
    data.addColumn('string', 'Sample');
    data.addColumn('number', 'Elevation');
    for (var i = 0; i < results.length; i++) {
      data.addRow(['', elevations[i].elevation]);
    }

    document.getElementById('chart_div').style.display = 'block';
    chart.draw(data, {
      width: 512,
      height: 200,
      legend: 'none',
      titleY: 'Elevation (m)',
      focusBorderColor: '#00ff00'
    });
  }
  
  // Remove the green rollover marker when the mouse leaves the chart
  function clearMouseMarker() {
    if (mousemarker != null) {
      mousemarker.setMap(null);
      mousemarker = null;
    }
  }
  

  // Add a marker and trigger recalculation of the path and elevation
  function addMarker(latlng, doQuery, drag) {
        var marker = new google.maps.Marker({
        position: latlng,
        map: map,
        draggable: drag
      })
      
      /*google.maps.event.addListener(marker, 'dragend', function(e) {
        updateElevation();
      });*/
      
      markers.push(marker);
      
      if (doQuery) {
        updateElevation();
      }
     
  }
  
  // Trigger the elevation query for point to point
  // or submit a directions request for the path between points
  function updateElevation() {
    if (markers.length > 1) {
      var travelMode = document.getElementById("mode").value;
      if (travelMode != 'direct') {
        calcRoute(travelMode);
      } else {
        var latlngs = [];
        for (var i in markers) {
          latlngs.push(markers[i].getPosition())
        }
        elevationService.getElevationAlongPath({
          path: latlngs,
          samples: SAMPLES
        }, plotElevation);
      }
    }
  }
  
  // Submit a directions request for the path between points and an
  // elevation request for the path once returned
  function calcRoute(travelMode) {
    var origin = markers[0].getPosition();
    var destination = markers[markers.length - 1].getPosition();
    
    var waypoints = [];
    for (var i = 1; i < markers.length - 1; i++) {
      waypoints.push({
        location: markers[i].getPosition(),
        stopover: true
      });
    }
    
    var request = {
      origin: origin,
      destination: destination,
      waypoints: waypoints
    };
   
    switch (travelMode) {
      case "bicycling":
        request.travelMode = google.maps.DirectionsTravelMode.BICYCLING;
        break;
      case "driving":
        request.travelMode = google.maps.DirectionsTravelMode.DRIVING;
        break;
      case "walking":
        request.travelMode = google.maps.DirectionsTravelMode.WALKING;
        break;
    }
    
    directionsService.route(request, function(response, status) {
      if (status == google.maps.DirectionsStatus.OK) {
        elevationService.getElevationAlongPath({
          path: response.routes[0].overview_path,
          samples: SAMPLES
        }, plotElevation);
      } else if (status == google.maps.DirectionsStatus.ZERO_RESULTS) {
        alert("Could not find a route between these points");
      } else {
        alert("Directions request failed");
      }
    });
  }

  function load_map(lat1, lon1, lat2, lon2) {
    reset();
    map.setMapTypeId(google.maps.MapTypeId.SATELLITE);
    //document.getElementById('mode').value = examples[n].travelMode;
    var bounds = new google.maps.LatLngBounds();
    /*for (var i = 0; i < examples[n].latlngs.length; i++) {
      var latlng = new google.maps.LatLng(
        examples[n].latlngs[i][0],
        examples[n].latlngs[i][1]
      );*/
	  var latlng = new google.maps.LatLng(lat1, lon1);
	  addMarker(latlng, false, false);
	  bounds.extend(latlng);
	  var latlng2 = new google.maps.LatLng(lat2, lon2);
	  addMarker(latlng2, false, false);
      bounds.extend(latlng2);
    //}
    map.fitBounds(bounds);
    updateElevation();
  }
    // Clear all overlays, reset the array of points, and hide the chart
  function reset() {
    if (polyline) {
      polyline.setMap(null);
    }
    
    for (var i in markers) {
      markers[i].setMap(null);
    }
    
    markers = [];
    
    document.getElementById('chart_div').style.display = 'none';
  }