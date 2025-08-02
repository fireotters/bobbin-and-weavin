extends Control

@onready var label_level_value: Label = %label_level_value
@onready var label_remaining_value: Label = %label_remaining_value
@onready var label_rescued_value: Label = %label_rescued_value

@onready var panel_pause: CanvasLayer = $panel_pause

@onready var panel_gameover: CanvasLayer = $panel_gameover
@onready var label_gameover_score: RichTextLabel = %label_gameover_score
@onready var label_gameover_bestscore: RichTextLabel = %label_gameover_bestscore
@onready var lineedit_highscorename: LineEdit = %lineedit_highscorename

var game_is_over = false

func _ready() -> void:
	SignalBus.update_ui.connect(_update_hud)
	SignalBus.level_death.connect(_game_over)
	_update_hud()

func _update_hud():
	print("HUD updated, signal told us to")
	label_level_value.text = str(PlayerVariables.level)
	label_remaining_value.text = str(
		PlayerVariables.num_of_poms - PlayerVariables.pom_rescues - PlayerVariables.pom_deaths
		)
	label_rescued_value.text = str(PlayerVariables.pom_rescues) + "/" + str(PlayerVariables.num_of_poms - PlayerVariables.allowed_max_deaths)


# -------------------------------------
# Pause dialog
# -------------------------------------
func pause():
	if not game_is_over:
		Engine.time_scale = 0
		panel_pause.visible = true
		AudioPlayer.pause_music()
func resume():
	if not game_is_over:
		Engine.time_scale = 1
		panel_pause.visible = false
		AudioPlayer.resume_music()

func _on_btn_pause_pressed() -> void:
	pause()
func _input(_event):
	if Input.is_action_just_pressed("pause"):
		if panel_pause.visible:
			resume()
		else:
			pause()
			
func _on_btn_resume_pressed() -> void:
	resume()
	
# -------------------------------------
# Game Over & Pause Screen (shared buttons)
# -------------------------------------
func _on_btn_restart_pressed() -> void:
	if game_is_over:
		_save_highscore()
	AudioPlayer.stop()
	PlayerVariables.reset_game()

func _on_btn_exit_pressed() -> void:
	if game_is_over:
		_save_highscore()
		
func _save_highscore():
	if lineedit_highscorename.visible:
		ConfigfileHandler.save_high_score_setting("score", PlayerVariables.total_rescued_this_game)
		if lineedit_highscorename.text != "":
			ConfigfileHandler.save_high_score_setting("nickname", lineedit_highscorename.text)
		else:
			ConfigfileHandler.save_high_score_setting("nickname", "")

# -------------------------------------
# Game Over
# -------------------------------------
func _game_over():
	game_is_over = true
	Engine.time_scale = 0
	panel_gameover.visible = true
	var best_score = ConfigfileHandler.load_high_score_settings()["score"]
	if PlayerVariables.total_rescued_this_game > best_score:
		label_gameover_score.text = "Total Saved: " + str(PlayerVariables.total_rescued_this_game)
		label_gameover_bestscore.text = "New Best Score!"
		lineedit_highscorename.visible = true
	else:
		label_gameover_score.text = "Total Saved: " + str(PlayerVariables.total_rescued_this_game)
		label_gameover_bestscore.text = "Your Best Score: " + str(best_score)
	AudioPlayer.pause_music()
