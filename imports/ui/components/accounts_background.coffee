Template.accountsBackground.onRendered ->
  Tracker.afterFlush ->
    # initialize landing page slider
    $('.slider').slider({full_width: true, duration: 4000})
