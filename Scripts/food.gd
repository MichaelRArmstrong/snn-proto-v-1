extends Area2D


@export var nutrition := 0.5

func _ready():
	add_to_group("food")
