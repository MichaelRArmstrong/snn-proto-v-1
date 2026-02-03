class_name LIFNeuron

var voltage := 0.0
var threshold := 1.0
var leak := 0.95
var spiked := false

func step(input_current: float) -> bool:
	#integrate
	voltage += input_current
	
	#leak
	voltage *= leak
	
	#fire
	if voltage >= threshold:
		spiked = true
		voltage = 0.0
		return true
	
	spiked = false
	return false
