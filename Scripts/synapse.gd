extends Node
# Weight + Plasticity
#1. Stores weights
#2. Knows who it connecs to, (pre- and post-synaptic neurons)
#3. Adjusts weights using STDP

var weight := 0.0
var pre_syn_neuron
var post_syn_neuron

func init(pre, post: Neuron, w = 0.0) -> void:
		weight = w
		pre_syn_neuron = pre
		post_syn_neuron = post

#update func probably for adjusting weights based on incoming values?
