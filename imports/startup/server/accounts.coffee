{ Accounts } = require 'meteor/accounts-base'
passwordEmail = require '/imports/ui/components/reset_pwd_email.coffee'

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


Accounts.emailTemplates.siteName = "communityofthings.tk"
Accounts.emailTemplates.from = "CoT accounts <no-reply@communityofthings.tk>"

Accounts.emailTemplates.resetPassword =
  from:() -> "CoT accounts <no-reply@communityofthings.tk>"
  subject: (user) -> "Reset your pasword on The Community of Things"
  text: (user, url) ->
    text =
      """Hello #{user.firtsName}!
         \n\n
         Click the link below to reset your password on The Community of Things
         (CoT).
         \n\n
         #{url}
         \n\n
         If you didn't this request, please ignore it.
         \n\n
         See you soon at The Community of Things!
         Thank you,
         \n\n
         \tThe CoT team
      """
    text
  html: (user, url) ->
    passwordEmail(user, url)




Meteor.startup ->
  console.log "***********Meteor app started************"
  if Meteor.settings.env is 'LOCAL'
    process.env.MAIL_URL = Meteor.settings.emailUrl
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
