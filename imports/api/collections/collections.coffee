{ Mongo } = require 'meteor/mongo'

# Define collections
@Users = Meteor.users
@Devices = new Mongo.Collection('Devices')
@IOs = new Mongo.Collection('IOs')

# Default rights
Users.allow
  update: ()-> false
  remove: ()-> false
  insert: ()-> false

Users.me = (attr)->
  fields = {}
  fields[attr] = 1
  Users.findOne(Meteor.userId(), fields:fields)?[attr]

Devices.allow
  update: -> false
  remove: -> false
  insert: -> false

IOs.allow
  update: -> false
  remove: -> false
  insert: -> false
