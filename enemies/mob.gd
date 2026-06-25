extends CharacterBody3D

@export var min_speed: int = 5

@export var max_speed: int = 11

@export var rotation_speed = 2

var max_health = 10
@export var health_bar = max_health

signal squashed
signal left 
func _physics_process(_delta):
	if is_on_wall():
		velocity = get_wall_normal()
		
	move_and_slide()
	
func initialize(start_position: Vector3, player_position: Vector3):
	look_at_from_position(start_position, player_position, Vector3.UP)
	rotate_y(randf_range(-PI/4, PI/4))
	
	var random_speed = randi_range(min_speed, max_speed)
	velocity = Vector3.FORWARD * random_speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	

func take_damage(damage_amount):
	$HealthBar.visible = true
	health_bar -= damage_amount
	$SubViewport/ProgressBar.value -= damage_amount
	if health_bar <= 0:
		squash()

func _on_visible_on_screen_notifier_3d_screen_exited():
	left.emit()
	queue_free()

func squash():
	squashed.emit()
	queue_free()
