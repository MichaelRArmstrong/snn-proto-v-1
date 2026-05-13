extends HBoxContainer

class_name WeightDivergenceTracker

var network: Network = null

var LeftMotorWeightsLabel : Label
var RightMotorWeightsLabel : Label
var LeftStr : String
var RightStr : String

func setup(n: Network):
	network = n
	LeftMotorWeightsLabel = Label.new()
	add_child(LeftMotorWeightsLabel)
	RightMotorWeightsLabel = Label.new()
	add_child(RightMotorWeightsLabel)

func refresh():
	LeftStr = network.left_syn_weight_divergence_string
	RightStr = network.right_syn_weight_divergence_string
	
	LeftMotorWeightsLabel.text = LeftStr
	RightMotorWeightsLabel.text = RightStr
	
