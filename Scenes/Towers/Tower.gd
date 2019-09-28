"""
Tower captures the target and fire the bullets.
A tower decides the bullet's speed and damage points If the enemy was hit by the bullet.
"""
extends Node2D

enum TYPES {NORMAL, DOUBLE_DECKER}

"""
Member variables
"""
#speed of the bullet
export (int, 1,5) var speed = 3
#the damage amount it causes to enemy
export (int) var damage_points = 5
#firing delay in seconds
export (float) var firing_delay_interval = 0
#the bullet this tower uses
export (PackedScene) var Bullet
#the type of tower
export (TYPES) var type = TYPES.NORMAL
#is enabled?
export (bool) var is_enabled = true
#is firing?
var firing = false
#list of targets and processed one by one
var targets = []
#the individual target to focus
var target = null

export (PackedScene) var BasementPlaceholder

"""
onready event variables
"""
onready var initial_rotation = self.rotation_degrees


"""
Godot's default functions
"""
func _ready():
	if !is_enabled:
		$DefenceSurface/CollisionShape2D.disabled = true
		set_process(false)
		return

	#add tower's basement placeholder
	var placeholder = BasementPlaceholder.instance()
	placeholder.position = self.position
	placeholder.scale = Vector2(scale.x * 0.8, scale.y * 0.8)
	#get_parent().add_child(placeholder)
	get_parent().call_deferred("add_child", placeholder)

	#start the animation
	start_animation()

"""
Look at the target and fire
"""
func _process(delta):
	if target != null:
		self.look_at(target.global_position)
		if !firing:
			fire()

"""
Utility functions
"""
#Fire the bullet
func fire():
	is_firing(true)
	if self.type == TYPES.NORMAL:
		load_bullet($BulletPointer.global_position)
	elif self.type == TYPES.DOUBLE_DECKER:
		#add 1st bullets
		var bullet_position = $BulletPointer.global_position - Vector2(0, 10)
		load_bullet(bullet_position)
		#add 2nd bullet
		bullet_position = $BulletPointer.global_position + Vector2(0, 10)
		load_bullet(bullet_position)

#Load the bullet and connect it's signals
func load_bullet(_position):
	#create bullet
	var bullet = Bullet.instance()

	#connect signals to reset the tower's firing status
	bullet.connect("enemy_was_hit", self, "reset_firing")
	bullet.connect("exited_screen", self, "reset_firing")

	#setup the bullet properties
	var direction = target.global_position - global_position
	var _scale = Vector2(scale.x * 0.75, scale.y * 0.75)
	bullet.init(_position, direction, self.rotation_degrees, self.speed, self.damage_points, _scale)
	
	#add the bullet
	get_parent().add_child(bullet)

#Sets the tower's firing status
func is_firing(value):
	firing = value

"""
Event handlers
"""
#append the enemy to targets and connect it's signal
func _on_DefenceSurface_body_entered(body):
	stop_animation()
	"""
	Set the target only when the tower is not targeting any enemy already.
	"""
	if target == null:
		target = body
	else:
		targets.append(body)
	"""
	connect the signal and when enemy was died, remove from the existing targets, If any.
	"""
	body.connect("enemy_was_died", self, "on_target_died")

"""
remove the enemy from the target and assign new target, If any. 
Otherwise, the tower rotates back to it's initial position.
"""
func _on_DefenceSurface_body_exited(body):
	body.disconnect("enemy_was_died", self, "on_target_died")
	"""
	Enemies are handles using FIFO DataStructure
	"""
	target = null

	if targets.size() > 0:
		target = targets.pop_front()
	else:
		$Tween.interpolate_property(self, "rotation_degrees", rotation_degrees, initial_rotation, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN)
		$Tween.start()
		yield($Tween, "tween_completed")
		start_animation()

#handles weapon's signals.
func reset_firing():
	if firing_delay_interval != 0:
		yield(get_tree().create_timer(firing_delay_interval), "timeout")
	is_firing(false)

#reset the target and remove from the targets list
func on_target_died(enemy):
	if enemy == target:
		target = targets.pop_front()
	elif targets.size() > 0:
		for i in range(targets.size()):
			if enemy == targets[i]:
				targets.remove(i)
				break
#toggle sprite and animatable sprite's visibility and starts animation
func start_animation():
	$sprite.hide()
	$AnimatableSprite.show()
	$AnimationPlayer.play("patrol")

#toggle sprite and animatable sprite's visibility and stop animation
func stop_animation():
	$AnimatableSprite.hide()
	$sprite.show()
	$AnimationPlayer.stop()