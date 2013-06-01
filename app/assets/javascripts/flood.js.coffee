jQuery ($)->
  return unless $('#floodfinder')

  success (position)->
    alert('fart')

  if !navigator.geolocation
    $('#nobueno').show()
    $('body').addClass('sample')
    success(sample)
