extends Node
# State + Spike logic

class_name Neuron

var v := 0.0 #membrane potential
var v_rest := 0.0 # resting potential
var v_thresh := 1.0 #threshold potential
var leak_rate := 0.2 #decay over time 
var spiked := false
var last_spike_time := 0.0

var input_current := 0.0 #for sensor neurons this will be set by the sensors, teh rest will recieve this from their synapses, probably

signal spiked_signal

func step(delta: float, current_time: float) -> bool:
	#integrate
	v += input_current
	input_current = 0.0 
	
	#leak
	v -= v * leak_rate * delta
	
	#fire
	if v >= v_thresh:
		v =  0.0
		spiked = true
		last_spike_time = current_time
		emit_signal("spiked_signal", self)
		return true
	
	spiked = false
	return false
	
