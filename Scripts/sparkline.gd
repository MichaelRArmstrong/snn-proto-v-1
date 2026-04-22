extends Control

class_name Sparkline

var neuron: Neuron = null

const LINE_COL := Color(0.2,0.9,0.4,0.9)
const SPIKE_COL := Color(1.0,1.0,0.4,0.7)
const BG_COL := Color(0.05, 0.05, 0.05, 1.0)

func watch(n: Neuron):
	neuron = n

func _process(delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), BG_COL)
	
	if neuron == null or neuron.v_history.size() < 2:
		return
	
	var w = size.x
	var h = size.y
	var count = neuron.v_history.size()
	
	#draw threshold line
	var thresh_y = h * 0.1
	draw_line(Vector2(0, thresh_y), Vector2(2, thresh_y), Color(0.5,0.0,0.0,0.5), 1.0)
	
	#setup polyline points
	var points: PackedVector2Array = []
	for i in range(count):
		var x = (float(i) / float(count - 1)) * w
		var v_norm = clamp(neuron.v_history[i] / neuron.v_thresh, 0.0, 1.0)
		var y = h - (v_norm * h * 0.9) - (h * 0.05)
		points.append(Vector2(x, y))
	
	draw_polyline(points, LINE_COL, 1.5)
	
	#draw spikes as vertical lines
	for i in range(count):
		if i > 0 and neuron.v_history[i] == 0.0 and neuron.v_history[i-1] > 0.1:
			var x = (float(i) / float(count - 1)) * w
			draw_line(Vector2(x, 0), Vector2(x, h), SPIKE_COL, 1.0)
	
