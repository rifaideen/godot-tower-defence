extends TextureProgress

var textures = {
	"red": load("res://resources/ui/red-button.png"),
	"yellow": load("res://resources/ui/yellow-button.png")
}

"""
change the sprites according to the current strength
"""
func _on_TextureProgress_value_changed(value):
	if value <= (max_value * 0.5):
		self.texture_progress = textures.get("red")
	elif value <= (max_value * 0.75):
		self.texture_progress = textures.get("yellow")
