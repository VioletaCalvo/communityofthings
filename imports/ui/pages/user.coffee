Template.user.helpers
  user: ->
    id = FlowRouter.getParam '_id'
    user = Users.findOne(id)
    user.email = user.emails?[0]?.address
    # TODO generate a random key on user creation (user may change this)
    user.secretKey = user._id
    user
  isMe: ->
    id = FlowRouter.getParam '_id'
    id is Meteor.userId()

Template.user.events
  'click #editProfile': ->
    FlowRouter.go 'user_edit'
