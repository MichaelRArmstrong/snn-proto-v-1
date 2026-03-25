extends Node

class_name Synapse
# Weight + Plasticity
#1. Stores weights
#2. Knows who it connecs to, (pre- and post-synaptic neurons)
#3. Adjusts weights using STDP

var weight := 0.1
var eligibility := 0.0
var pre_syn_neuron
var post_syn_neuron

var agent

func _init(pre: Neuron, post: Neuron, w: float = 1.0) -> void:
	weight = randf_range(0.05, 0.2)
	pre_syn_neuron = pre
	post_syn_neuron = post
	
	pre_syn_neuron.connect("spiked_signal", Callable(self, "_on_pre_spike")) #signals from neuron spikes
	post_syn_neuron.connect("spiked_signal", Callable( self, "_on_post_spike")) #very useful icl

func _ready():
	agent = get_parent().get_parent()
	agent.connect("food_eaten", Callable(self, "_on_food_eaten"))

func _on_pre_spike(neuron):
	var dt = post_syn_neuron.last_spike_time - neuron.last_spike_time
	if post_syn_neuron.last_spike_time > 0:
		update_eligibility(dt)
	
	post_syn_neuron.input_current += weight

func _on_post_spike(neuron):
	var dt = neuron.last_spike_time - pre_syn_neuron.last_spike_time
	if pre_syn_neuron.last_spike_time > 0:
		update_eligibility(dt)

func update_eligibility(delta_time: float): #eligibility meaning how much the reward will affect the weight of the synapse once recievedd
	#20ms STDP window
	var tau = 0.02 
	#always between 0 and 1
	var magnitude = exp(-abs(delta_time) / tau) 
	
	if delta_time > 0:
		eligibility += magnitude   # < potentiation
	else:
		eligibility -= magnitude  # < depression
	
	#eligibility decay
	eligibility *= 0.95

func _on_food_eaten(reward: float):
	weight += reward * eligibility
	weight = clamp(weight, 0.0, 0.5)#NOTE needs adjusting probably
	return
