class_name Player
extends CharacterBody3D

@onready var Sprite = $AnimatedSprite3D

@export var MoveSpeed = 10.0
var baseSpeed = 10
var DesiredSpeedY : float
var DesiredSpeedX : float


@export var JumpHeight : float
@export var JumpTimeToPeak : float
@export var JumpTimeToDescent : float

@onready var JumpVelocity : float = (2.0 * JumpHeight) / JumpTimeToPeak
@onready var JumpGravity : float  = (-2.0 * JumpHeight) / (JumpTimeToPeak * JumpTimeToPeak)
@onready var FallGravity : float  = (-2.0 * JumpHeight) / (JumpTimeToDescent * JumpTimeToDescent)

#jump buffering
@export var JumpBufferTime : float = 0.1
var BufferTimer: float = 0.0

#coyote time
@export var Coyote : float = 0.5
var CoyoteTimer : float = 0
var CanCoyote = true
var flip = false

var Attacking = false
var DamageAmount = 1

@export var MaxHealth = 10
var Health = 10
var dead = false
var Knocked = false
@export var KnockbackMod = 1

func _ready():
	Health = MaxHealth
	baseSpeed = MoveSpeed

var Grounded = true

func _physics_process(delta) -> void:
	if not dead:
	#handel movement and gravity
		DesiredSpeedX = GetInputVelocity() * MoveSpeed
		if DesiredSpeedX != 0:
			if moving == false:
				moving = true
				$AudioStep.play()
		else:
			moving = false
			$AudioStep.stop()
		velocity.x = lerp(velocity.x, DesiredSpeedX, 0.1)
	
		velocity.y += GetGravity() * delta
		move_and_slide()
	
		#handel when jumping and Coyote
		BufferTimer -= delta
		CoyoteTimer -= delta
	
		HandleAnimation()
	
		if is_on_floor():
			CanCoyote = true
			if BufferTimer > 0:
				Jump()
			if not Grounded:
				$AudioLand.play()
				Grounded = true
		else:
			HandelJumpPush()
			if CanCoyote and CoyoteTimer < 0:
				CoyoteTimer = Coyote
			if CanCoyote and CoyoteTimer > 0 and BufferTimer > 0:
				Jump()
			Grounded = false
	else: 
		
		$CollisionShape3D.disabled = true
		$DamagedArea/CollisionShape3D.disabled = true

func _input(event):
	if Input.is_action_just_pressed("Jump"):
		BufferTimer = JumpBufferTime
	
	elif Input.is_action_just_pressed("Attack"):
		if Attacking == false:
			Attack()
	elif Input.is_action_just_pressed("Start"):
			if dead:
				_on_dead_timeout()
	elif Input.is_action_just_pressed("Follow"):
		if Follow:
			Follow = false
		else:
			Follow = true
	
func Attack():
	Attacking = true
	MoveSpeed = 0
	if not Sprite.flip_h:
		$AttackArea/CollisionShape3D.position.x = 1.2
		Sprite.flip_h = false
	else:
		$AttackArea/CollisionShape3D.position.x = -1.2
		Sprite.flip_h = true
		
	$AttackArea/CollisionShape3D.disabled = false
	$AttackArea/Timer.start(0.5)

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
	$AudioJump.play()
	velocity.y = JumpVelocity
	CanCoyote = false

#handel Push off ledges
func HandelJumpPush():
	if ($RayCast_Right.is_colliding() and $RayCast_RightInner.is_colliding() 
	and !$RayCast_LeftInner.is_colliding() and !$RayCast_Left.is_colliding()):
		global_position.x -= .3
	elif (!$RayCast_Right.is_colliding() and!$RayCast_RightInner.is_colliding() 
	and $RayCast_LeftInner.is_colliding() and $RayCast_Left.is_colliding()):
		global_position.x += .3

var moving = false

func GetInputVelocity() -> float:
	var horizontal := 0.0
	if Input.is_action_pressed("move_Left") and not Attacking:
		horizontal -= 1.0
		
		Sprite.flip_h = true
	if Input.is_action_pressed("move_Right") and not Attacking:
		horizontal += 1.0
		Sprite.flip_h = false
	return horizontal

func HandleAnimation():
	flip = Sprite.flip_h
	if Knocked:
		Sprite.play("TakeDamage", flip)
	elif Attacking:
		Sprite.play("Attack", flip)
	elif is_on_floor():
		if velocity.x < 1 and velocity.x > -1 :
			Sprite.play("Idle", flip)
		else:
			Sprite.play("Move_Right", flip)
			Sprite.speed_scale = velocity.x / 5
	
	elif velocity.y < 1 and velocity.y > -1 :
		Sprite.play("Jump_Apex")
	elif velocity.y > 0:
		Sprite.play("Jump_Start")
	elif velocity.y < 0:
		Sprite.play("Jump_Fall")

func _on_timer_timeout():
	$AttackArea/CollisionShape3D.disabled = true
	MoveSpeed = baseSpeed
	Attacking = false
	pass # Replace with function body.

func TakeDamage(DamageSource : Vector3, amount : int):
	if Knocked == false:
		Knocked = true
		MoveSpeed = 0
		$AudioDamage.play()
		Sprite.modulate = Color(255, 0, 0)
		if DamageSource.x > position.x :
			velocity.x = abs(velocity.x)  * -2
		else:
			velocity.x = abs(velocity.x) * 2
			
		var KnockbackDirection = DamageSource.direction_to(self.global_position)
		var Knockback = KnockbackDirection * KnockbackMod
		global_position.x += Knockback.x
		Heal(-amount)
		if not dead:
			$DamagedArea/Timer.start(.5)
		else:
			$DamagedArea/Timer/Dead.start(5)

var h = false
func Heal(amount):
	if amount > 0:
		h = true
		$AudioPower.play()
	Health += amount
	if Health <= 0:
			Knocked = false
			dead = true
			Sprite.play("Death", flip)
	elif Health >= MaxHealth:
		Health = MaxHealth
	

func _on_entered(area):
	area.owner.TakeDamage(self.global_position, DamageAmount)
	pass # Replace with function body.


func Damaged_timeout():
	Knocked = false
	Sprite.modulate = Color(255, 255, 255)
	MoveSpeed = baseSpeed

var Jlvl = 1
func ChangeJump(Amount):
	$AudioPower.play()
	JumpHeight += Amount
	Jlvl += 1
	JumpVelocity = (2.0 * JumpHeight) / JumpTimeToPeak
	JumpGravity = (-2.0 * JumpHeight) / (JumpTimeToPeak * JumpTimeToPeak)
	FallGravity = (-2.0 * JumpHeight) / (JumpTimeToDescent * JumpTimeToDescent)


func _on_dead_timeout():
	get_tree().change_scene_to_file("res://TestLevel.tscn")


func _on_audio_step_finished():
	if moving:
		$AudioStep.play()
	pass # Replace with function body.

var Win = false
var Follow = false
