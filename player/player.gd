extends CharacterBody3D

# Player speed in m/s
@export var speed = 10

@export var spin_speed = 2
var max_rotation_speed = 11
var fall_acceleration = 10

@export var bounce_impulse = 16

@export var health = 60

var temporary_invincibility = false
var superpower_on = false

var mass = 4

signal hit
signal died
signal used_power

var target_velocity = Vector3.ZERO
var rotation_speed = spin_speed

func _physics_process(delta):
	if not superpower_on and Input.is_action_pressed("spin"):
		superpower_on = true
		rotation_speed = max_rotation_speed
		transform = transform.scaled_local(Vector3(2,2,2))
		used_power.emit()
	
	if is_on_wall():
		bounce_away(get_wall_normal())
	if not is_on_floor():
		target_velocity.y = -1 * fall_acceleration * delta

	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
		
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
					bounce_away(mob.position)
				else:
					mob.take_damage(damage_amount)
					mob.bounce_away(position)
	
	velocity = target_velocity
	move_and_slide()

func take_damage(damage_amount):
	if not temporary_invincibility:
		#print_debug("Player took %d damage" % damage_amount)
		health -= damage_amount
		$Pivot/DamageBlinkTimer.start()
		$Pivot/BlinkIntervalTimer.start()
		temporary_invincibility = true
		hit.emit()
		if health <= 0:
			die()

func bounce_away(from_position: Vector3):
	look_at(from_position)
	velocity = Vector3.BACK * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)

func die():
	died.emit()
	queue_free()
#
#func _on_mob_detector_body_entered(_body):
	#take_damage(1)

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


func _on_superpower_timer_timeout() -> void:
	transform = transform.scaled_local(Vector3(0.5, 0.5, 0.5))
	superpower_on = false
	rotation_speed = spin_speed
