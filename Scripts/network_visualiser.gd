extends Control

class_name NetworkVisualiser

var network: Network

#Layout consts
const LAYER_X = {
	"sensor": 60.0,
	"hidden": 270.0,
	"motor": 480.0
}
const NODE_RADIUS := 14.0
const SPIKE_FLASH_DURATION := 0.15

#Per-neuron display state
var neuron_positions := {}
var spike_timers := {}

signal neuron_clicked(neuron: Neuron)

func _ready():
	pass

func setup(n: Network):
	network = n
	_make_layout()

func _make_layout():
	if network == null:
		return
	neuron_positions.clear()
	
	var h = size.y
	
	#sensor neurons - vertically centred pair
	neuron_positions[network.lsensor_neuron] = Vector2(LAYER_X["sensor"], h * 0.35)
	neuron_positions[network.rsensor_neuron] = Vector2(LAYER_X["sensor"], h * 0.65)
	
	#hidden - evenly spaced vertically
	var count = network.hidden_neurons.size()
	for i in range(count):
		var y = h * 0.1 + (h * 0.8) * (float(i) / float(count - 1))
		neuron_positions[network.hidden_neurons[i]] = Vector2(LAYER_X["hidden"], y)
	
	#motor
	neuron_positions[network.lmotor_neuron] = Vector2(LAYER_X["motor"], h * 0.35)
	neuron_positions[network.rmotor_neuron] = Vector2(LAYER_X["motor"], h * 0.65)

func _process(delta: float) -> void:
	if network == null:
		return
		#tick flash timeers
		for neuron in neuron_positions.keys():
			if neuron.spiked:
				spike_timers[neuron] = SPIKE_FLASH_DURATION
			elif neuron in spike_timers:
				spike_timers[neuron] = max(0.0, spike_timers[neuron] - delta)
	queue_redraw()

func _draw():
	if network == null:
		return
	if neuron_positions.is_empty():
		_make_layout()
	
	_draw_synapses()
	_draw_neurons()

func _draw_neurons():
	for neuron in neuron_positions.keys():
		var pos = neuron_positions[neuron]
		var flash = spike_timers.get(neuron, 0.0) / SPIKE_FLASH_DURATION
		
		#set colours
		var base_col: Color
		if neuron == network.lsensor_neuron or neuron == network.rsensor_neuron:
			base_col = Color(0.2,0.8,0.4)	
		elif neuron == network.lmotor_neuron or neuron == network.rmotor_neuron:
			base_col = Color(0.9,0.5,0.1)	
		else:
			match neuron.side:
				"left":		base_col = Color(0.2,0.6,1.0)
				"right": 	base_col = Color(0.9,0.2,0.5)
				_:			base_col = Color(0.6,0.6,0.6)
		
		#membrane voltage fill
		var v_fill = clamp(neuron.v / neuron.v_thresh, 0.0, 1.0)
		var fill_col = base_col.darkened(0.6)
		fill_col.a = 0.4 + v_fill * 0.4
		
		#spike flash
		if flash > 0.0:
			draw_circle(pos, NODE_RADIUS + 8.0 * flash, Color(base_col.r, base_col.g, base_col.b, flash * 0.5))
		
		draw_circle(pos, NODE_RADIUS, fill_col)
		draw_arc(pos, NODE_RADIUS, 0, TAU, 32, base_col, 1.5)
		
		#voltage overlay
		if v_fill > 0.0:
			draw_arc(pos, NODE_RADIUS, -PI/2, -PI/2 + TAU * v_fill, 32, base_col, 2.5)
		

func _draw_synapses():
	for s in network.synapse_array:
		var from = neuron_positions.get(s.pre_syn_neuron, Vector2.ZERO)
		var to = neuron_positions.get(s.post_syn_neuron, Vector2.ZERO)
		if from == Vector2.ZERO or to == Vector2.ZERO:
			continue
		#weights are 0->1 = dark orange to bright orange
		var t = clamp(s.weight, 0.0, 1.0)
		var col = Color(0.6 + t * 0.4, 0.35 + t * 0.3, 0.0, 0.15 + t * 0.55)
		draw_line(from, to, col, 5.0)
		
