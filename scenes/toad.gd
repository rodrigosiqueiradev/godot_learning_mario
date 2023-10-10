extends CharacterBody2D

class_name Toad

const SPEED = 25.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_alive = true

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	add_to_group("Enemy")

func _physics_process(delta):
	velocity.y += gravity * delta
	
	velocity.x = -SPEED
	
	update_animation()
	move_and_slide()
	
func update_animation():
	animated_sprite.play("walk")


func _on_hitbox_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		is_alive = false
		queue_free()
	
