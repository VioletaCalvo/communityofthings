Meteor.methods
  # Update my profile
  'user.update': (profile)->
    return unless @userId
    check profile,
      firstName: String
      lastName: String
      imgId: Match.Optional(String)
    fields =
      firstName: profile.firstName.trim()
      lastName: profile.lastName.trim()
      hasCompletedProfile: true
      updatedAt: new Date
    fields.imgId = profile.imgId if profile.imgId
    Users.update @userId, $set:fields

  'device.new': (deviceName) ->
    return unless @userId
    check deviceName, String
    secret = Random.secret()
    fields =
      name: deviceName
      onlineStatus: 'not configured'
      active: true
      updatingIOs: false
      owner: @userId
      secret: secret
      io: []
      monitorUsers: []
      controlUsers: []
      createdAt: new Date
      updatedAt: new Date
    Devices.insert fields

  'device.delete': (id) ->
    return unless @userId
    check id, String
    device = Devices.findOne(id)
    unless device.owner is @userId
      throw new Meteor.Error(403,
        'You cannot delete this device. The well configured device is not
        yours!')
    Devices.remove id

  'device.update': (fields) ->
    return unless @userId
    check fields,
      id: String
      name: String
    device = Devices.findOne(fields.id)
    unless device.owner is @userId
      throw new Meteor.Error(403,
        'You cannot edit this device. The device is not yours!')
    unless device
      throw new Meteor.Error(403, 'Device not found')
    Devices.update fields.id, $set:{name: fields.name}

  'io.update.value': (fields) ->
    return unless @userId
    check fields,
      id: String,
      desired: Match.OneOf(Boolean, Number)
    io = IOs.findOne(fields.id, type:{$in:['DO', 'AO']}, active:true)
    unless io?
      throw new Meteor.Error(404, 'IO not found.')
    device = Devices.findOne(io.deviceId)
    unless device?
      throw new Meteor.Error(404, 'Device not found.')
    return if (io.desiredValue is fields.desired) and device.updatingIOs
    unless (device.owner is @userId) or (@userId in device.controlUsers)
      throw new Meteor.Error(403, 'You no have rights to update this IO.')
    # check is a valid desired value
    isValid = false
    switch io.type
      when 'DO'
        isValid = true if typeof fields.desired is 'boolean'
      when 'AO'
        isValid = true if fields.desired >= 0 and fields.desired < 256
    unless isValid
      throw new Meteor.Error(403, 'Desired value is not valid')
    IOs.update io._id, $set: {desiredValue: fields.desired}
    unless device.updatingIOs or (io.currentValue is fields.desired)
      Devices.update device._id, $set: {updatingIOs: true}


  'io.update.customize': (fields) ->
    return unless @userId
    check fields,
      id: String,
      name: String
    io = IOs.findOne(fields.id)
    unless io?
      throw new Meteor.Error(404, 'IO not found.')
    return if io.desiredValue is fields.desired
    device = Devices.findOne(io.deviceId)
    unless device?
      throw new Meteor.Error(404, 'Device not found.')
    unless device.owner is @userId
      throw new Meteor.Error(403, 'You no have rights to update this IO.')
    IOs.update io._id, $set: {name: fields.name}

  'io.delete': (id) ->
    return unless @userId
    check id, String
    io = IOs.findOne(id)
    unless io?
      throw new Meteor.Error(404, 'IO not found.')
    device = Devices.findOne(io.deviceId)
    unless device?
      throw new Meteor.Error(404, 'Device not found.')
    unless device.owner is @userId
      throw new Meteor.Error(403, 'You no have rights to remove this IO.')
    IOs.remove io._id
