extends Control

class_name RewardPlot

var network: Network = null
var slider: HSlider = null

const LINE_COL := Color(0.7, 0.3, 0.1, 0.9)
const BG_COL := Color(0.05, 0.05, 0.05, 1.0)

func _process(_delta):
	queue_redraw()

func _draw():
	draw_rect(Rect2(Vector2.ZERO, size), BG_COL)
	
	if network == null or slider == null:
		return
	
	var history = network.reward_history
	var total = history.size()
	if total < 2:
		return
	
	var sample_count = int(slider.value)
	var start = max(0, total - sample_count)
	var slice = history.slice(start, total)
	var count = slice.size()
	if count < 2:
		return
	
	var w = size.x
	var h = size.y
	
	var range_val = network.reward_max - network.reward_min
	if range_val < 0.01:
		return
	
	var points: PackedVector2Array = []
	for i in range(count):
		var x = (float(i) / float(count - 1)) * w
		var normalised = (slice[i] - network.reward_min) / range_val
		var y = h - (normalised * h * 0.9) - (h * 0.05)
		points.append(Vector2(x, y))
	
	draw_polyline(points, LINE_COL, 1.5)
