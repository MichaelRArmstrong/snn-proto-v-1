extends Control

class_name RewardHistory

var network: Network = null

const LINE_COL := Color(0.7,0.3,0.1,0.9)
const BG_COL := Color(0.05, 0.05, 0.05, 1.0)

func setup(n: Network):
	network = n

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if network == null:
		return
	var count = network.reward_history.size()
	if count < 2:
		return
	draw_rect(Rect2(Vector2.ZERO, size), BG_COL)
	
	
	var w = size.x
	var h = size.y
		
	#setup polyline points
	var points: PackedVector2Array = []
	for i in range(count):
		var x = (float(i) / float(count - 1)) * w
		var range = network.reward_max - network.reward_min
		if range < 0.01:
			return
		var normalised = (network.reward_history[i] - network.reward_min) / range
		var y = h - (normalised * h * 0.9) - (h * 0.05)
		points.append(Vector2(x, y))
	
	draw_polyline(points, LINE_COL, 1.5)
	
