Template.device_share.onRendered ->
  @autorun ->
    # re-run this code on user change
    Meteor.user()
    Tracker.afterFlush ->
      Materialize.updateTextFields()


Template.device_share.helpers
  device: ->
    id = FlowRouter.getParam '_id'
    Devices.findOne(id)


Template.device_share.events
  'click #share': (e, tpl)->
    id = FlowRouter.getParam '_id'
    fields =
      deviceId: id
      userEmail: $('#userEmail').val().trim()
      rights: $("#rights input[type='radio']:checked").val()
    unless fields.userEmail.length > 4
      sAlert.error "A user email is required"
      return
    else unless fields.rights
      sAlert.error "Please, choose control or monitor rights"
      return
    Meteor.call 'device.share', fields, (err, res) ->
      unless err
        if res.message
          sAlert.info res.message
        else
          sAlert.success 'Device updated.'
          FlowRouter.go 'device', {_id: id}
      else
        sAlert.error "Error: #{err.reason}"

  'click #cancel': ->
    id = FlowRouter.getParam '_id'
    FlowRouter.go 'device', {_id: id}
