require './useraccounts-configuration.coffee'
require './routes.coffee'

require '/imports/api/collections/collections.coffee'
require '/imports/api/collections/methods.coffee'

Meteor.startup ->
  sAlert.config
    effect: 'stackslide'
    position: 'bottom-right'
    timeout: 10000
    onRouteClose: false
    stack: true
    offset: 0
