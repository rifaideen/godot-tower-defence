"""
Targets the enemy and emits the appropriate signals.
When the bullet exit the screen the 'exited_screen' will be emitted.
"""
extends Area2D

# warning-ignore:unused_signal
signal enemy_was_hit
# warning-ignore:unused_signal
signal exited_screen


export var direction = Vector2.ZERO
export (int, 1, 5) var speed = 3
#The amount of damage it causes in units
export (int, 1, 100) var point = 10

func _physics_process(delta):
	position += direction * speed * delta

"""
damage the enemy and emit the signal
"""
func _on_Bullet_body_entered(enemy):
	if enemy.has_method("take_damage"):
		enemy.call("take_damage", point)
	if $VisibilityNotifier2D.is_connected("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited"):
		$VisibilityNotifier2D.disconnect("screen_exited", self, "_on_VisibilityNotifier2D_screen_exited")
	__destruct("enemy_was_hit")

"""
emit the screen exited signal
"""
func _on_VisibilityNotifier2D_screen_exited():
	__destruct("exited_screen")

"""
emit the given signal and destroy free the weapon.
"""
func __destruct(_signal):
	emit_signal(_signal)
	queue_free()
