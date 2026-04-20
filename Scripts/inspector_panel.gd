extends VBoxContainer

class_name InspectorPanel

var network: Network
var current_neuron: Neuron = null
var current_synapse: Synapse = null

var title_label: Label
var stats_label: RichTextLabel
var synapse_list: VBoxContainer

func setup(n: Network):
	network = n
	
	title_label = Label.new()
	title_label.add_theme_font_size_override("font_size", 10.0)
	add_child(title_label)
	
	stats_label = RichTextLabel.new()
	stats_label.bbcode_enabled = true
	stats_label.custom_minimum_size = Vector2(0, 160)
	stats_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(stats_label)
	
	var sep = HSeparator.new()
	add_child(sep)
	
	var syn_header = Label.new()
	syn_header.text = "SYNAPSES"
	syn_header.add_theme_font_size_override("font_size", 10.0)
	add_child(syn_header)
	
	var scroll = ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(scroll)
	
	synapse_list = VBoxContainer.new()
	synapse_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.add_child(synapse_list)

func inspect_neuron(neuron: Neuron):
	current_neuron = neuron
	current_synapse = null
	title_label.text = neuron.neuron_name
	_rebuild_synapse_list()
	refresh()

func _rebuild_synapse_list():
	for child in synapse_list.get_children():
		child.queue_free()
	
	if current_neuron == null:
		return
	
	var outgoing = network.synapse_array.filter(func(s): return s.pre_syn_neuron == current_neuron)
	var incoming = network.synapse_array.filter(func(s): return s.post_syn_neuron == current_neuron)
	
	_add_synapse_group_label("OUT (%d)" % outgoing.size())
	for s in outgoing:
		_add_synapse_button(s)
	
	_add_synapse_group_label("IN (%d)" % incoming.size())
	for s in incoming:
		_add_synapse_button(s)

func _add_synapse_group_label(text: String):
	var l = Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", 10.0)
	synapse_list.add_child(l)

func _add_synapse_button(s: Synapse):
	var btn = Button.new()
	btn.alignment = HORIZONTAL_ALIGNMENT_LEFT
	btn.pressed.connect(func(): _inspect_synapse(s))
	synapse_list.add_child(btn)
	#store ref on button so can update live
	btn.set_meta("synapse", s)

func _inspect_synapse(s: Synapse):
	current_synapse = s
	refresh()

func refresh():
	if current_neuron == null:
		return
	
	if current_synapse != null:
		stats_label.clear()
		stats_label.append_text("[b]%s -> %s[/b]\n" % [current_synapse.pre_syn_neuron.neuron_name, current_synapse.pre_syn_neuron.neuron_name])
		stats_label.append_text("Weight:		%.4f\n" % current_synapse.weight)
		stats_label.append_text("Eligibility:	%.4f\n" % current_synapse.eligibility)
	else:
		stats_label.clear()
		stats_label.append_text("[b]%s[/b]\n" % current_neuron.neuron_name)
		stats_label.append_text("V:				%.4f\n" % current_neuron.v)
		stats_label.append_text("Threshold:		%.2f\n" % current_neuron.v_thresh)
		stats_label.append_text("Leak rate:		%.2f\n" % current_neuron.leak_rate)
		stats_label.append_text("Spiked:		%s\n" % current_neuron.spiked)
		stats_label.append_text("Last spike:	%.3f\n" % current_neuron.last_spike_time)
		stats_label.append_text("Input curr:	%.4f\n" % current_neuron.input_current)
	
	#update synapse buttons live
	for btn in synapse_list.get_children():
		if btn is Button and btn.has_meta("synapse"):
			var s: Synapse = btn.get_meta("synapse")
			btn.text = "	%s -> %s	 w: %.3f" % [s.pre_syn_neuron.neuron_name, s.post_syn_neuron.neuron_name, s.weight]
