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
#Navigation2D object to find the path
var navigation : Navigation2D = null setget set_navigation
#paths from the 'navigation'
var paths = []
#end position / final destination
var goal = Vector2()
var velocity = Vector2.ZERO

const DEFAULT_MASS = 2.0

func _ready():
	$Node2D/TextureProgress.max_value = health
	$Node2D/TextureProgress.value = health
	$AnimationPlayer.play("walk")

func _physics_process(delta):
	#follow the paths
	if paths.size() > 0:
		var distance = position.distance_to(paths[0])
		if distance > 2:
			var desired_velocity = follow(velocity, global_position, paths[0])
			velocity = move_and_slide(desired_velocity)
			self.rotation = velocity.angle()
			#position = lerp(position, paths[0], (speed * delta) / distance)
			#self.look_at(paths[0])
			"""
			* Alternate approach
			* 	position = position.linear_interpolate(paths[0], (speed * delta) / distance)
			"""
		else:
			paths.remove(0)
	else:
		emit_signal("enemy_was_reached_goal")
		queue_free()

func follow(velocity, global_position, target_position, max_speed = speed, mass = DEFAULT_MASS):
	var desired_velocity = (target_position - global_position).normalized() * max_speed
	var steering = (desired_velocity - velocity) / mass

	return velocity + steering

"""
* navigation property setter method
"""
func set_navigation(new_navigation):
	navigation = new_navigation
	update_paths()

"""
* update the paths
"""
func update_paths():
	paths = navigation.get_simple_path(self.position, goal, true)

	"""
	* remove the enemy when the paths becomes zero.It means the enemy has reached it's goal.
	"""
	if paths.size() == 0:
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