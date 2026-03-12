extends Node
#Enforce environment bounds and spawn food

#Dish bounds
@export var dish_center := Vector2(270,270)
@export var dish_radius := 400

#Food
@export var food_scene: PackedScene
@export var food_count := 300

func _ready():
	fill_dish()
	return

func fill_dish():
	for i in food_count:
		spawn_food()

func spawn_food():
	var pos = random_dish_position()
	var food = food_scene.instantiate()
	food.global_position = pos
	add_child(food)
	return
	
func random_dish_position() -> Vector2:
	#get a random point in a square that is dish diameter x dish diameter, then check if its within thee circele, (distance from center < radius)
	var x = randi_range(dish_center.x - dish_radius, dish_center.x + dish_radius)
	var y = randi_range(dish_center.y - dish_radius, dish_center.y + dish_radius)
	var rand_pos = Vector2(x,y)
	while rand_pos.distance_to(dish_center) > dish_radius:
		x = randi_range(dish_center.x - dish_radius, dish_center.x + dish_radius)
		y = randi_range(dish_center.y - dish_radius, dish_center.y + dish_radius)
		rand_pos = Vector2(x,y)
	return(rand_pos)
