# Meteor.startup ->
#   ServiceConfiguration.configurations.upsert(
#     { service: "google" },
#     {
#       $set: {
#         clientId: Meteor.settings.google.id,
#         loginStyle: "popup",
#         secret: Meteor.settings.google.secret
#       }
#     }
#   )
