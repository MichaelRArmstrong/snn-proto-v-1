extends HBoxContainer

class_name StatsBar

var network: Network = null

var avg_weight_label: Label
var spike_rate_label: Label
var last_reward_label: Label

var s_h
var h_h
var h_m

func setup(n: Network):
	network = n
	
	#avg weights
	avg_weight_label = Label.new()
	add_child(avg_weight_label)
	
	s_h = network.synapse_array.filter(func(s): return s.pre_syn_neuron.neuron_name == "L_Sensor" or s.pre_syn_neuron.neuron_name == "R_Sensor")
	h_m = network.synapse_array.filter(func(s): return s.post_syn_neuron.neuron_name == "L_Motor" or s.post_syn_neuron.neuron_name == "R_Motor")
	h_h = network.synapse_array.filter(func(s): 
		return s.pre_syn_neuron.neuron_name != "L_Sensor" and \
			s.pre_syn_neuron.neuron_name != "R_Sensor" and \
			s.post_syn_neuron.neuron_name != "L_Motor" and \
			s.post_syn_neuron.neuron_name != "R_Motor")
	
	#spike rate
	spike_rate_label = Label.new()
	add_child(spike_rate_label)
	
	#last reward
	last_reward_label = Label.new()
	add_child(last_reward_label)
	

func refresh():
	#weight averages
	var s_h_sum := 0.0
	for s in s_h:
		s_h_sum += s.weight
	var avg_s_h = s_h_sum / s_h.size()
	
	var h_h_sum := 0.0
	for s in h_h:
		h_h_sum += s.weight
	var avg_h_h = h_h_sum / h_h.size()
	
	var h_m_sum := 0.0
	for s in h_m:
		h_m_sum += s.weight
	var avg_h_m = h_m_sum / h_m.size()
	
	avg_weight_label.text = "Avg Weights: S-H: %.3f, H-H %.3f, H-M %.3f" % [avg_s_h,avg_h_h,avg_h_m]
	
	#spike rate
	spike_rate_label.text = "Spike Rate: %d" % network.spike_rate
	
	#last reward
	last_reward_label.text = "Last R: %.1f" % network.last_reward
