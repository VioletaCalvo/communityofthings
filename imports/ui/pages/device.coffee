Template.device.onCreated ->
  @getId = ->
    FlowRouter.getParam '_id'
  @autorun =>
    @subscribe 'device.ios', @getId()

Template.device.helpers
  device: ->
    id = FlowRouter.getParam '_id'
    device = Devices.findOne(id)
    userId = Meteor.userId()
    device.isConfigured = device.onlineStatus isnt 'not configured'
    if device.isConfigured
      device.DIs = IOs.find(deviceId: id, type: 'DI').map (io) -> io
      device.DOs = IOs.find(deviceId: id, type: 'DO').map (io) -> io
      device.AIs = IOs.find(deviceId: id, type: 'AI').map (io) -> io
      device.AOs = IOs.find(deviceId: id, type: 'AO').map (io) -> io
    device.disableControl =
      (device.onlineStatus isnt 'online') or \
      not ((userId is device.owner) or (userId in device.controlUsers))
    device.isMine = userId is device.owner
    device.isOnline = device.onlineStatus is 'online'
    device.lastUpdate = "#{device.updatedAt.toLocaleDateString()} -
                         #{device.updatedAt.toLocaleTimeString()}"
    device



Template.device.events
  'click #editDevice': ->
    FlowRouter.go 'device_edit', {_id:@_id}

  'change input': (e,tpl) ->
    switch @type
      when 'DO'
        inputValue = e.target.checked
      when 'AO'
        inputValue = parseInt(e.target.value)
      else
        return
    fields =
      id: @_id
      desired: inputValue
    return if fields.desired is @desiredValue
    Meteor.call 'io.update.value', fields, (err, res) ->
      if err
        sAlert.error err.reason

  'click .io-edit-btn': (e,tpl) ->
    FlowRouter.go 'io_edit', {_id: @_id}, {deviceId: @deviceId}
