extends CharacterBody3D

@export var Name :String

@onready var Sprite = $AnimatedSprite3D

@export var MoveSpeed = 5.0
var baseSpeed = 5
var DesiredSpeedY : float
var DesiredSpeedX : float

@export var JumpHeight : float = 5
@export var JumpTimeToPeak : float = 1.0
@export var JumpTimeToDescent : float = 1.0

@onready var JumpVelocity : float = (2.0 * JumpHeight) / JumpTimeToPeak
@onready var JumpGravity : float  = (-2.0 * JumpHeight) / (JumpTimeToPeak * JumpTimeToPeak)
@onready var FallGravity : float  = (-2.0 * JumpHeight) / (JumpTimeToDescent * JumpTimeToDescent)

@export var GoLeft = false
var Direction = 1.0

@export var health = 3
var Knocked = false
@export var KnockbackMod : float = 1
var dead = false

@export var DamageAmount = 1

var Room

# Called when the node enters the scene tree for the first time.
func _ready():
	$Node3D/SubViewport/Label2.text = Name
	TurnOn(false)
	baseSpeed = MoveSpeed
	$AudioStep.pitch_scale = randi_range(0.7, 0.9)
	if GoLeft:
		ChangeDirection(false, position)

var moving = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func Tick(delta):
	if dead:
		$CollisionShape3D.disabled = true
		$Area3D/CollisionShape3D.disabled = true
	else:
		DesiredSpeedX = Movement() * MoveSpeed
		if DesiredSpeedX != 0:
			if moving == false:
				moving = true
				$AudioStep.play()
		else:
			moving = false
			$AudioStep.stop()
		velocity.x = lerp(velocity.x, DesiredSpeedX, 0.05)
	
		velocity.y += GetGravity() * delta
		move_and_slide()
		HandleAnimation()

func ChangeDirection(bo, loc : Vector3):
	if bo:
		if loc.x > position.x:
			Direction = -1
			$RayCast3D.position.x = -1
		else:
			Direction = 1
			$RayCast3D.position.x = 1
	else:
		Direction = Direction * -1
		$RayCast3D.position.x *= -1

func GetGravity() -> float:
	var grav : float
	if velocity.y > 2:
		grav = JumpGravity
	elif velocity.y < 2: 
		grav = FallGravity
	else:
		grav = lerp(JumpGravity, FallGravity, 0.05)
	return grav

func Jump():
	velocity.y = JumpVelocity

func Movement() -> float:
	if Knocked or dead:
		MoveSpeed = 0
	else:
		MoveSpeed = baseSpeed
		if is_on_wall() or $RayCast3D.is_colliding() == false:
			ChangeDirection(false, position)
	return Direction

var flip = false
func HandleAnimation():
	flip = Sprite.flip_h
	if Knocked:
		Sprite.play("TakeDamage", flip)
	elif is_on_floor():
		if velocity.x < 2 and velocity.x > -2 :
			Sprite.play("Idle", flip)
		else:
			Sprite.play("Move_Right", flip)
			Sprite.speed_scale = velocity.x / 5
			if Direction > 0:
				Sprite.flip_h = false
			else:
				Sprite.flip_h = true
	
	elif velocity.y < 1 and velocity.y > -1 :
		Sprite.play("Jump_Apex", flip)
	elif velocity.y > 0:
		Sprite.play("Jump_Start", flip)
	elif velocity.y < 0:
		Sprite.play("Jump_Fall", flip)

func TakeDamage(DamageSource : Vector3, amount : int):
	if Knocked == false:
		Knocked = true
		$AudioHurt.play()
		if DamageSource.x > position.x and Direction > 0:
			velocity.x = abs(velocity.x)  * -KnockbackMod
		else:
			velocity.x = abs(velocity.x) * KnockbackMod
		Sprite.modulate = Color(255, 0, 0)
		var KnockbackDirection = DamageSource.direction_to(self.global_position)
		var KnockbackStrength = amount * KnockbackMod
		var Knockback = KnockbackDirection * KnockbackStrength
		global_position.x += Knockback.x
		health -= amount
		ChangeDirection(true, DamageSource)
		if health <= 0:
			Knocked = false
			dead = true
			Sprite.play("Death", flip)
		else:
			$Timer.start(.5)
	


func _on_timer_timeout():
	Knocked = false
	Sprite.modulate = Color(255, 255, 255)


func _on_entered(area):
	if area.owner.name == "Player":
		area.owner.TakeDamage(self.global_position, DamageAmount)
		ChangeDirection(true, area.owner.position)

func TurnOn(yes : bool):
	if yes:
		pass
	#else:


func step_finished():
	if moving:
		$AudioStep.play()
	pass # Replace with function body.
