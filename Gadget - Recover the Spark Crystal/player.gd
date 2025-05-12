extends CharacterBody2D

@export var gravity = 2500
@export var move_speed = 1200
@export var jump_speed = 100

var jumped = false
var longjumped = false
var dived = false
var diving = false
var divespeed = 0
var divehop = 0
var longjumpdir = "right"
var divedir = "right"
var direction = "right"
var score = 0
var battieriescollected = 0
var controlActive = true
var crouchControl = false
var jumpslow = 0
var moveslow = 0
var doublejump = true
var coins = 0
var lives = 3
var invincible = false
var checkposition1 = position.y
var checkposition2 = 0
var goingdown = false
var shorthop = false
var hopamount = 0

signal updatehud

func _ready() -> void:
	self.position.x = 550
	self.position.y = 300
	$AnimationPlayer.play("RESET")

func _physics_process(delta: float) -> void:
	position.y += gravity * delta
	move_and_slide()
	if is_on_floor():
		controlActive = true
		dived = false
		diving = false
	if controlActive:
		input()
	if Input.is_action_just_pressed("crouch") and is_on_floor():
		crouchControl = true
		$Gadget/AnimationPlayer.play("crouch")
	if Input.is_action_just_released("crouch"):
		crouchControl = false
	if checkposition1 - checkposition2 < -3:
		goingdown=true
	else:
		goingdown = false
	checkposition1 = checkposition2
	checkposition2 = position.y
	if shorthop:
		if hopamount != 0:
			position.y -= hopamount
			hopamount -= 1
		else:
			shorthop = false

func _process(delta: float) -> void:
	if jumped and jumpslow > 0:
		position.y -= jumpslow
		jumpslow -= 2
		if longjumped:
			if longjumpdir == "right":
				position.x += moveslow
			else:
				position.x -= moveslow
			moveslow -= 1
	if diving and divespeed > 0:
		if divedir == "right":
			position.x += divespeed
		else:
			position.x -= divespeed
		position.y -= divehop
		divespeed -= 5
		divehop -= 1
	if is_on_floor():
		$Gadget/Skeleton2D/spine.rotation = 0
	if is_on_ceiling():
		jumped = false
	if is_on_wall():
		controlActive = true
		longjumped = false
		crouchControl = false
	if lives == 0:
		get_tree().change_scene_to_file("res://losescreen.tscn")

func input():
	velocity.x = 0
	var right = Input.is_action_pressed("run_right")
	var left = Input.is_action_pressed("run_left")
	var jump = Input.is_action_just_pressed("jump")
	var crouch = Input.is_action_pressed("crouch")
	var dive = Input.is_action_just_pressed("dive")
	var left_floor = false
	if crouchControl == false:
		if right:
			velocity.x += move_speed
			$Gadget.scale.x = 1
			direction = "right"
		if left:
			velocity.x -= move_speed
			$Gadget.scale.x = -1
			direction = "left"
		if jump:
			if is_on_floor():
				jumpslow = jump_speed
				jumped = true
				longjumped = false
				$jumpsound.pitch_scale = 1
				$jumpsound.play()
			elif doublejump:
				doublejump = false
				jumpslow = jump_speed
				jumped = true
				diving = false
		if is_on_floor() and not doublejump:
			doublejump = true
		if is_on_floor() and velocity.x == 0:
			$Gadget/AnimationPlayer.play("idle")
		if is_on_floor() and velocity.x != 0:
			$Gadget/AnimationPlayer.play("run")
		if not is_on_floor() and $Gadget/AnimationPlayer.current_animation not in ["jump", "flipjump", "dive"]:
			$Gadget/AnimationPlayer.stop()
			if doublejump == true and $Gadget/AnimationPlayer.current_animation not in ["jump", "dive"]:
				$Gadget/AnimationPlayer	.play("jump")
		if doublejump == false and $Gadget/AnimationPlayer.current_animation != "flipjump" and diving == false:
			$Gadget/AnimationPlayer.stop()
			$Gadget/AnimationPlayer.play("flipjump")
			$jumpsound.pitch_scale = 1.2
			$jumpsound.play()
		if dive and dived == false and is_on_floor() == false:
			divespeed = 100
			divehop = 20
			dived = true
			diving = true
			if direction == "right":
				divedir = "right"
			else:
				divedir = "left"
			velocity.y = -1
			$Gadget/AnimationPlayer.play("dive")
			$divesound.play()
	else:
		if Input.is_action_just_pressed("run_right") and is_on_floor():
			doublejump = false
			controlActive = false
			$Gadget.scale.x = 1
			$Gadget/AnimationPlayer.play("flipjump")
			jumpslow = jump_speed*0.8
			moveslow = jump_speed
			jumped = true
			longjumped = true
			dived = false
			longjumpdir = "right"
			$jumpsound.pitch_scale = 0.8
			$jumpsound.play()
			await get_tree().create_timer(0.5).timeout
			crouchControl = false
			
		if Input.is_action_just_pressed("run_left") and is_on_floor():
			doublejump = false
			controlActive = false
			$Gadget.scale.x = -1
			$Gadget/AnimationPlayer.play("flipjump")
			jumpslow = jump_speed*0.8
			moveslow = jump_speed*1
			jumped = true
			longjumped = true
			longjumpdir = "left"
			$jumpsound.pitch_scale = 0.8
			$jumpsound.play()
			await get_tree().create_timer(0.5).timeout
			crouchControl = false
			
		if jump:
			doublejump = false
			$Gadget/AnimationPlayer.play("flipjump")
			jumpslow = jump_speed*1.3
			jumped = true
			longjumped = false
			$jumpsound.pitch_scale = 0.8
			$jumpsound.play()
			await get_tree().create_timer(0.5).timeout
			crouchControl = false

func _on_event_detect_area_entered(area: Area2D) -> void:
	if area.name == "coin":
		coins += 1
		score += 25
		updatevalues()
		$coinsound.play()
		area.emit_signal("collected")
	if area.name == "tiger" and goingdown:
		area.get_parent().emit_signal("defeated")
		$enemydefeat.play()
		score += 100
		hopamount = 65
		shorthop = true
		updatevalues()
	elif area.name == "tiger" and goingdown == false and invincible == false:
		hurt()
		updatevalues()
	if area.name == "sparkcrystal":
		get_tree().change_scene_to_file("res://winscreen.tscn")

func hurt():
	$hurtsound.play()
	lives -= 1
	invincible = true
	$AnimationPlayer.play("invincible_anim")
	await get_tree().create_timer(3).timeout
	$AnimationPlayer.play("RESET")
	invincible = false

func updatevalues():
	var updatelives = lives
	var updatescore = score
	var updatecoins = coins
	updatehud.emit(updatelives, updatescore, updatecoins)
