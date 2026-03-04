extends Node
# Update order

class_name Network

var global_time := 0.0

#Sensor neurons: 4, 
#> food on left/right - 2
#> obstacle proximity - 1
#> hazard proximity - 1
var lsensor_neuron := Neuron.new()
var rsensor_neuron := Neuron.new()
#ADD REST LATER

#Hidden neurons - 16
#~4 connections per neuron between hidden and hidden, each sensor neuron should connect to a ~2 hidden neurons.
var hidden_neurons := []
var HIDDEN_COUNT := 16


#motor neurons - 2 
#accumulate spikes and produce continuous motor signals.
var lmotor_neuron := Neuron.new()
var rmotor_neuron := Neuron.new()

#synapses
var synapse_array := []

func _init() -> void:
	#assigning names
	lsensor_neuron.neuron_name = "L_Sensor"
	rsensor_neuron.neuron_name = "R_Sensor"
	lmotor_neuron.neuron_name = "L_Motor"
	rmotor_neuron.neuron_name = "R_Motor"
	
	for i in range(HIDDEN_COUNT):
		var h = Neuron.new()
		if i < 10:
			h.neuron_name = "Hidden_%02d" % i
		else:
			h.neuron_name = "Hidden_%s" % i
		hidden_neurons.append(h)

	
	global_time = 0.0
# In the networks constructor (here) i need it to:
# > setup sensor to hidden synapse connections
# > setup synapse connections from hidden to hidden
# > setup synapse connections from hidden to motor
	
	#sensor to hidden
	var s_to_h := []
	for i in 4: #Left sensor
		var h = hidden_neurons.pick_random()
		while h in s_to_h:
			h = hidden_neurons.pick_random() #should work ¯\_ツ)_/¯
	
		var s = Synapse.new(lsensor_neuron, h)
		add_child(s)
		synapse_array.append(s)
		s_to_h.append(h)
	s_to_h.clear()
	for i in 4: #Right sensor
		var h = hidden_neurons.pick_random()
		while h in s_to_h:
			h = hidden_neurons.pick_random() 
	
		var s = Synapse.new(rsensor_neuron, h)
		add_child(s)
		synapse_array.append(s)
		s_to_h.append(h)
	
	#hidden to hidden
	for h in hidden_neurons: #for each hidden neuron
		var h_to_h := []
		for i in randi_range(4,6): #between 4 and 6 times
			var h2 = hidden_neurons.pick_random()
			while  h2 == h or h2 in h_to_h:
				h2 = hidden_neurons.pick_random() #pick a random neuron besides self and not already connected
			
			var s = Synapse.new(h, h2)
			add_child(s)
			synapse_array.append(s)
			h_to_h.append(h2)
	
	#hidden to motor
	var h_to_m := []
	#for now all hidden to both motors with random weights
	for h in hidden_neurons:
		var lms = Synapse.new(h, lmotor_neuron)
		add_child(lms)
		synapse_array.append(lms)
		var rms = Synapse.new(h, rmotor_neuron)
		add_child(rms)
		synapse_array.append(rms)
	
	return

func update(delta: float) -> void: #update funciton, could handle STDP/synaptic weight changes here idk 
	global_time += delta
	
	#sensor step
	lsensor_neuron.step(delta, global_time)
	rsensor_neuron.step(delta, global_time)
	
	#hidden step
	for hidden in hidden_neurons:
		hidden.step(delta, global_time)
	#synapse updates should occur naturally on neuron spikes
	
	#motor step
	lmotor_neuron.step(delta, global_time)
	rmotor_neuron.step(delta, global_time)
	
	
	
	
	
	return
