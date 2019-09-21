"""
@todo: Scale the bullet relative to the tower's scale.
@todo 
1. Introduce total number of waves, waiting time between each waves.
2. In each wave slightly increase the mob speed or add show different mobs.
3. After particular period of time, call the final battle for the current level.
4. Need certain mapping of Mob placeholder points and it's required rotation degree

Idea: 
1. Introduce Level Configuration Manifest JSON to contain all this information.
   Include the above mentioned points as configurable ones.
2. Each Level should read this manifesto

"""
extends Node2D

export var number_of_enemies = 5
onready var enemies_on_screen = 0

var ticks = {
	"BattleTimer": 3, 
	"Completed": {
		"BattleTimer": 0
	}
}


var Enemy : PackedScene = load("res://Scenes/Enemies/Enemy.tscn")
var Placeholder : PackedScene = load("res://Scenes/Towers/TowerPlaceholder.tscn")
var Tower : PackedScene = load("res://Scenes/Towers/Defense/Tower.tscn")
export (Array, float) var tower_rotation_mapping = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	var curve = $DefensePath.curve
	for i in range(0, curve.get_point_count()):
		var tower_placeholder = Tower.instance()#Placeholder.instance()
		tower_placeholder.scale = Vector2(0.5, 0.5)
		tower_placeholder.position = curve.get_point_position(i)
		if tower_rotation_mapping[i] != null:
			tower_placeholder.rotation = tower_rotation_mapping[i]
		add_child(tower_placeholder)
		

func start_battle_timer(start: bool):
	if start and ticks.Completed.BattleTimer < ticks.BattleTimer:
		$BattleTimer.start()
	else:
		$BattleTimer.stop()

func _on_EnemyTimer_timeout():
	if enemies_on_screen < number_of_enemies:
		spawn_enemy()
	else:
		$EnemyTimer.stop()
		enemies_on_screen = 0
		start_battle_timer(true)

func spawn_enemy(local_position = Vector2.ZERO):
	var enemy = Enemy.instance()
	enemy.position = $EnemyStartPosition.global_position + local_position
	enemy.goal = $EnemyEndPosition.global_position
	enemy.navigation = $Navigation2D
	enemy.scale = Vector2(0.5, 0.5)
	enemy.connect("enemy_was_reached_goal", self, "on_enemy_reached_goal")
	add_child(enemy)
	enemies_on_screen += 1
	

func on_enemy_reached_goal():
	print("@todo enemy reached goal, shake the screen or similar")
	#$Camera2D.shake = true
func _on_BattleTimer_timeout():
	ticks.Completed.BattleTimer += 1

	if $EnemyTimer.is_stopped():
		$EnemyTimer.start()


func _on_IdleTimer_timeout():
	$EnemyTimer.start()
	$AudioAmbience.stop()
	$AudioBattle.play()
	$IdleTimer.queue_free()
