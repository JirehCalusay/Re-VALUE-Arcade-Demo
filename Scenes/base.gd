extends Node2D

@export var camera_node_path: NodePath = "Camera2D"

func _ready():
	var cam = get_node(camera_node_path) as Camera2D
	if cam:
		# Get the camera's visible area in pixels
		var visible_size = cam.get_camera_screen_rect().size

		# Set window size to match camera
		DisplayServer.window_set_size(visible_size)

		# Center the window on screen
		var screen_size = DisplayServer.screen_get_size(0)
		var _position = (screen_size - visible_size) / 2
		DisplayServer.window_set_position(_position)
