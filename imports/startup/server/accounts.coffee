urlModule = require('url')

Accounts.onCreateUser (options, user)->
  googleData = user.services['google']
  if googleData?
    user.emails = [
      address: googleData.email
      verified: googleData.verified_email
    ]
    user.firstName = googleData.given_name
    user.lastName = googleData.family_name
    user.imgUrl = googleData.picture
  user


Meteor.startup ->
  if Meteor.settings.env is 'LOCAL'
    mailstring = Meteor.settings.mailgun
    process.env.MAIL_URL = Meteor.settings.mailgun
    mailUrl = urlModule.parse(mailstring)
    console.log mailUrl.protocol
  # Configure services
  ServiceConfiguration.configurations.upsert(
    { service: "google" },
    {
      $set: {
        clientId: Meteor.settings.google.id,
        loginStyle: "popup",
        secret: Meteor.settings.google.secret
      }
    }
  )
