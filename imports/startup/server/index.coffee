# Set up some rate limiting and other important security settings.
require './security.coffee'
# Set up service configuration
# require './service_configuration.coffee'
require './accounts.coffee'
# This defines all the collections, publications and methods that the
# application provides as an API to the client.
require '/imports/api/collections/collections.coffee'
require '/imports/api/collections/methods.coffee'
require '/imports/api/collections/server/publications.coffee'
# Server API
require '/imports/api/io_api/server_side_api_routes.coffee'
