extends Control

var Num = 0
@onready var start = $VBoxContainer/ButtonStart
@onready var exit = $VBoxContainer/ButtonExit 

@onready var buttonlist = {0: [start], 1: [exit]}

# Called when the node enters the scene tree for the first time.
func _ready():
	start.grab_focus()

func _input(event):
	
	if event.is_action_pressed("Attack") or event.is_action_pressed("Start"):
		if start.has_focus():
			_on_button_start_pressed()

func _on_button_start_pressed():
	$AudioStreamPlayer.play()
	$AudioStreamPlayer/Timer.start(.5)


func _on_button_exit_pressed():
	get_tree().quit()
	


func _on_timer_timeout():
	get_tree().change_scene_to_file("res://TestLevel.tscn")
	pass # Replace with function body.
