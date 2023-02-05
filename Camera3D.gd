extends Camera3D

@export var FollowLook = false
var DesiredPositionX : float
var DesiredPositionY : float
var CurrentPositionX : float
var CurrentPositionY : float
var playerPosition : Vector3
@export var Offset : Vector3 = Vector3(0, 3.5, 12)
var timeY : float = 0.1
var timeX : float = 0.1

@export var DistanceX = 5
@export var DistanceY = 10
var BaseX : int
var BaseY : int
var Look : Vector3

func _ready():
	global_position = $"../Player".global_position
	BaseX = DistanceX
	BaseY = DistanceY
	
func _physics_process(delta) -> void:
	playerPosition = $"../Player".global_position
	
	Look = lerp(Look, playerPosition, 0.05)
	
	Offset.y = lerp(Offset.y, 2 + ($"../Player".JumpHeight / 2), 0.01)
	Offset.z = lerp(Offset.z, 5 + ($"../Player".JumpHeight), 0.01)
	
	if $"../Player".Follow:
		look_at(Vector3(Look))
	else:
		print(global_rotation_degrees)
		global_rotation_degrees = Vector3(-10.2, 0, 0)
		pass
	
	if  ((DesiredPositionX - playerPosition.x) >= DistanceX 
	or (DesiredPositionX - playerPosition.x) <= -DistanceX ) and not FollowLook:
		CurrentPositionX = playerPosition.x
		DistanceX = 1
		timeX = 0.05
	else:
		CurrentPositionX = playerPosition.x
		DistanceX = BaseX
		timeX = 0.03
	
	if $"../Player".is_on_floor():
		CurrentPositionY = playerPosition.y
		DistanceY = BaseY
		#timeY = 0.05
		if not FollowLook:
			timeY = 0.05
		else:
			timeY = 0.02
	elif  ((DesiredPositionY - playerPosition.y) >= DistanceY 
	or (DesiredPositionY - playerPosition.y) <= -DistanceY):
		CurrentPositionY = playerPosition.y
		DistanceY = 2
		timeY = 0.05
		
		
	
	DesiredPositionX = lerp(DesiredPositionX, CurrentPositionX, timeX) 
	DesiredPositionY = lerp(DesiredPositionY, CurrentPositionY, timeY) 
	
	global_position = Vector3(DesiredPositionX, DesiredPositionY , 0.0 ) + Offset
