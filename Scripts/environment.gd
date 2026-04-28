extends Node2D
#Enforce environment bounds and spawn food

#Dish bounds
@export var dish_center := Vector2(0,0)
@export var dish_radius := 256

#circular dish shaped field of points, nutrition value lerped between them in a gradient.
@export var maps:Array[String] = []
@export var current_map_index: int = 0
@export var useMaps := true
@export var noise_frequency := 0.01
var map_image: Image
var map_sprite: Sprite2D


func _ready():
	add_to_group("environment")
	
	map_sprite = Sprite2D.new()
	if useMaps == true:
		load_map(current_map_index)
	else:
		var noise = FastNoiseLite.new()
		noise.frequency = noise_frequency 
		map_image = noise.get_seamless_image(512,512)
		
		map_sprite.texture = ImageTexture.create_from_image(map_image)
	map_sprite.position = dish_center
	add_child(map_sprite)

func load_map(index: int) -> void:
	current_map_index = clamp(index, 0, maps.size()-1)
	map_image = Image.load_from_file(maps[current_map_index])
	map_sprite.texture = ImageTexture.create_from_image(map_image)
	return

func get_nutrition_at(pos: Vector2) -> float:
	if pos.distance_to(dish_center) <= dish_radius:
		var local = pos - (dish_center - Vector2(256,256))#cahnge to local space
		var pixel_x = int((local.x / 512) * map_image.get_width())
		var pixel_y = int((local.y / 512) * map_image.get_height())
		pixel_x = clamp(pixel_x, 0, map_image.get_width() - 1)
		pixel_y = clamp(pixel_y, 0, map_image.get_height() - 1)
		var n = map_image.get_pixel(pixel_x, pixel_y).r #sample red channel pixel brightness, 0 - 1
		#n = (n*2) - 1 #map to -1 - 1
		return n
	else:
		return 0.0
