extends RigidBody3D

@export var MoveSpeed = 100
@export var RotationSpeed := 8

var Model = $AnimatedSprite3D
var JumpInitialImpulse

var MoveDirection := Vector3.ZERO
var LastStrongDirection := Vector3.FORWARD
var LocalGravity := Vector3.DOWN
var ShouldRest := false

@onready var Sprite = $AnimatedSprite3D
@onready var StartPosition := global_transform.origin

func _ready() -> void:
	pass

func _integrate_forces(state: PhysicsDirectBodyState3D)-> void:

	if ShouldRest:
		state.transfom.origin = StartPosition
		ShouldRest = false
	
	LocalGravity = state.total_gravity.normalized()
	
	if MoveDirection.length() > 0.2:
		LastStrongDirection = MoveDirection.normalized()
		
	MoveDirection = GetModelOrientedInput()
	OrientCharacterToDirection(LastStrongDirection, state.step)
	
	if IsJumping(state):
		Model.Jump()
		apply_central_impulse(-LocalGravity * JumpInitialImpulse)
	if IsOnFloor(state) and not Model.IsFalling():
		add_constant_central_force(MoveDirection * MoveSpeed)
	Model.velocity = state.linear_velocity

func GetModelOrientedInput() -> Vector3:
	var inputLeftRight := (
		Input.get_action_strength("move_Left") 
		- Input.get_action_strength("move_Right")
	)
	
	var RawInput := Vector2(inputLeftRight, 0)
	var input := Vector3.ZERO
	
	input.x = RawInput.x * sqrt(1 - RawInput.y * RawInput.y / 2)
	input.y = RawInput.y * sqrt(1 - RawInput.x * RawInput.x / 2)
	
	input = Model.transform.basis.xform(input)
	return input

func OrientCharacterToDirection(direction: Vector3, delta: float) -> void:
	var LeftAxis := LocalGravity.cross(direction)
	var rotationBasis := Basis(LeftAxis, -LocalGravity, direction)
	Model.transform.basis = Model.transform.basis.get_rotation_quat().slerp(
		rotationBasis, delta * RotationSpeed
	)

func IsJumping(state: PhysicsDirectBodyState3D) -> bool:
	return true 

func ResetPosition() -> void:
	pass

func IsOnFloor(state: PhysicsDirectBodyState3D) -> bool:
	for contact in state.get_contact_count():
		var contactNormal = state.get_contact_local_normal(contact)
		if contactNormal.dot(-LocalGravity) > 0.5:
			return true
	return false
