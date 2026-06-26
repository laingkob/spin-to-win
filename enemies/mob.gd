extends CharacterBody3D

@export var min_speed: int = 5

@export var max_speed: int = 11

@export var rotation_speed = 2
var is_rotating : bool = true
signal squashed
signal left 

func _physics_process(_delta):
	if is_on_wall():
		initialize(position,get_wall_normal())
	if is_rotating:
		rotate_y(randf_range(-PI/4, PI/4))
	move_and_slide()
	
func initialize(start_position: Vector3, player_position: Vector3):
	look_at_from_position(start_position, player_position, Vector3.UP)
	
	
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	

func take_damage(damage_amount):
	$HealthBar.visible = true
	$SubViewport/ProgressBar.value -= damage_amount
	if $SubViewport/ProgressBar.value <= 0:
		squash()

func _on_visible_on_screen_notifier_3d_screen_exited():
	left.emit()
	queue_free()

func squash():
	squashed.emit()
	queue_free()
