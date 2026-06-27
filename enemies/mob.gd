extends CharacterBody3D

@export var min_speed: int = 5
@export var max_speed: int = 11
@export var rotation_speed = 2
var fall_acceleration = 10

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
	if not is_on_floor():
		velocity.y = velocity.y - (fall_acceleration * _delta)
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		
		if collision.get_collider() == null:
			continue
		var other_mob = collision.get_collider()
		if collision.get_collider().is_in_group("mob"):
			bounce_away(other_mob.position)
			other_mob.bounce_away(position)
	move_and_slide()


func initialize(start_position: Vector3, target_position: Vector3):
	look_at_from_position(start_position, target_position, Vector3.UP)
	
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
		dead = true
		$AnimationPlayer.stop()
		$AnimationPlayer.play("death")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "death":
		squash()


func squash():
	squashed.emit()
	queue_free()


func bounce_away(from_position: Vector3):
	look_at(from_position)
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.BACK * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
