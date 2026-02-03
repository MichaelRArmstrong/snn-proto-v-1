extends CharacterBody2D

#neurons
var left_motor := LIFNeuron.new()
var right_motor := LIFNeuron.new()
var hunger_neuron := LIFNeuron.new()
var hidden_neurons := []
var HIDDEN_COUNT := 6

var left_inhibition := 0.0
var right_inhibition := 0.0

@export var speed := 60.0
@export var turn_speed := 2.0
@export var hunger := 0.2

var angular_velocity := 0.0

const HUNGER_RATE := 0.01
const FOOD_REWARD := 0.5
const SENSOR_ANGLE := deg_to_rad(30)
const SENSOR_RANGE := 120.0
const SENSOR_CURRENT := 0.4

const STRONG_INPUT := 0.5
const WEAK_INPUT := 0.2

var foods := []

const RATE_WINDOW := 1.0 #seconds

var left_spike_times: Array[float] = []
var right_spike_times: Array[float] = []

func _ready():
    left_motor.threshold = 1.0
    right_motor.threshold = 1.0
    
    left_motor.leak = 0.92
    right_motor.leak = 0.92
    
    for i in range(HIDDEN_COUNT):
        hidden_neurons.append(LIFNeuron.new())

func _physics_process(delta):
    queue_redraw()
    
    hunger += HUNGER_RATE * delta
    hunger = clamp(hunger, 0.0, 1.0)
    
    hunger_neuron.step(hunger * 1.5)
    
    if hunger_neuron.spiked:
        print("Hunger Spiked")
    
    var left_strength = sense_food(true)
    var right_strength = sense_food(false)
    
    var left_spike = sensor_spike(left_strength)
    var right_spike = sensor_spike(right_strength)
    
    var time_now = Time.get_ticks_msec() / 1000
    
    var left_input := 0.0
    var right_input := 0.0
    
    var left_motor_input := 0.0
    var right_motor_input := 0.0
    
    if (left_spike):
        left_spike_times.append(time_now)
        
        left_input += STRONG_INPUT
        right_input += WEAK_INPUT
        
        print("LEFT SENSOR SPIKE")
    
    if (right_spike):
        right_spike_times.append(time_now)
        
        right_input += STRONG_INPUT
        left_input += WEAK_INPUT
        
        print("RIGHT SENSOR SPIKE")
    
    for i in range(hidden_neurons.size()):
        var input := left_input if i % 2 == 0 else right_input
        hidden_neurons[i].step(input)

    if hunger_neuron.spiked:
        var exploration = hunger * 0.4
        if randf() < 0.5:
            left_motor_input += exploration
        else:
            right_motor_input += exploration
        
        for h in hidden_neurons:
            h.step(0.5)
    
    #hidden neurons affect motors
    for i in range(hidden_neurons.size()):
        if hidden_neurons[i].spiked:
            if i % 2 == 0:
                left_motor_input += 0.3
            else:
                right_motor_input += 0.3
                
    left_motor_input = max(0.0, left_motor_input - left_inhibition)
    right_motor_input = max(0.0, right_motor_input - right_inhibition)
                
    var left_motor_spike = left_motor.step(left_motor_input)
    var right_motor_spike = right_motor.step(right_motor_input)
    
    var torque := 0.0
    
    if left_motor_spike:
        right_inhibition += 1.2
        left_inhibition = 0.0
        torque -= 1.0
    if right_motor_spike:
        left_inhibition += 1.2
        right_inhibition = 0.0
        torque += 1.0
    
    angular_velocity += torque * 3.0
    angular_velocity *= 0.9
    
    rotation += angular_velocity * delta
    
    #move forward
    var forward = Vector2.UP.rotated(rotation)
    velocity = forward * speed
    
    move_and_slide()
    
    prune_spikes(left_spike_times, time_now)
    prune_spikes(right_spike_times, time_now)
    
    left_inhibition *= 0.85
    right_inhibition *= 0.85
    
    #add hunger reward on food consumption

func _draw():
    draw_line(Vector2.ZERO, Vector2.UP * 75, Color.GREEN, 2)
    
    var left_dir = Vector2.UP.rotated(-SENSOR_ANGLE)
    var right_dir = Vector2.UP.rotated(SENSOR_ANGLE)
    
    draw_line(Vector2.ZERO, left_dir * SENSOR_RANGE, Color.RED, 1)
    draw_line(Vector2.ZERO, right_dir * SENSOR_RANGE, Color.BLUE, 1)
    
    #sensor rate
    var left_rate = left_spike_times.size() / RATE_WINDOW
    var right_rate = right_spike_times.size() / RATE_WINDOW
    
    var bar_width = 6
    var max_height = 40
    
    var left_height = clamp(left_rate / 10.0, 0, 1) * max_height
    var right_height = clamp(right_rate / 10.0, 0, 1) * max_height
    
    draw_rect(Rect2(Vector2(-20,30 - left_height), Vector2(bar_width, left_height)), Color.RED)
    draw_rect(Rect2(Vector2(14,30 - right_height), Vector2(bar_width, right_height)), Color.BLUE)
    
    #motor neuron bars
    var motor_max = 40
    
    var left_v = clamp(left_motor.voltage / left_motor.threshold, 0, 1) * motor_max
    var right_v = clamp(right_motor.voltage / right_motor.threshold, 0, 1) * motor_max
    
    draw_rect(Rect2(Vector2(-30, 60 - left_v), Vector2(6, left_v)), Color.ORANGE)
    draw_rect(Rect2(Vector2(24, 60 - right_v), Vector2(6, right_v)), Color.CYAN)
    
    if left_motor.spiked:
        draw_circle(Vector2(-27,40), 4, Color.ORANGE)
        print("LEFT MOTOR SPIKED")
    
    if right_motor.spiked:
        draw_circle(Vector2(27,40), 4, Color.CYAN)
        print("RIGHT MOTOR SPIKED")

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
    

func sensor_spike(strength: float) -> bool:
    return randf() < strength

func prune_spikes(spike_times: Array, current_time: float):
    while spike_times.size() > 0 and spike_times[0] < current_time - RATE_WINDOW:
        spike_times.pop_front()

func _on_mouth_area_entered(area: Area2D):
     if area.is_in_group("food"):
        eat_food(area)
        
func eat_food(food):
    hunger -= FOOD_REWARD
    hunger = clamp(hunger, 0.0, 1.0)
    
    #reset
    hunger_neuron.voltage = 0.0
    left_inhibition = 0.0
    right_inhibition = 0.0
    
    food.queue_free()
