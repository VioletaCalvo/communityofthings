Template.device_edit.onRendered ->
  FlowRouter.subsReady 'deviceIos', ->
    Tracker.afterFlush ->
      Materialize.updateTextFields()
      $('.modal-trigger').leanModal()


Template.device_edit.helpers
  device: ->
    id = FlowRouter.getParam '_id'
    Devices.findOne(id)

Template.device_edit.events
  'click #update': (e, tpl)->
    id = FlowRouter.getParam '_id'
    # TODO validate form
    fields =
      id: id
      name: $('#deviceName').val()
    device = Devices.findOne(id)
    if device.name is fields.name
      FlowRouter.go 'device', {_id: id}
      sAlert.info "No changes"
      return
    Meteor.call 'device.update', fields, (err, res) ->
      unless err
        sAlert.success 'Device sucessfully updated.'
        FlowRouter.go 'device', {_id: id}
      else
        sAlert.error "Error: #{err.reason}"

  'click #delete': (e, tpl) ->
    id = FlowRouter.getParam '_id'
    Meteor.call 'device.delete', id, (err, res) ->
      unless err
        sAlert.success 'Device sucessfully deleted.'
        FlowRouter.go 'device', {_id: id}
      else
        sAlert.error "Error: #{err.reason}"

  'click #cancel': ->
    id = FlowRouter.getParam '_id'
    FlowRouter.go 'device', {_id: id}
