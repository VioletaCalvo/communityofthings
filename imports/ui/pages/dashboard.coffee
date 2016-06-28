Template.dashboard.onCreated ->
  $('.tooltipped').tooltip({delay: 50})

Template.dashboard.helpers
  ownDevices: ->
    Devices.find(owner: Meteor.userId()).map (device) ->
      if device.onlineStatus is 'online'
        device.icon = 'wifi_tethering'
        device.class = 'cyan lighten-2'
        device.isConfigured = true
      else if device.onlineStatus is 'offline'
        device.icon = 'portable_wifi_off'
        device.class = 'grey'
        device.isConfigured = true
      else
        device.icon = 'error_outline'
        device.class = 'orange lighten-3'
        device.isConfigured = false
      device
  otherDevices: ->
    me = Meteor.userId()
    query =
      $or: [{controlUsers: me}, {monitorUsers: me}]
    Devices.find(query).map (device) ->
      if device.onlineStatus is 'online'
        device.icon = 'wifi_tethering'
        device.class = 'cyan lighten-2'
      else if device.onlineStatus is 'offline'
        device.icon = 'portable_wifi_off'
        device.class = 'grey'
      else
        device.icon = 'error_outline'
        device.class = 'orange lighten-3'
      device.ownerName =
        Users.findOne(device.owner)?.firstName
      device


Template.dashboard.events
  'click #addDevice': (e,tpl) ->
    # $('#form_addDevice').openModal()
    FlowRouter.go('device_add')

  'click .collection-item': (e,tpl) ->
    FlowRouter.go 'device', {_id: @_id}
