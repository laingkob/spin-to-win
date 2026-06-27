extends CharacterBody3D

# Player speed in m/s
@export var speed = 14

@export var spin_speed = 2
var max_rotation_speed = 6
var fall_acceleration = 10

@export var bounce_impulse = 16

@export var health_bar = 200

var temporary_invincibility = false
var lock_controls = false
var superpower_on = false
@onready var initial_transform = transform

var mass = 4

signal hit
signal died

var target_velocity = Vector3.ZERO
var rotation_speed = spin_speed

func _physics_process(delta):
	if not is_on_floor():
		velocity.y = velocity.y - (fall_acceleration * delta)
	
	if lock_controls:
		move_and_slide()
		return
	
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
	
	if not superpower_on and Input.is_action_pressed("spin"):
		superpower_on = true
		rotation_speed = max_rotation_speed
		transform = transform.scaled(Vector3(1.5,1.5,1.5))
		$SuperpowerTimer.start()
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	$AnimationPlayer.speed_scale = rotation_speed/2

	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() == null:
			continue
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if (rotation_speed && mob.rotation_speed):
				var damage_amount = rotation_speed - mob.rotation_speed
				if (damage_amount < 0):
					take_damage(-damage_amount)
					bounce_off(mob)
				else:
					mob.take_damage(damage_amount)
					mob.bounce_away(position)
	
	velocity = target_velocity
	move_and_slide()

func take_damage(damage_amount):
	if not temporary_invincibility:
		#print_debug("Player took %d damage" % damage_amount)
		health_bar -= damage_amount
		$Pivot/DamageBlinkTimer.start()
		$Pivot/BlinkIntervalTimer.start()
		temporary_invincibility = true
		hit.emit()
		if health_bar <= 0:
			die()

func bounce_off(mob):
	lock_controls = true
	$CollisionTimer.start()
	var nx = mob.velocity.y*velocity.z - mob.velocity.z*velocity.y
	var ny = mob.velocity.z*velocity.x - mob.velocity.x*velocity.z
	var nz = mob.velocity.x*velocity.y - mob.velocity.y*velocity.x
	var normal = Vector3(nx, ny, nz)
	velocity = normal * speed

func die():
	died.emit()
	queue_free()

func _on_mob_detector_body_entered(_body):
	take_damage(1)

func _on_damage_blink_timer_timeout() -> void:
	$Pivot/BlinkIntervalTimer.stop()
	temporary_invincibility = false
	$Pivot/beyblade.show()
	$Pivot/damaged_beyblade.hide()

func _on_blink_interval_timer_timeout() -> void:
	if $Pivot/beyblade.visible:
		$Pivot/beyblade.hide()
		$Pivot/damaged_beyblade.show()
	else :
		$Pivot/beyblade.show()
		$Pivot/damaged_beyblade.hide()


func _on_collision_timer_timeout() -> void:
	lock_controls = false


func _on_superpower_timer_timeout() -> void:
	var power_down = initial_transform
	power_down.origin = position
	transform = power_down
	superpower_on = false
	rotation_speed = spin_speed
