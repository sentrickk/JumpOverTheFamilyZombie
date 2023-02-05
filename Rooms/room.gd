extends Node3D

@onready var Objects = $Objects

@onready var list

var IsInRoom = false
# Called when the node enters the scene tree for the first time.
func _ready():
	list = $Objects.get_children()
	for each in list:
		each.Room = self
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if IsInRoom and not list.is_empty():
		for each in list:
			each.Tick(delta)
	pass


func _on_entered(area):
	if area.owner.name == "Player":
		IsInRoom = true
		for each in list:
			each.TurnOn(true)


func _on_exited(area):
	if area.owner.name == "Player":
		IsInRoom = false
		for each in list:
			each.TurnOn(false)


func KillZone_entered(area):
	if area.owner.name == "Player":
		
		area.owner.TakeDamage($Area3D2/CollisionShape3D.global_position, area.owner.MaxHealth)

	pass # Replace with function body.


func _on_area_3d_2_area_entered(area):
	if area.owner.name == "Player":
		area.owner.Win = true
	pass # Replace with function body.
