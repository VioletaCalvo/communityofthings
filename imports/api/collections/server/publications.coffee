# Imports
{ Meteor } = require 'meteor/meteor'

# my data, no need to subscribe
Meteor.publish null, ->
  return [] unless @userId
  # publish my data
  me =
    Meteor.users.find @userId,
      fields:
        firstName:1
        lastName:1
        imgUrl:1
  # publish my devices and devices I controll or I monitor
  query =
    $or: [{owner: @userId}, {controlUsers: @userId}, {monitorUsers: @userId}]
  fields =
    name:1
    onlineStatus:1
    active:1
    updatingIOs:1
    owner:1
    io:1
    updatedAt:1
  myDevices =
    Devices.find(query, fields: fields)
  [me, myDevices]


# device data, need to subscribe
Meteor.publish 'device.ios', (id) ->
  check id, String
  return [] unless @userId
  devicePrivate =
    Devices.findOne(id, fields:{owner:1, controlUsers:1, monitorUsers:1})
  return [] unless (@userId is devicePrivate.owner) or \
                   (@userId in devicePrivate.controlUsers) or \
                   (@userId in devicePrivate.monitorUsers)

  # DEVICE publication
  if @userId is devicePrivate.owner
    fields =
      secret:1
      controlUsers:1
      monitorUsers:1
    # publish only this data to the owner
    device = Devices.find(id, fields: fields)
  else
    # owner publication if @userId is not the owner
    from = Users.find(devicePrivate.owner, fields:{firstName:1, lastName:1})

  # IO publication
  ios = IOs.find(deviceId: id)

  # return
  if @userId is devicePrivate.owner
    cursors = [device, ios]
  else
    cursors = [from, ios]
  cursors
