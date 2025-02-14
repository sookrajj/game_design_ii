extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	Glob.current = "driver"
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_2_pressed() -> void:
	Glob.current = "hybrid"
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_3_pressed() -> void:
	Glob.current = "iron"
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_4_pressed() -> void:
	Glob.current = "chipper"
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_button_5_pressed() -> void:
	Glob.current = "putter"
	self.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
