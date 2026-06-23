extends CharacterBody3D

# Player speed in m/s
@export var speed = 14

@export var spin_speed = 2

# Downward acceleration when in the air
@export var fall_acceleration = 75

@export var jump_impulse = 20

@export var bounce_impulse = 16

@export var health_bar = 200

var mass = 4

signal hit
signal died

var target_velocity = Vector3.ZERO
var rotation_speed = 0

func _physics_process(delta):
	var direction = Vector3.ZERO
	
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_forward"):
		direction.z += 1
	if Input.is_action_pressed("move_back"):
		direction.z -= 1
	
	if Input.is_action_pressed("spin"):
		rotation_speed += spin_speed
	
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		$Pivot.basis = Basis.looking_at(direction)
	
	target_velocity.x = direction.x * speed
	target_velocity.z = direction.z * speed
	
	if rotation_speed != 0:
		var rotation_amount = 0.1 * rotation_speed
		$Pivot/Sprite.rotate(Vector3(0, 1, 0), rotation_amount)
		rotation_speed -= 1
		
	if not is_on_floor():
		target_velocity.y = target_velocity.y - (fall_acceleration * delta)
	if is_on_floor() and Input.is_action_just_pressed("jump"):
		target_velocity.y = jump_impulse
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if collision.get_collider() == null:
			continue
		if collision.get_collider().is_in_group("mob"):
			var mob = collision.get_collider()
			if (mob.rotation_speed > rotation_speed):
				take_damage(mob.rotation_speed)
			else:
				mob.take_damage(rotation_speed)
			##Check that we are on top of it
			#if Vector3.UP.dot(collision.get_normal()) > 0.1:
				#mob.squash()
				#target_velocity.y = bounce_impulse
				#break

	velocity = target_velocity
	move_and_slide()

func take_damage(damage_amount):
	print_debug("Player took %d damage" % damage_amount)
	health_bar -= damage_amount 
	hit.emit()
	if health_bar <= 0:
		die()

func bounce_off(mob):
	var nx = mob.velocity.y*velocity.z - mob.velocity.z*velocity.y
	var ny = mob.velocity.z*velocity.x - mob.velocity.x*velocity.z
	var nz = mob.velocity.x*velocity.y - mob.velocity.y*velocity.x
	var normal = Vector3(nx, ny, nz)
	velocity = normal
	# TODO need to double check how to re scale this vector if necessary

func die():
	died.emit()
	queue_free()

func _on_mob_detector_body_entered(_body):
	take_damage(1)
