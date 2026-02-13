extends Node
# State + Spike logic

class_name Neuron

var v := 0.0 #membrane potential
var v_rest := 0.0 # resting potential
var v_thresh := 1.0 #threshold potential
var leak := 0.95 #decay over time (New Value =max (Current Value-S,T)))
var spiked := false

var incoming_v := 0.0 #needs to be set before step is called on each neuron

func step(delta: float, input_current = null) -> bool:
	#integrate
	if input_current == null:
		v += incoming_v
	else:
		v += input_current #Note: overwrites/ignores the incoming_v
	
	#leak
	v = max(v*leak,v_rest)
	
	#fire
	if v >= v_thresh:
		v =  0.0
		spiked = true
		return true
	
	spiked = false
	return false
	
