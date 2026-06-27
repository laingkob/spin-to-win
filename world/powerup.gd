extends ProgressBar

var max_fill = 10
var empty = 0
var is_filling = false

signal superpower_timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func drain():
	is_filling = false
	value -= 1
	$IntervalTimer.wait_time = 0.5
	$IntervalTimer.start()


func fill():
	if value < max_fill:
		value += 1
		$IntervalTimer.wait_time = 1.0
		$IntervalTimer.start()


func _on_drain_timer_timeout() -> void:
	if value > empty:
		if is_filling:
			fill()
		else:
			drain()
	if value == empty:
		superpower_timeout.emit()
		is_filling = true
		fill()
	if value == max_fill:
		$Label.show()
	else:
		$Label.hide()
