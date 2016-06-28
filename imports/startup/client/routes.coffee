# Imports
{ FlowRouter } = require 'meteor/kadira:flow-router'
{ BlazeLayout } = require 'meteor/kadira:blaze-layout'
{ AccountsTemplates } = require 'meteor/useraccounts:core'

# LAYOUTS
require '/imports/ui/layouts/layout.jade'
# PAGES
require '/imports/ui/pages/landing.jade'
require '/imports/ui/pages/landing.coffee'
require '/imports/ui/pages/community.jade'
require '/imports/ui/pages/dashboard.jade'
require '/imports/ui/pages/dashboard.coffee'
require '/imports/ui/pages/device.jade'
require '/imports/ui/pages/device.coffee'
require '/imports/ui/pages/user.jade'
require '/imports/ui/pages/user.coffee'
#forms
require '/imports/ui/pages/forms/device_add.jade'
require '/imports/ui/pages/forms/device_add.coffee'
require '/imports/ui/pages/forms/device_edit.jade'
require '/imports/ui/pages/forms/device_edit.coffee'
require '/imports/ui/pages/forms/device_share.jade'
require '/imports/ui/pages/forms/device_share.coffee'
require '/imports/ui/pages/forms/io_edit.jade'
require '/imports/ui/pages/forms/io_edit.coffee'
require '/imports/ui/pages/forms/user_edit.jade'
require '/imports/ui/pages/forms/user_edit.coffee'
# COMPONENTS#editDevice
require '/imports/ui/components/footer.jade'
require '/imports/ui/components/navbar.jade'
require '/imports/ui/components/navbar.coffee'
require '/imports/ui/components/accounts_background.jade'
require '/imports/ui/components/accounts_background.coffee'
# STYLESHEETS
require '/imports/ui/stylesheets/main.css'
require '/imports/ui/stylesheets/main.scss'

# helper functions
notFoundRedirect = ->
  if Meteor.userId()
    FlowRouter.go 'dashboard'
  else
    FlowRouter.go 'landing'

# Not found route
FlowRouter.notFound =
  action: ->
    BlazeLayout.render 'layoutLanding',
      content:'notFound'
    window.setTimeout(notFoundRedirect, 2000)

# Login
FlowRouter.route '/',
  name: 'landing'
  action: ->
    if Meteor.userId()
      FlowRouter.go 'dashboard'
    else
      BlazeLayout.render 'layoutLanding',
        content: 'landing'

## Function for app routes - need to follow conventions when writing template
appRoute = (path)->
  template = path.split('/')[1]
  FlowRouter.route path,
    triggersEnter: [AccountsTemplates.ensureSignedIn]
    name: template,
    subscriptions: (params, queryParams) ->
      @register 'myData', Meteor.subscribe('publish')
      if template in ['device', 'device_edit', 'device_share']
        @register 'deviceIos', Meteor.subscribe('device.ios', params._id)
        @register 'myContacts', Meteor.subscribe('my.contacts')
      else if template is 'io_edit'
        @register 'deviceIos', Meteor.subscribe('device.ios',
                                                      queryParams.deviceId)
      else if template is 'dashboard'
        @register 'myContacts', Meteor.subscribe('my.contacts')
    action: ->
      BlazeLayout.render 'layoutApp',
        content: template

## Routes
appRoutes = [ '/dashboard', '/user/:_id', '/user_edit',
           '/device/:_id', '/device_edit/:_id', '/device_share/:_id',
           '/device_add', '/io_edit/:_id']

## Function for other routes - need to follow conventions when writing template
otherRoute = (path)->
  template = path.split('/')[1]
  FlowRouter.route path,
    name: template,
    action: -> BlazeLayout.render 'layoutLanding',
      content: template

## Routes
otherRoutes = [ '/privacy', '/terms-of-use']

appRoute(route) for route in appRoutes
otherRoute(route) for route in otherRoutes

## USERACCOUNTS ROUTES
# AccountsTemplates.configureRoute('changePwd')
AccountsTemplates.configureRoute('forgotPwd')
AccountsTemplates.configureRoute('resetPwd')
AccountsTemplates.configureRoute('signIn')
AccountsTemplates.configureRoute('signUp')
AccountsTemplates.configureRoute('verifyEmail')
