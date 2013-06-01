jQuery ($)->
  return unless $('#floodfinder').length > 0

  success =(position)->
    $('#spinnaz').hide()
    $('#privacy').hide()
    localgeo = $('#localgeo')
    localgeo.html(Mustache.render localgeo.html(), position)
    localgeo.show()
    
  error =(msg)->
    if (typeof msg == 'string')
      message = msg
    else
      message = "Unknown error."

    $('#nobueno').text(message).show()
    $('body').addClass('error')

  if !navigator.geolocation
    $('#nobueno').show()
    $('body').addClass('sample')
    return success(sample)

  $('#spinnaz').show()
  navigator.geolocation.getCurrentPosition(success, error)
