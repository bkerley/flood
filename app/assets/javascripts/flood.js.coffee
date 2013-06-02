jQuery ($)->
  return unless $('#floodfinder').length > 0

  spin = {}
  (->
    spinnaz = $('#spinnaz')
    spin.ride = ->
      spinnaz.show()
    spin.stop = ->
      spinnaz.hide()
    )()

  t =(el, obj)->
    obj.round = ->
      (text, render)->
        Number(render(text)).toPrecision(3)
    obj.biground = ->
      (text, render)->
        Number(render(text)).toPrecision(6)

    el.html(Mustache.render el.html(), obj)

  map = (lat, long)->
    joined_latlong = [lat,long].join(',')
    params =
      api_key: 'AIzaSyCnp7JMG9xi9leGcwd1LllubYEB5x00UlY'
      center: joined_latlong
      zoom: 14
      size: "200x200"
      sensor: "true"
      markers: joined_latlong
    encoded_params = jQuery.param params
    url = "https://maps.google.com/maps/api/staticmap?#{encoded_params}"
    "<img src='#{url}' width='100' height='100' />"

  ajax =
    success: (data, status, jqx)->
      floodzone = $('#floodzone')
      t floodzone, data
      floodzone.show()
      spin.stop()

  geo = 
    success: (position)->
      spin.stop()
      $('#privacy').hide()
      localgeo = $('#localgeo')
      position.map_tag = map(position.coords.latitude, position.coords.longitude)
      t localgeo, position
      localgeo.show()
      spin.ride()
      $.ajax
        url: '/find'
        dataType: 'json'
        data: position.coords
        success: ajax.success
    error: (msg)->
      if (typeof msg == 'string')
        message = msg
      else
        message = "Unknown error."
      $('#nobueno').text(message).show()
      $('body').addClass('error')

  if !navigator.geolocation
    $('#nobueno').show()
    $('body').addClass('sample')
    # return geo.success(sample)

  spin.ride
  navigator.geolocation.getCurrentPosition(geo.success, geo.error)
