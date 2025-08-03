# Help from Godot Forums to get HTML5 links working: https://forum.godotengine.org/t/how-do-i-open-richtextlabel-bbcode-links-in-an-html5-export/23729
extends Control

@onready var page_1: Control = %page_1
@onready var page_2: Control = %page_2
@onready var page_3: Control = %page_3
@onready var page_4: Control = %page_4
@export var dev_urls: Array[RichTextLabel]

func _ready():
	# If HTML5, the browser handles URL requests from BBCode labels
	# If not HTML5, tell PC to open the URL in default browser
	if OS.get_name() != "HTML5":
		for dev_url in dev_urls:
			dev_url.connect("meta_clicked", _on_site_label_clicked)

func _on_site_label_clicked(meta):
	OS.shell_open(str(meta))

func turn_off_all_pages():
	page_1.visible = false
	page_2.visible = false
	page_3.visible = false
	page_4.visible = false

func _on_btn_to_page_2_pressed() -> void:
	turn_off_all_pages()
	page_2.visible = true

func _on_btn_to_page_3_pressed() -> void:
	turn_off_all_pages()
	page_3.visible = true

func _on_btn_to_page_4_pressed() -> void:
	turn_off_all_pages()
	page_4.visible = true
