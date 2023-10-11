extends CharacterBody2D

var is_jumping = false
var is_dying = false

const ACCELERATION = 10.0
const DECCELERATION = 15.0
const AIR_DECCELERATION = 5.0
const MAX_SPEED = 200.0
const JUMP_VELOCITY = 300.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var gravity_multiplier = 1.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var death_timer: Timer = $DeathTimer

var max_jump = false

func _ready():
	is_dying = false
	add_to_group("Player")

func _physics_process(delta):
	if is_dying:
		return
	if not Input.is_action_pressed("jump") and is_jumping:
		gravity_multiplier = 2.0
	else:
		gravity_multiplier = 1.0
	# Add the gravity.		
	if not is_on_floor():
		velocity.y += gravity * gravity_multiplier * delta
	else:
		is_jumping = false

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -JUMP_VELOCITY
		is_jumping = true
	

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction = Input.get_action_strength("right") - Input.get_action_strength("left")
	
	if direction > 0:
		velocity.x = velocity.x + ACCELERATION if velocity.x < MAX_SPEED else MAX_SPEED
	elif direction < 0:
		velocity.x = velocity.x - ACCELERATION if velocity.x > -MAX_SPEED else -MAX_SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, (DECCELERATION if is_on_floor() else AIR_DECCELERATION))
	
	update_animation(direction)
	move_and_slide()
	
func update_animation(direction: int):
	if is_jumping:
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.flip_h = direction < 0
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")
	

func _on_hitbox_body_entered(body: Node2D):
	if body is Toad and (body as Toad).is_alive:
		die()
		
func die():
	if is_dying: 
		return
	is_dying = true
	animated_sprite.play("die")
	await player_death_movement()
	print()
	death_timer.start(1.0)


func player_death_movement():
	var start_position = position
	var up_position = start_position.y - 50
	var down_position = start_position.y + 300
	
	while position.y > up_position:
		position.y -= 2
		await get_tree().create_timer(0.01).timeout

	while position.y < down_position:
		position.y += 2
		await get_tree().create_timer(0.01).timeout

func _on_death_timer_timeout():
	get_tree().reload_current_scene()
