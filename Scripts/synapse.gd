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
var LEARNING_RATE:= 0.001

var agent

func _init(pre: Neuron, post: Neuron, w: float = 1.0) -> void:
	weight = w
	pre_syn_neuron = pre
	post_syn_neuron = post
	
	pre_syn_neuron.connect("spiked_signal", Callable(self, "_on_pre_spike")) #signals from neuron spikes
	post_syn_neuron.connect("spiked_signal", Callable( self, "_on_post_spike")) #very useful icl

func _on_pre_spike(neuron):
	eligibility -= post_syn_neuron.trace	
	post_syn_neuron.input_current += clamp(weight, 0.0, 1.0)

func _on_post_spike(neuron):
	#if pre_syn_neuron.neuron_name == "L_Sensor" or pre_syn_neuron.neuron_name == "R_Sensor":
	#	print("pre trace: %.4f" % pre_syn_neuron.trace)
	eligibility += pre_syn_neuron.trace

func update_weight(delta: float, reward: float) -> void:
	eligibility *= 0.95
	var dw = reward * eligibility * LEARNING_RATE * delta
	#print("dw: %.8f" % dw) 
	weight += dw
	weight = clamp(weight, 0.05, 0.4)
