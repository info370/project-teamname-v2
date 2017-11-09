$(document).ready(function() {
    var map, infoWindow, geocoder;

    detectBrowser();
    init();

    $('#find-address').click(function(event) {
        codeAddress();

    })

    /*
     * Initialize the map. Give it a default of Seattle 
     */
    function init() {
        var seattle = {lat: 47.60, lng: -122.33};

        map = new google.maps.Map(document.getElementById('map'), {
            zoom: 15,
            center: seattle
        });

        // Attempt to get the user's location, center the map on it
        infoWindow = new google.maps.InfoWindow;
        if (navigator.geolocation) {
          navigator.geolocation.getCurrentPosition(function(position) {
            var pos = {
              lat: position.coords.latitude,
              lng: position.coords.longitude
            };

            map.setCenter(pos);
          }, function() {
            handleLocationError(true, infoWindow, map.getCenter());
          });
        } else {
          // Browser doesn't support Geolocation
          handleLocationError(false, infoWindow, map.getCenter());
        }

        geocoder = new google.maps.Geocoder();
    }

    /*
     * applies some default styles to the map for mobile/desktop
     */
    function detectBrowser() {
        var useragent = navigator.userAgent;
        var mapdiv = document.getElementById('map');

        if(useragent.indexOf('iPhone') != -1 || useragent.indexOf('Android') != -1) {
            mapdiv.classList.add('map-mobile');
        } else {
            mapdiv.classList.add('map-desktop');
        }
    }

    /*
     * handles gracefully when a geolocation error occurs
     */
    function handleLocationError(browserHasGeolocation, infoWindow, pos) {
        infoWindow.setPosition(pos);
        infoWindow.setContent(browserHasGeolocation ?
                                'Error: The Geolocation service failed.' :
                                'Error: Your browser doesn\'t support geolocation.');
        infoWindow.open(map);
    }

    function codeAddress() {
        var address = $('#address').val();
        geocoder.geocode( { 'address': address}, function(results, status) {
        if (status == 'OK') {
            //map.setCenter(results[0].geometry.location);
            var marker = new google.maps.Marker({
                map: map,
                position: results[0].geometry.location
            });
        } else {
            alert('Geocode was not successful for the following reason: ' + status);
        }
        });
    }
})