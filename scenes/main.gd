extends Node

# PRELOAD
var stump_scene = preload("res://scenes/stump.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles: Array
var bird_heights := [200, 390]

# const
const RABBIT_START = Vector2i(150, 485)
const CAM_START = Vector2i(575, 324)
const SCORE_MODIFIER : int = 10
const SPEED_MOD : int = 5000
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25

#var
var speed : float
var screen_size : Vector2i
var score : int  
var game_running : bool
var last_obs
var ground_heght : int
var difficulty
const MAX_DIFFICULTY : int = 2
var high_score : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_heght = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	$BGMusic.play()
	
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	$Rabbit.position = RABBIT_START
	$Rabbit.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START
	$Ground.position = Vector2i(0, 0)
	
	$HUD.get_node("Play").show()
	$GameOver.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if game_running:
		speed = START_SPEED + score / SPEED_MOD
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()
			
		generate_obs()
		
		# MOVE THE RABBIT
		$Rabbit.position.x += speed
		$Camera2D.position.x += speed
	
		score += speed
		show_score()
	
		#update rgoud
		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5 :
			$Ground.position.x += screen_size.x
		
		# remove obs
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
			
	else:
		if Input.is_action_just_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("Play").hide()
			
		
func show_score():
	$HUD.get_node("Score").text = "SCORE: " + str(score / SCORE_MODIFIER)

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(400, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var obs_height = obs.get_node("Sprite2D").texture.get_height()
			var obs_scale = obs.get_node("Sprite2D").scale
			var obs_x : int = screen_size.x + score + 500 + (i * 100)
			var obs_y : int = screen_size.y - 130
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		#additionally random chance to spawn a bird
		if difficulty ==  MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				#generate bird obstacles
				obs = bird_scene.instantiate()
				var obs_x : int = screen_size.x + score + 400
				var obs_y : int = bird_heights[randi() % bird_heights.size()]
				add_obs(obs, obs_x, obs_y)
		
func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)
	
func adjust_difficulty():
	difficulty = score / SPEED_MOD
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)
	
func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("High Score").text = "HIGH SCORE: " + str(high_score / SCORE_MODIFIER)
	
func hit_obs(body):
	if body.name == "Rabbit":
		game_over()
	
func game_over():
	check_high_score() 
	get_tree().paused = true
	game_running = false
	$GameOver.show()
