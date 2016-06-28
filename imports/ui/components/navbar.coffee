Template.navbar.onRendered ->
  $(".button-collapse").sideNav({
    closeOnClick: true
    })
  $(".dropdown-button").dropdown()
  route = FlowRouter.getRouteName
  if route is 'dashboard'
    $("#goDashboard").addClass('active')
  else if route is 'user'
    $("#goMyProfile").addClass('active')


Template.navbar.helpers
  myPofileUrl: -> "/user/#{Meteor.userId()}"

Template.navbar.events
  'click #logout': ->
    $('.button-collapse').sideNav('hide')
    AccountsTemplates.logout()

  'click #goMyProfile': ->
    FlowRouter.go 'user', {_id: Meteor.userId()}
