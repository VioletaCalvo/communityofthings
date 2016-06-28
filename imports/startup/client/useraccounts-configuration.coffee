{ AccountsTemplates } = require 'meteor/useraccounts:core'

require '/imports/ui/layouts/layout.jade'

# submitError = (error, state) ->
#   if error
#     err = error.reason.split('error.accounts.')
#     sAlert.error err[1]

onLogout = ->
  Meteor.logout()
  FlowRouter.go '/'

AccountsTemplates.configure
  defaultLayoutType: 'blaze'
  defaultLayout: 'layoutLogin'
  showForgotPasswordLink: true
  overrideLoginErrors: true
  enablePasswordChange: true
  # sendVerificationEmail: true
  # enforceEmailVerification: true
  confirmPassword: false
  # forbidClientAccountCreation: true
  # formValidationFeedback: true
  homeRoutePath: '/dashboard'
  negativeValidation: true
  positiveValidation: true
  negativeFeedback: true
  positiveFeedback: true
  privacyUrl: 'privacy'
  termsUrl: 'terms-of-use'
  ## Appearance
  # showAddRemoveServices: false
  # showPlaceholders:true
  showLabels: true
  ## Client-side Validation
  continuousValidation: true
  texts:
    title:
      changePwd: ""
      enrollAccount: ""
      forgotPwd: ""
      resetPwd: ""
      signIn: ""
      signUp: ""
      verifyEmail: ""
  onLogoutHook: onLogout
  # onSubmitHook: submitError
