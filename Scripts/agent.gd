extends CharacterBody2D
# Sensors inputs + Motors outputs

#network with all the neurons and synapses. 
var snn

#reference for the environment node
var env

@export_category("Movement Variables")
@export var speed := 20.0
@export var turn_speed := 2.0
var angular_velocity := 0.0
@export var time_scale := 1.0

@export_category("Sensor Variables")
const SENSOR_ANGLE := deg_to_rad(60)
@export var SENSOR_RANGE := 10.0
const SENSOR_CURRENT := 0.2
@export var FOOD_SENSITIVITY := 1.0


func _ready() -> void:
	env = get_tree().get_first_node_in_group("environment")
	
	Engine.time_scale = time_scale
	snn = Network.new()
	add_child(snn)
	

func _physics_process(delta: float) -> void:
	snn.lsensor_neuron.input_current = sense_food(true)
	snn.rsensor_neuron.input_current = sense_food(false)
	
	#network update loop + stdp reward
	var reward = env.get_nutrition_at(global_position)
	snn.update(delta, reward)
	
	#if snn.lsensor_neuron.spiked:
		#print("Left Spiked")
	
	#if snn.rsensor_neuron.spiked:
		#print("Right Spiked")
	
	
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
	
	#boundary logic
	var dist = global_position.distance_to(env.dish_center)
	if dist > env.dish_radius:
		var inward = (env.dish_center - global_position).normalized()
		#pos correction
		global_position = env.dish_center - inward * (env.dish_radius - 5.0)
		#rot correction
		var reflected = forward.reflect(inward)
		rotation = reflected.angle() - PI/2
		angular_velocity = 0.0
	
	
	return

func _draw() -> void:
	#draw_line(Vector2.ZERO, Vector2.UP * 75, Color.GREEN, 2)
	
	var left_dir = Vector2.UP.rotated(-SENSOR_ANGLE)
	var right_dir = Vector2.UP.rotated(SENSOR_ANGLE)
	
	draw_line(Vector2.ZERO, left_dir * SENSOR_RANGE, Color.RED, 1)
	draw_line(Vector2.ZERO, right_dir * SENSOR_RANGE, Color.BLUE, 1)

func get_sensor_directions(is_left: bool) -> Vector2:
	var angle = -SENSOR_ANGLE if is_left else SENSOR_ANGLE
	return Vector2.UP.rotated(rotation + angle)

func sense_food(is_left: bool) -> float:
	 #look for higher density of food in sensor cone
	var dir = get_sensor_directions(is_left)
	
	#TODO: Make it checkk if its sensing sample points that are outside the dish boundss, if so, it needs to turn back, s
	
	#sample a point in the sensor direction at the distance of the sensor range
	var sample_point1 = global_position + (dir.normalized() * (SENSOR_RANGE * 0.5))
	var sample_point2 = global_position + (dir.normalized() * SENSOR_RANGE)
	var sample_point3 = global_position + (dir.normalized() * (SENSOR_RANGE * 1.5))
	
	var n1 = env.get_nutrition_at(sample_point1) * FOOD_SENSITIVITY
	var n2 = env.get_nutrition_at(sample_point2) * FOOD_SENSITIVITY
	var n3 = env.get_nutrition_at(sample_point3) * FOOD_SENSITIVITY
	
	var avg = (n1 + n2 + n3) / 3
	
	return avg
