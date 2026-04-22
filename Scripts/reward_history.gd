extends VBoxContainer

class_name RewardHistory

var network: Network = null
var plot: RewardPlot
var slider: HSlider

func setup(n: Network):
	network = n
	
	plot = RewardPlot.new()
	plot.size_flags_vertical = Control.SIZE_EXPAND_FILL
	add_child(plot)
	
	slider = HSlider.new()
	slider.custom_minimum_size = Vector2(0, 20)
	slider.min_value = 2
	slider.max_value = 1000
	slider.value = 1000
	add_child(slider)
	
	plot.network = network
	plot.slider = slider

func _process(_delta):
	slider.max_value = max(1000, network.reward_history.size())
	if slider.value > network.reward_history.size() * 0.99:
		slider.value = network.reward_history.size()
