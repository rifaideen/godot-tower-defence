"""
Handles missile, hide empty sprite when not firing.
"""
extends "res://Scenes/Towers/Tower.gd"

func is_firing(value):
	#call the parent implementation
	.is_firing(value)
	#toggle sprites visibility while firing
	if firing:
		$sprite.hide()
		$SpriteEmpty.show()

func start_animation():
	#hide empty sprite
	$SpriteEmpty.hide()
	#call the parent implimentation
	.start_animation()

func stop_animation():
	#hide empty sprite
	$SpriteEmpty.hide()
	.stop_animation()