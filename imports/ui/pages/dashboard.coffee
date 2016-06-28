Template.dashboard.onCreated ->
  $('.tooltipped').tooltip({delay: 50})

Template.dashboard.helpers
  ownDevices: ->
    devices = []
    Devices.find(owner: Meteor.userId()).forEach (device) ->
      if device.onlineStatus is 'online'
        device.icon = 'wifi_tethering'
        device.class = 'cyan lighten-2'
      else if device.onlineStatus is 'offline'
        device.icon = 'portable_wifi_off'
        device.class = 'grey'
      else
        device.icon = 'error_outline'
        device.class = 'orange lighten-3'
      devices.push device
    devices.lenght = devices.length
    devices
  isConfigured: ->
    not (@onlineStatus is 'not configured')


Template.dashboard.events
  'click #addDevice': (e,tpl) ->
    # $('#form_addDevice').openModal()
    FlowRouter.go('device_add')

  'click .collection-item': (e,tpl) ->
    FlowRouter.go 'device', {_id: @_id}
