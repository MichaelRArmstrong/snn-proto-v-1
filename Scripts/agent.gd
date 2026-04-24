extends CharacterBody2D
# Sensors inputs + Motors outputs

#network with all the neurons and synapses. 
var snn

#reference for the environment node
var env

@export_category("Movement Variables")
@export var speed := 20.0
@export var turn_speed := 2.0
@export var time_scale := 1.0
var angular_velocity := 0.0

@export_category("Sensor Variables")
const SENSOR_ANGLE := deg_to_rad(60)
const FWD_SENSOR_ANGLE := deg_to_rad(15)
@export var sensor_range := 10.0
@export var sensor_baseline := 0.3
@export var sensor_gain := 0.05

func _ready() -> void:
	env = get_tree().get_first_node_in_group("environment")
	
	Engine.time_scale = time_scale
	snn = Network.new()
	add_child(snn)
	

func _physics_process(delta: float) -> void:
	var left = sense_food(true)
	var right = sense_food(false)
	
	var total = max(left + right, 0.001)
	var diff = left - right
	var normalised_diff = diff / total
	
	snn.lsensor_neuron.input_current = sensor_baseline + normalised_diff * sensor_gain
	snn.rsensor_neuron.input_current =  sensor_baseline - normalised_diff * sensor_gain
	
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
	var left_fwd_dir = Vector2.UP.rotated(-FWD_SENSOR_ANGLE)
	var right_dir = Vector2.UP.rotated(SENSOR_ANGLE)
	var right_fwd_dir = Vector2.UP.rotated(FWD_SENSOR_ANGLE)
	
	draw_line(Vector2.ZERO, left_dir * sensor_range, Color.RED, 1)
	draw_line(Vector2.ZERO, left_fwd_dir * sensor_range * 1.5, Color.ORANGE, 1)
	draw_line(Vector2.ZERO, right_dir * sensor_range, Color.BLUE, 1)
	draw_line(Vector2.ZERO, right_fwd_dir * sensor_range * 1.5, Color.CYAN, 1)

func get_sensor_directions(is_left: bool, is_fwd: bool = false) -> Vector2:
	if is_fwd:
		var fwd_angle = -FWD_SENSOR_ANGLE if is_left else FWD_SENSOR_ANGLE
		return Vector2.UP.rotated(rotation + fwd_angle)
	else:
		var angle = -SENSOR_ANGLE if is_left else SENSOR_ANGLE
		return Vector2.UP.rotated(rotation + angle)


func sense_food(is_left: bool) -> float:
	 #look for higher density of food in sensor cone
	var dir = get_sensor_directions(is_left)
	var fwd_dir = get_sensor_directions(is_left, true)
	
	#sample a point in the sensor direction at the distance of the sensor range
	var sample_point1 = global_position + (dir.normalized() * (sensor_range * 0.5))
	var sample_point2 = global_position + (dir.normalized() * sensor_range)
	var sample_point3 = global_position + (dir.normalized() * (sensor_range * 1.5))
	
	var fwd_sample1 = global_position + (fwd_dir.normalized() * sensor_range * 0.75)
	var fwd_sample2 = global_position + (fwd_dir.normalized() * sensor_range * 1.5)
	var fwd_sample3 = global_position + (fwd_dir.normalized() * sensor_range * 2.25)
	
	var n1 = env.get_nutrition_at(sample_point1)
	var n2 = env.get_nutrition_at(sample_point2)
	var n3 = env.get_nutrition_at(sample_point3)
	
	var fwd_n1 = env.get_nutrition_at(fwd_sample1)
	var fwd_n2 = env.get_nutrition_at(fwd_sample2)
	var fwd_n3 = env.get_nutrition_at(fwd_sample3)
	
	var avg = (n1 + n2 + n3) / 3
	var fwd_avg = ((fwd_n1*0.6) + (fwd_n2*0.8) + fwd_n3) / 3
	
	
	return (avg + fwd_avg) / 2
