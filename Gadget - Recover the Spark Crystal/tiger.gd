extends CharacterBody2D
@export var gravity = 1500
@export var move_speed = 10
var direction = 0
var active = false
signal defeated
var deathspeed = 50
var death_anim = false

func _ready() -> void:
	$AnimatedSprite2D.play("walk")

func _physics_process(delta: float) -> void:
	velocity.y += gravity * delta
	if active:
		if direction ==  0:
			$AnimatedSprite2D.flip_h = false
			position.x += move_speed
		else:
			$AnimatedSprite2D.flip_h = true
			position.x -= move_speed
		move_and_slide()
	if position.y > 10000:
		queue_free()
	if death_anim:
		position.y -= deathspeed
		position.x -= 10
		deathspeed -= 2

func _on_area_2d_body_entered(body) -> void:
	if direction == 0:
		direction = 1
	else:
		direction = 0

func _on_defeated() -> void:
	active = false
	move_speed = 0
	$tiger/CollisionShape2D.queue_free()
	$CollisionShape2D.queue_free()
	death_anim = true
	$AnimatedSprite2D.play("death")


func _on_area_2d_area_entered(area: Area2D) -> void:
	active = true
