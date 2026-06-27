extends CharacterBody3D

@export var min_speed: int = 5
@export var max_speed: int = 11
@export var rotation_speed = 2

var damage_buffer_frames = 5
var invincible_frames = 0

@onready var health_bar = $HealthBar/SubViewport/ProgressBar

var is_rotating : bool = true
signal squashed
var dead = false
signal collide

func _physics_process(_delta):
	if is_on_wall():
		initialize(position, get_wall_normal())
		#rotate_y(randf_range(-PI/4, PI/4))
	move_and_slide()


func initialize(start_position: Vector3, player_position: Vector3):
	look_at_from_position(start_position, player_position, Vector3.UP)
	
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	$AnimationPlayer.play("spin")


func take_damage(damage_amount):
	if (invincible_frames > 0):
		invincible_frames -= 1
		return
	else :
		invincible_frames = damage_buffer_frames
	collide.emit()
	$HealthBar.visible = true
	#print_debug("Mob took %d damage" %damage_amount)
	health_bar.value -= damage_amount
	if health_bar.value <= 0 && dead == false:
		$AnimationPlayer.play("death")
		dead = true


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		squash()


func squash():
	squashed.emit()
	queue_free()


func bounce_away(position: Vector3):
	look_at(position)
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.BACK * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
