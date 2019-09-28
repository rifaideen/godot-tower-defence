"""
* Enemy's goal is to reach the end-position.
*
* Each enemy has it's own health (and health progress menu). When the health is zero, enemy will be died.
"""
extends KinematicBody2D

signal enemy_was_died(enemy)
signal enemy_was_reached_goal

export (int) var health = 100
export (int) var speed = 25

#the path to follow
var path : Path2D setget set_path
#paths from the 'Path2D'
var paths = []
#the movement vector
var velocity = Vector2.ZERO
#initial path index position
var index = 0

func _ready():
	$Node2D/TextureProgress.max_value = health
	$Node2D/TextureProgress.value = health
	$AnimationPlayer.play("walk")

func _physics_process(delta):
	if paths.size() == 0:
		return
	var target = paths[index]
	if position.distance_to(target) < 1:
		index = min(index + 1, paths.size())
		target = paths[index]
	velocity = (target - position).normalized() * speed
	velocity = move_and_slide(velocity)
	var current_rotation = Vector2.RIGHT.rotated(rotation)
	rotation = current_rotation.linear_interpolate(velocity, speed * delta).angle()

func set_path(value):
	path = value

	if path != null:
		paths = path.curve.get_baked_points()

"""
* Completed Goal, Emit the signal and free the enemy.
"""
func completed_goal():
	emit_signal("enemy_was_reached_goal")
	queue_free()

"""
* take damage, update progress bar and emit the signal when the health becomes zero
"""
func take_damage(point):
	health = max(0, health - point)
	$Node2D/TextureProgress.value = health

	if health <= 0:
		emit_signal("enemy_was_died", self)
		queue_free()