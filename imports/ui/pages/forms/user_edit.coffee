Template.user_edit.onRendered ->
  @autorun ->
    # re-run this code on user change
    Meteor.user()
    Tracker.afterFlush ->
      Materialize.updateTextFields()
      $('.modal-trigger').leanModal()

Template.user_edit.helpers
  user: -> Meteor.user()

Template.user_edit.events
  'click #updateUser': (e,tpl) ->
    fields =
      firstName: $('#firstName').val().trim()
      lastName: $('#lastName').val().trim()
    Meteor.call 'user.update', fields, (err, res) ->
      unless err
        sAlert.success 'Profile updated!'
        FlowRouter.go 'user', {_id:Meteor.userId()}
      else
        sAlert.error "Error: #{err.message}"

  'click #cancel': ->
    FlowRouter.go 'user', {_id:Meteor.userId()}
