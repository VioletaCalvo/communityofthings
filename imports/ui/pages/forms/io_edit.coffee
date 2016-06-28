Template.io_edit.onRendered ->
  @autorun ->
    # re-run this code on user change
    Meteor.user()
    Tracker.afterFlush ->
      Materialize.updateTextFields()
      $('.modal-trigger').leanModal()

Template.io_edit.helpers
  io: ->
    id = FlowRouter.getParam '_id'
    io = IOs.findOne(id)
    io.deviceName = Devices.findOne(io.deviceId).name
    io

Template.io_edit.events
  'click #update': (e, tpl)->
    id = FlowRouter.getParam '_id'
    fields =
      id: id
      name: $('#ioName').val().trim()
    io = IOs.findOne(id)
    if io.name is fields.name
      FlowRouter.go 'device', {_id: io.deviceId}
      sAlert.info "No changes"
      return
    Meteor.call 'io.update.customize', fields, (err, res) ->
      unless err
        sAlert.success 'IO sucessfully updated.'
        FlowRouter.go 'device', {_id: io.deviceId}
      else
        sAlert.error "Error: #{err.reason}"

  'click #delete': (e, tpl) ->
    id = FlowRouter.getParam '_id'
    Meteor.call 'io.delete', id, (err, res) ->
      unless err
        sAlert.success 'Device sucessfully removed.'
        deviceId = FlowRouter.getQueryParam 'deviceId'
        FlowRouter.go 'device', {_id: deviceId}
      else
        sAlert.error "Error: #{err.reason}"

  'click #cancel': ->
    deviceId = FlowRouter.getQueryParam 'deviceId'
    FlowRouter.go 'device', {_id: deviceId}
