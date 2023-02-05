extends Node3D

enum options {Healing, Jump}

@export var current = options.Healing

@export var Amount : float = 2

var Room

# Called when the node enters the scene tree for the first time.
func _ready():
	if current == options.Healing:
		$ParticlesJump.queue_free()
	elif current == options.Jump:
		$ParticlesHeal.queue_free()
	TurnOn(true)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	rotate(Vector3(0,1,0), .05)


func _on_entered(area):
	if area.owner.name == "Player":
		if current == options.Healing:
			area.owner.Heal(Amount)
			
		elif current == options.Jump:
			area.owner.ChangeJump(Amount)
		queue_free()


func TurnOn(yes : bool):
	if yes:
		if current == options.Healing:
			$ParticlesHeal.set_emitting(true)
		elif current == options.Jump:
			$ParticlesJump.set_emitting(true)
	else:
		if current == options.Healing:
			$ParticlesHeal.set_emitting(false)
		elif current == options.Jump:
			$ParticlesJump.set_emitting(false)
