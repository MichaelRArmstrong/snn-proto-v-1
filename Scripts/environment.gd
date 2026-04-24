extends Node2D
#Enforce environment bounds and spawn food

#Dish bounds
@export var dish_center := Vector2(270,270)
@export var dish_radius := 400
@export var deadzone_radius := 50
@export var dish_resolution := 10 #Space between each point in the field

#circular dish shaped field of points, nutrition value lerped between them in a gradient.
var dish_grid_points := []
var noise

func _ready():
	add_to_group("environment")
	
	var grid_size = dish_radius * 2
	var point_count = (grid_size / dish_resolution) * (grid_size / dish_resolution)
	noise = FastNoiseLite.new()
	#noise.get_image(grid_size,grid_size,false,false,true)

	
	for	row in range(point_count+1):
		for col in range(point_count+1):
			var x = col * dish_resolution
			var y = row * dish_resolution
			
			var offset = Vector2((540 - dish_radius)/2,(540-dish_radius)/2)
			#check if its in the dish
			if Vector2(x,y).distance_to(dish_center) <= dish_radius:
				dish_grid_points.append(Vector2(x,y))

func _draw() -> void:
	noise.seed += 1
	for point in dish_grid_points:
		var n = (noise.get_noise_2d(point.x, point.y) + 1.0) / 2.0
		#if n > 0.5:
			#n = 1
		#else:
			#n = 0
		var pos: Vector2 = point
		#draw_circle(point, dish_resolution * 0.5, Color(1.0 - n, n, 0.0))
		draw_rect(Rect2(pos, Vector2(dish_resolution, dish_resolution)), Color(1.0 - n, n, 0.0))

func get_nutrition_at(pos: Vector2) -> float:
	if pos.distance_to(dish_center) <= dish_radius:
		var n = (noise.get_noise_2d(pos.x, pos.y) + 1.0) / 2.0
		#if n > 0.5:
			#n = 1
		#else:
			#n = 0
		return n
	else:
		return 0.0
