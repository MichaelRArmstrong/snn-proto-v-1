extends Node
# Update order

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
	for i in range(HIDDEN_COUNT):
		hidden_neurons.append(Neuron.new())
	
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
	
		synapse_array.append(Synapse.new(lsensor_neuron, h))
		s_to_h.append(h)
	s_to_h.clear()
	for i in 4: #Right sensor
		var h = hidden_neurons.pick_random()
		while h in s_to_h:
			h = hidden_neurons.pick_random() 
	
		synapse_array.append(Synapse.new(rsensor_neuron, h))
		s_to_h.append(h)
	
	#hidden to hidden
	for h in hidden_neurons: #for each hidden neuron
		var h_to_h := []
		for i in randi_range(4,6): #between 4 and 6 times
			var h2 = hidden_neurons.pick_random()
			while  h2 == h or h2 in h_to_h:
				h2 = hidden_neurons.pick_random() #pick a random neuron besides self and not already connected
			
			synapse_array.append(Synapse.new(h,h2))
			h_to_h.append(h2)
	
	#hidden to motor
	var h_to_m := []
	#for now all hidden to both motors with random weights
	for h in hidden_neurons:
		synapse_array.append(Synapse.new(h, lmotor_neuron, randf_range(0.0,1.0)))
		synapse_array.append(Synapse.new(h, rmotor_neuron, randf_range(0.0,1.0)))
	
	return

func update() -> void: #update funciton, could handle STDP/synaptic weight changes here idk 
	return
