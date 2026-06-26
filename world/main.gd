extends Node3D

@export var mob_scene: PackedScene
@export var mob_limit : int = 3
var mob_count : int = 0 
var mob_killed : int = 0 
signal shake
# Called when the node enters the scene tree for the first time.
func _ready():
	$UserInterface/Retry.hide()
	$UserInterface/Victory.hide() 
	$Player.hit.connect($UserInterface/PlayerHealth._on_player_hit.bind())
	$Player.died.connect(_on_player_died.bind())
	shake.connect($CameraPivot/Camera3D._shake_camera.bind())
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_mob_spawn_timer_timeout():
	if(mob_count < mob_limit):
		var mob = mob_scene.instantiate()
		var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
		mob_spawn_location.progress_ratio = randf()
		
		var player_position = $Player.position
		mob.initialize(mob_spawn_location.position, player_position)
		
		add_child(mob)
		
		mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())
		mob.squashed.connect(_on_mob_gone.bind())
		#mob.left.connect(_on_mob_gone.bind())
		mob_count+=1
	else:
		$MobTimer.stop()
		
func _on_mob_gone():
	$SFX.play()
	shake.emit(2,1,300)
	mob_killed+=1
	if(mob_killed>=mob_limit):
		$MobTimer.stop()
		victory()
	

func _on_player_died():
	$MobTimer.stop()
	$UserInterface/Retry.show()
  
func victory():
	
	$UserInterface/Victory.show()
		 
func _unhandled_input(event):
	if (event.is_action_pressed("enter")) and ($UserInterface/Retry.visible or $UserInterface/Victory.visible):
		get_tree().reload_current_scene()
