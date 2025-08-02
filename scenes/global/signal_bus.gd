extends Node

# UI
@warning_ignore("unused_signal")
signal update_ui() # only call this from PlayerVariables global script

# PomPom state
@warning_ignore("unused_signal")
signal pompom_lasso()
@warning_ignore("unused_signal")
signal pompom_died()
@warning_ignore("unused_signal")
signal pompom_capture()

# Level state
@warning_ignore("unused_signal")
signal level_passed()
@warning_ignore("unused_signal")
signal level_death()
