extends Node3D

@export var DamageAmount : int = 1
@export var LevelColor : Color = Color(1, 0, 0)

var Room

# Called when the node enters the scene tree for the first time.
func _ready():
	
	$ParticlesHeal.process_material.set_color(LevelColor)
	pass # Replace with function body.

func Tick(delta):
	pass

func _on_area_3d_area_entered(area):
	if area.owner.name == "Player":
		area.owner.TakeDamage(self.global_position, DamageAmount)


func TurnOn(yes : bool):
	if yes:
		$ParticlesHeal.set_emitting(true)
		process_mode = Node.PROCESS_MODE_PAUSABLE
	else:
		$ParticlesHeal.set_emitting(false)
		process_mode = Node.PROCESS_MODE_DISABLED
