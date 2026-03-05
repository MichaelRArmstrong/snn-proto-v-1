extends Window

var network: Network #will be set in agent.gd
var update_timer := 0.0
const UPDATE_RATE := 0.1 #10hz
var all_neurons := []
#Node refs
@onready var neuron_list = $VBoxContainer/HSplitContainer/LeftPanel_Neurons/NeuronList
@onready var inspector = $VBoxContainer/HSplitContainer/Inspector

var selected_neuron = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	title = "SNN Debugger"
	size = Vector2i(600,600)
	position = Vector2i(20, 20)
	
	#Make the VBoxContainer fill the whole window
	$VBoxContainer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	#Make the HSplitContainer expand vertically to fill
	$VBoxContainer/HSplitContainer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	#Give each panel a minimum width
	$VBoxContainer/HSplitContainer/LeftPanel_Neurons.custom_minimum_size = Vector2(200, 0)
	$VBoxContainer/HSplitContainer/MiddlePanel_Synapses.custom_minimum_size = Vector2(200, 0)
	$VBoxContainer/HSplitContainer/Inspector.custom_minimum_size = Vector2(250, 0)
	
	all_neurons = [network.lsensor_neuron, network.rsensor_neuron]
	all_neurons.append_array(network.hidden_neurons) 
	all_neurons.append(network.lmotor_neuron)
	all_neurons.append(network.rmotor_neuron)


func set_network(n: Network):
	network = n

func _on_neuron_selected(neuron: Neuron):
	selected_neuron = neuron
	refresh_inspector()

func refresh_inspector():
	if selected_neuron == null:
		return
	inspector.clear()
	inspector.append_text("[b]%s[/b]\n" % selected_neuron.neuron_name)
	inspector.append_text("V: %.4f\n" % selected_neuron.v)
	inspector.append_text("Threshold: %.2f\n" % selected_neuron.v_thresh)
	inspector.append_text("Leak Rate: %.2f\n" % selected_neuron.leak_rate)
	inspector.append_text("Spiked: %s\n" % selected_neuron.spiked)
	inspector.append_text("Last spike: %.3f\n" % selected_neuron.last_spike_time)
	inspector.append_text("Input current: %.4f\n" % selected_neuron.input_current)

func _process(delta):
	if network == null:
		return
	update_timer += delta
	if update_timer >= UPDATE_RATE:
		update_timer = 0.0
		refresh_neuron_list()
		refresh_inspector()

func refresh_neuron_list():
	#clear and rebuild the list
	for child in neuron_list.get_children():
		child.queue_free()
	
	#rebuild list
	 
	for neuron in all_neurons:
		var new_button = Button.new()
		new_button.text = neuron.neuron_name + " - V: " + "%.2f" % neuron.v
		new_button.pressed.connect(_on_neuron_selected.bind(neuron))
		neuron_list.add_child(new_button)
