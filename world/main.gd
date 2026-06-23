extends Node3D

@export var mob_scene: PackedScene
# Called when the node enters the scene tree for the first time.
func _ready():
	$UserInterface/Retry.hide()
	$Player.hit.connect($UserInterface/PlayerHealth._on_player_hit.bind())
	$Player.died.connect(_on_player_died.bind())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_mob_spawn_timer_timeout():
	var mob = mob_scene.instantiate()
	var mob_spawn_location = get_node("SpawnPath/SpawnLocation")
	mob_spawn_location.progress_ratio = randf()
	
	var player_position = $Player.position
	mob.initialize(mob_spawn_location.position, player_position)
	
	add_child(mob)
	
	mob.squashed.connect($UserInterface/ScoreLabel._on_mob_squashed.bind())


func _on_player_died():
	$MobTimer.stop()
	$UserInterface/Retry.show()

func _unhandled_input(event):
	if (event.is_action_pressed("ui_accept")) and $UserInterface/Retry.visible:
		get_tree().reload_current_scene()
