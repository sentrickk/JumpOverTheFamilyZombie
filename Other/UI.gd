extends Control

var player

var l = "Lvl"
# Called when the node enters the scene tree for the first time.
func _ready():
	$ProgressBar.max_value = player.MaxHealth
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$ProgressBar.value = player.Health
	
	$Label3.text = str("Lvl " , player.Jlvl)
	
	if player.h == true:
		$Heal.visible = true
		$Heal/Timer.start(2.5)
		player.h = false
	
	if player.Win == true:
		$Win.visible = true
	
	if player.dead:
		$Label.visible = true


func _on_timer_timeout():
	$Heal.visible = false
	pass # Replace with function body.
