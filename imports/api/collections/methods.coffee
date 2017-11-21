#import { Email } from 'meteor/email'

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

  'device.share': (fields) ->
    return unless @userId
    check fields,
      userEmail: String
      deviceId: String
      rights: String
    return unless fields.rights in ['revoke', 'control', 'monitor']
    device = Devices.findOne(fields.deviceId)
    unless device?
      throw new Meteor.Error(404, 'Device not found.')
    unless device.owner is @userId
      throw new Meteor.Error(403, "You don't have rights to share this device.")
    unless @isSimulation
      user = Users.findOne('emails.address': fields.userEmail)
      unless user
        throw new Meteor.Error(404, 'User not found.')
      if fields.rights is 'control'
        if user._id in device.controlUsers
          res =
            message: "User with email '#{fields.userEmail}' has already control
                      rights for this device"
          return res
        else user.id in
          # update device
          Devices.update device._id,
            $addToSet:
              controlUsers: user._id
            $pull:
              monitorUsers: user._id
      else if fields.rights is 'monitor'
        if user._id in device.monitorUsers
          res =
            message: "User with email '#{fields.userEmail}' has already monitor
                      rights for this device"
          return res
        else
          # update device
          Devices.update device._id,
            $addToSet:
              monitorUsers: user._id
            $pull:
              controlUsers: user._id
      else
        unless (user._id in device.monitorUsers) or \
                (user._id in device.controlUsers)
          res =
            message: "User with email '#{fields.userEmail}' has not monitor or
                      control rights"
          return res
        else
          # update device
          Devices.update device._id,
            $pull:
              monitorUsers: user._id
              controlUsers:user._id
      # update user contacts
      Users.update @userId, $addToSet: {contacts: user._id}
      Users.update user._id, $addToSet: {contacts: @userId}

  'revoke.rights': (fields) ->
    return unless @userId
    check fields,
      deviceId: String
      userId: String
    device = Devices.findOne(fields.deviceId)
    unless device?
      throw new Meteor.Error(404, 'Device not found.')
    unless device.owner is @userId
      throw new Meteor.Error(403, "You don't have rights to share this device.")
    unless @isSimulation
      user = Users.findOne(fields.userId)
      unless user
        throw new Meteor.Error(404, 'User not found.')
      # update device
      Devices.update device._id,
        $pull:
          monitorUsers: user._id
          controlUsers:user._id

  'email.me.smtp': ->
    return unless @userId
    userEmail = Users.findOne(@userId).emails?[0]?.address
    throw new Meteor.Error(404, "User email not found") unless userEmail
    return if @isSimulation
    # Send via the SendGrid SMTP API, using meteor email package
    Email.send
      from: Meteor.settings.sendgrid.sender_email
      to: userEmail
      subject: "your template subject here"
      text: "template plain text here"
      html: "template body content here"
      headers:
        'X-SMTPAPI':
          {
            "filters": {
              "templates": {
                "settings": {
                  "enable": 1,
                  "template_id": 'c040acdc-f938-422a-bf67-044f85f5aa03'
                }
              }
            }
          }


  'email.me.webapi': ->
    return unless @userId
    userEmail = Users.findOne(@userId).emails?[0]?.address
    throw new Meteor.Error(404, "User email not found") unless userEmail?
    return if @isSimulation
    # Send via the SendGrid Web API v3, using meteor http package
    endpoint = 'https://api.sendgrid.com/v3/mail/send'
    options =
      headers:
        "Authorization": "Bearer #{Meteor.settings.sendgrid.api_key}"
        "Content-Type": "application/json"
      data:
        personalizations: [
          to: [ {email: userEmail} ]
          subject: 'the template subject'
        ]
        from:
          email: Meteor.settings.sendgrid.sender_email
        content: [{  type: "text/html", value: "your body content here" }]
        template_id: 'c040acdc-f938-422a-bf67-044f85f5aa03'

    result = HTTP.post endpoint, options
    console.log result
