{ _ } = require 'meteor/underscore'

UpdateIOs = require '/imports/api/io_api/io_update.coffee'

processResponse = (req, res) ->
  deviceData = JSON.parse(req.body.data)
  user = Users.findOne(req.body.userId)._id
  device = Devices.findOne(deviceData.deviceId)
  res.setHeader('Content-Type', 'application/json')
  unless device
    res.statusCode = 404
    res.end(JSON.stringify
      error:404,
      message: 'Device not found'
    )
  else unless user is device.owner
    res.statusCode = 403
    res.end(JSON.stringify
      error:403,
      message: 'You are not the owner of the device'
    )
  else unless deviceData.deviceKey is device.secret
    res.statusCode = 403
    res.end(JSON.stringify
      error:403,
      message: 'Device id/key mismatch'
    )
  else
    res.statusCode = 200


# DEFINE SERVER SIDE ROUTE (with Picker pakcage)
# Include body parse NPM package to parse received JSON

bodyParser = require('body-parser')
Picker.middleware(bodyParser.json())
Picker.middleware( bodyParser.urlencoded({ extended: false }))

# filter PUT HTTP methods
PUT = Picker.filter(
  (req, res) ->
    req.method is 'PUT'
)

PUT.route '/io_put', (params, req, res, next) ->
  processResponse(req, res)
  if res.statusCode is 200
    deviceData = JSON.parse(req.body.data)
    return unless deviceData.IO
    device = Devices.findOne(deviceData.deviceId)
    unless device.io.length
      UpdateIOs.createDbIOs(deviceData)
    else
      UpdateIOs.updateDbIOs(deviceData)
  res.end('Got it!')


# filter GET HTTP methods
GET = Picker.filter(
  (req, res) ->
    req.method is 'GET'
)

GET.route '/io_get', (params, req, res, next) ->
  processResponse(req, res)
  deviceData = JSON.parse(req.body.data)
  if res.statusCode is 200
    data = UpdateIOs.updateDeviceIOs(deviceData)
    res.end(JSON.stringify(data))
  res
