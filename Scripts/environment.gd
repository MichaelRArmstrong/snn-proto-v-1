extends Node2D
#Enforce environment bounds and spawn food

#Dish bounds
@export var dish_center := Vector2(270,270)
@export var dish_radius := 400
@export var deadzone_radius := 50
@export var dish_resolution := 5 #Space between each point in the field

#circular dish shaped field of points, nutrition value lerped between them in a gradient.
var dish_grid_points := []
var noise

func _ready():
	var grid_size = dish_radius * 2
	var point_count = (grid_size / dish_resolution) * (grid_size / dish_resolution)
	noise = FastNoiseLite.new()
	noise.get_image(grid_size,grid_size,false,false,true)
	
	for	row in range(point_count+1):
		for col in range(point_count+1):
			var x = col * dish_resolution
			var y = row * dish_resolution
			
			var offset = Vector2((540 - dish_radius)/2,(540-dish_radius)/2)
			#check if its in the dish
			if Vector2(x,y).distance_to(dish_center) <= dish_radius:
				dish_grid_points.append(Vector2(x,y))

func _draw() -> void:
	for point in dish_grid_points:
		draw_circle(point,dish_resolution * 0.5,Color.from_rgba8((255 * -noise.get_noise_2d(point.x, point.y)),(255 * noise.get_noise_2d(point.x, point.y)),(255 * -noise.get_noise_2d(point.x, point.y))))
		
	
