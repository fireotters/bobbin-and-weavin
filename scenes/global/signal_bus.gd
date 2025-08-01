extends Node

@warning_ignore("unused_signal")
signal update_ui() # only call this from PlayerVariables global script

@warning_ignore("unused_signal")
signal enemy_died(enemy_type:String, points:int)
