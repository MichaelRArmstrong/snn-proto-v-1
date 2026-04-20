extends VBoxContainer

class_name HierarchyPanel

signal neuron_selected(neuron: Neuron)

var network: Network

func setup(n: Network):
	network = n
	_build()

func _build():
	for child in get_children():
		child.queue_free()
	
	_add_group_label("Sensors")
	_add_neuron_button(network.lsensor_neuron)
	_add_neuron_button(network.rsensor_neuron)
	
	_add_group_label("Hidden - Left")
	for h in network.hidden_neurons.filter(func(n): return n.side == "left"):
		_add_neuron_button(h)
	
	_add_group_label("Hidden - Shared")
	for h in network.hidden_neurons.filter(func(n): return n.side == "shared"):
		_add_neuron_button(h)
	
	_add_group_label("Hidden - Right")
	for h in network.hidden_neurons.filter(func(n): return n.side == "right"):
		_add_neuron_button(h)
	
	_add_group_label("Motors")
	_add_neuron_button(network.lmotor_neuron)
	_add_neuron_button(network.rmotor_neuron)

func _add_group_label(text: String):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 10)
	add_child(label)

func _add_neuron_button(neuron: Neuron):
	var btn = Button.new()
	btn.text = "	" + neuron.neuron_name
	btn.alignment - HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(func(): neuron_selected.emit(neuron))
	add_child(btn)
