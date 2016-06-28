Template.device_add.events
  'click #addDevice': (e, tpl)->
    # TODO validate form
    deviceName = $('#deviceName').val()
    Meteor.call 'device.new', deviceName, (err, res) ->
      # this method returns the device id
      unless err
        sAlert.info 'Your device has already added!\n Please use credentials in
          your device Python code.'
        FlowRouter.go 'device', {_id: res}
      else
        sAlert.error "Error: #{err.reason}"

  'click #cancel': ->
    FlowRouter.go 'dashboard'
