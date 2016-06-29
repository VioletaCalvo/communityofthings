UpdateIOs =
  updateDbIOs: (deviceData) ->
    device = Devices.findOne(deviceData.deviceId)
    updatedIos = []
    now = new Date
    updatingIOs = false
    deviceFields =
      onlineStatus: 'online'
      updatedAt: now
    for io in deviceData.IO
      ioOld = IOs.findOne(ioId: io.id, deviceId: device._id)
      # if IO doesn't exists create it
      unless ioOld?
        fields =
          deviceId: deviceData.deviceId
          name: io.id
          ioId: io.id
          type: io.type
          unit: io.unit or undefined
          currentValue: io.value
          desiredValue:
            if io.type in ['DI', 'DO'] then io.value else undefined
          active: true
          createdAt : now
          updatedAt: now
        id = IOs.insert fields
        updatedIos.push id
      # otherwise update it
      else
        fields =
          ioId: io.id
          type: io.type
          active: true
          currentValue: io.value
          updatedAt: now
        # If a value is not the desired value updatingIOs will be true
        if (io.value isnt ioOld.desiredValue) and (io.type in ['DO', 'AO'])
          updatingIOs = true
        if io.unit then fields.unit = io.unit
        IOs.update ioOld._id, $set: fields
        updatedIos.push ioOld._id
    unless updatingIOs
      deviceFields.updatingsIOs = false
    # update IOs difference
    iosDifference = _.difference(device.io, updatedIos)
    # TODO: do not update non active ios all times
    # TODO: fix array unions...
    for ioId in iosDifference
      IOs.update ioId, $set: {active: false}
    unless iosDifference.length is 0
      # console.log 'iosUnion'
      # console.log _.union(updatedIos, device.io)
      devideFields.io = _.union(updatedIos, device.io)
    # update device
    Devices.update deviceData.deviceId, $set: fields

  createDbIOs: (deviceData) ->
    iosIds = []
    now = new Date
    for io in deviceData.IO
      fields =
        deviceId: deviceData.deviceId
        name: io.id
        ioId: io.id
        type: io.type
        unit: io.unit or undefined
        currentValue: io.value
        desiredValue: io.value
        active: true
        createdAt: now
        updatedAt: now
      id = IOs.insert fields
      iosIds.push id
    Devices.update deviceData.deviceId,
      $set:
        io: iosIds
        onlineStatus: 'online'
        updatedAt: now

  updateDeviceIOs: (deviceData) ->
    device = Devices.findOne(deviceData.deviceId)
    unless device.onlineStatus is 'online'
      Devices.update device._id, $set: {onlineStatus: 'online'}
    if device.updatingIOs is true
      desiredValues = []
      # Set mongo find filter and options
      query =
        deviceId: device._id,
        active:true,
        type:{$in:['DO', 'AO']}
      options =
        fields:
          ioId: 1
          currentValue: 1
          desiredValue: 1
      IOs.find(query, options).forEach (io) ->
        # for each io
        unless io.currentValue is io.desiredValue
          desired =
            id: io.ioId
            value: io.desiredValue
          desiredValues.push desired
      data =
        needs_update: true
        desired_values: desiredValues
    else
      data =
        needs_update: false


module.exports = UpdateIOs

# Function to update online status for a device
# offline time is 1 minute
offlineTime = 1000 * 60
onlineStatusUpdate = () ->
  now = new Date
  offlineTimeAgo = new Date(now.getTime() - offlineTime)
  query =
    onlineStatus: 'online'
    updatedAt: {$lt: offlineTimeAgo}
  update = {$set: {onlineStatus: 'offline', updatedAt: now}}
  options = {multi: true}
  Devices.update(query, update, options)

# check status every offlineTime (1 minute)
setInterval(Meteor.bindEnvironment(onlineStatusUpdate), offlineTime)
