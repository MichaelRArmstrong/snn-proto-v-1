extends CharacterBody2D
# Sensors inputs + Motors outputs

#network with all the neurons and synapses. TODO: add necessary helper functions for accessing and affecting both lists and individuals
var snn

#movement variables
@export var speed := 60.0
@export var turn_speed := 2.0
var angular_velocity := 0.0

#sensor variables
const SENSOR_ANGLE := deg_to_rad(30)
const SENSOR_RANGE := 120.0
const SENSOR_CURRENT := 0.4

signal food_eaten

func _ready() -> void:
	snn = Network.new()
	add_child(snn)

func _physics_process(delta: float) -> void:
	snn.lsensor_neuron.input_current = sense_food(true)
	snn.rsensor_neuron.input_current = sense_food(false)
	
	#network update loop
	snn.update(delta)
	
	if snn.lsensor_neuron.spiked:
		print("Left Spiked")
	
	if snn.rsensor_neuron.spiked:
		print("Right Spiked")
	
	
	var torque := 0.0
	if snn.lmotor_neuron.spiked:
		torque -= 1.0
	if snn.rmotor_neuron.spiked:
		torque += 1.0
	
	angular_velocity += torque * 3.0
	angular_velocity *= 0.9
	
	rotation += angular_velocity * delta
	
	#move forward
	var forward = Vector2.UP.rotated(rotation)
	velocity = forward * speed
	
	move_and_slide()
	
	return

func _draw() -> void:
	draw_line(Vector2.ZERO, Vector2.UP * 75, Color.GREEN, 2)
	
	var left_dir = Vector2.UP.rotated(-SENSOR_ANGLE)
	var right_dir = Vector2.UP.rotated(SENSOR_ANGLE)
	
	draw_line(Vector2.ZERO, left_dir * SENSOR_RANGE, Color.RED, 1)
	draw_line(Vector2.ZERO, right_dir * SENSOR_RANGE, Color.BLUE, 1)

func get_sensor_directions(is_left: bool) -> Vector2:
	var angle = -SENSOR_ANGLE if is_left else SENSOR_ANGLE
	return Vector2.UP.rotated(rotation + angle)

func sense_food(is_left: bool) -> float:
	var dir = get_sensor_directions(is_left)
	var foods = get_tree().get_nodes_in_group("food")
	
	var best_strength := 0.0
	
	for food in foods:
		var to_food = food.global_position - global_position
		var distance = to_food.length()
	
		if distance > SENSOR_RANGE:
			continue
	
		var alignment = dir.normalized().dot(to_food.normalized())
		if alignment <= 0.0:
			continue
	
		#strength is higher when food is close and aligned
		var strength = alignment * (1.0 - distance / SENSOR_RANGE)
		best_strength = max(best_strength, strength)
	
	return best_strength  

func _on_mouth_area_entered(area: Area2D):
	if area.is_in_group("food"):
		eat_food(area)

func eat_food(food):
	#emit reward signal
	food_eaten.emit(1.0)
	food.queue_free()
