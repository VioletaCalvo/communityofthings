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
    process.env.MAIL_URL = Meteor.settings.mailgun
  # Configure services
  ServiceConfiguration.configurations.upsert(
    { service: "google" },
    {
      $set: {
        clientId: "813783237966-f63g15l4e8r7utdcs4689rtpov7rlsa7.apps.googleusercontent.com",
        loginStyle: "popup",
        secret: "bcg2QdIBbyf--QdbZzM1jsD-"
      }
    }
  )
