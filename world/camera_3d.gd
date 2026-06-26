extends Camera3D

@export var noise : NoiseTexture2D
var shake_time : float = 5.0
var strength : float = 0.0
var speed : float = 0.0
var noise_y : float = 0.0
var noise_x : float = 0.0

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if shake_time>0:
		shake_time-=delta
		var shake_offset = get_noise_offset(delta)
		self.h_offset = shake_offset.x
		self.v_offset = shake_offset.y
	else:
		self.h_offset = 0
		self.v_offset = 0
func get_noise_offset(delta: float)-> Vector2:
	noise_y = delta*speed
	var _offset : Vector2 = Vector2.ZERO 
	if noise.noise:
		var _noise : FastNoiseLite = noise.noise
		_offset.x = _noise.get_noise_2d(noise_x,noise_y)*strength
		_offset.y = _noise.get_noise_2d(noise_x*randf_range(58,100),noise_y)*strength
		
	return _offset	
		
		
		
		
		
func _shake_amounts(amount:float,duration:float,_speed:float):
	strength = amount
	shake_time =duration
	speed=_speed
		
func _shake_camera(amount:float,duration:float,_speed:float):	
	_shake_amounts(amount,duration,_speed)	
	print("heard")
		
		
