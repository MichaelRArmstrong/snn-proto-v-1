extends Control

class_name UIMain

var network: Network
var agent: Node
var selected_neuron: Neuron = null

@onready var sub_viewport = $MainLayout/CentreColumn/SubViewportContainer/SubViewport
@onready var network_visualiser = $MainLayout/CentreColumn/NetworkVisualiser
@onready var hierarchy_panel = $MainLayout/LeftPanel/HierarchyPanel
@onready var inspector_panel = $MainLayout/RightPanel/InspectorPanel

func _ready() -> void:
	#wait one frame for subviewport world scene to be fully initialised
	await get_tree().process_frame
	
	agent = sub_viewport.get_node("World/Agent")
	network = agent.snn
	
	network_visualiser.setup(network)
	hierarchy_panel.setup(network)
	inspector_panel.setup(network)
	
	#wire selection signal from hierarchy to inspector and visualiser
	hierarchy_panel.neuron_selected.connect(_on_neuron_selected)

func _on_neuron_selected(neuron: Neuron):
	selected_neuron = neuron
	inspector_panel.inspect_neuron(neuron)

func _process(delta: float) -> void:
	#live update visualiser and inspector
	if selected_neuron != null:
		inspector_panel.refresh()
	
