function geocodeAndPlace(address, businessParam)
{  
  var geocoder = window.geocoder;
  var business = businessParam;
  geocoder.geocode( { 'address': address}, function(results, status) {
    if (status == google.maps.GeocoderStatus.OK) {
      window.map.setCenter(results[0].geometry.location);
      var marker = new google.maps.Marker({
        map: window.map,
        position: results[0].geometry.location,
        title: "Qley",
        icon: "/img/qlogo.png"
      });
      google.maps.event.addListener(marker, 'click', function() {
        if (window.curInfo != undefined)
        {
          window.curInfo.close();
        }
        window.curInfo = new google.maps.InfoWindow({
          content: "<h3>" + business.name + "</h3><img src=\"" + business.rating_img_url + "\"> " + business.review_count + " reviewers <h4>" + (business.display_phone === undefined ? "" : business.display_phone) + "</h4><img src=\"" + business.image_url + "\">"
        });
        window.curInfo.open(window.map,marker);
      });
    } else if (status === google.maps.GeocoderStatus.OVER_QUERY_LIMIT) {    
      setTimeout(function() {
        geocodeAndPlace(address, businessParam);
      }, 200);
    } else {
      console.error('Geocode was not successful for the following reason: ' + status);
    }
  });
}

function qleyCount(count) {
  var displayStr = count + " people have Qley'd this place.";
  if (count == 0) {
    displayStr = "No one has Qley'd this place.";
  } else if (count == 1) {
    displayStr = "1 person has Qley'd this place.";
  }
  return displayStr;
}