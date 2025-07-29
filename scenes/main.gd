extends Node

# PRELOAD
var stump_scene = preload("res://scenes/stump.tscn")
var barrel_scene = preload("res://scenes/barrel.tscn")
var rock_scene = preload("res://scenes/rock.tscn")
var bird_scene = preload("res://scenes/bird.tscn")
var obstacle_types := [stump_scene, rock_scene, barrel_scene]
var obstacles: Array
var bird_heights := [200, 390]

# Fallback obstacle creation (for HTML5 compatibility)
var obstacle_textures := []
var use_fallback := false

# Touch controls
var touch_start_pos := Vector2.ZERO
var touch_active := false

# const
const RABBIT_START = Vector2i(150, 485)
const CAM_START = Vector2i(575, 324)
const SCORE_MODIFIER : int = 10
const SPEED_MOD : int = 5000
const START_SPEED : float = 10.0
const MAX_SPEED : int = 25
const GROUND_WIDTH : int = 2304  # Width of a single ground tile

#var
var speed : float
var screen_size : Vector2i
var score : int  
var game_running : bool
var last_obs
var ground_height : int
var difficulty
const MAX_DIFFICULTY : int = 2
var high_score : int
var ground_tiles : Array  # Array to track multiple ground tiles

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)
	ground_tiles = [$Ground]  # Start with the initial ground tile
	
	# Force fallback mode for HTML5 exports (ground obstacles have CollisionPolygon2D issues)
	use_fallback = true
	print("HTML5 Export: Using fallback obstacle creation (CollisionPolygon2D issues)")
	load_fallback_textures()
	
	new_game()

func load_fallback_textures():
	# Load textures directly for fallback obstacle creation
	var stump_texture = load("res://assets/obstacles/stump.png")
	var rock_texture = load("res://assets/obstacles/rock.png")
	var barrel_texture = load("res://assets/obstacles/barrel.png")
	
	print("Loading fallback textures for HTML5...")
	print("Stump texture: ", stump_texture != null)
	print("Rock texture: ", rock_texture != null)
	print("Barrel texture: ", barrel_texture != null)
	
	if stump_texture != null and rock_texture != null and barrel_texture != null:
		obstacle_textures = [stump_texture, rock_texture, barrel_texture]
		print("Fallback textures loaded successfully")
	else:
		print("Failed to load fallback textures - using colored rectangles")
		# Create simple colored rectangles as fallback
		obstacle_textures = [Color.RED, Color.GREEN, Color.BLUE]

func create_fallback_obstacle(texture_index: int):
	var obstacle = Area2D.new()
	
	# Set up sprite or colored rectangle
	if obstacle_textures[texture_index] is Texture2D:
		# Use actual texture
		var sprite = Sprite2D.new()
		sprite.texture = obstacle_textures[texture_index]
		sprite.scale = Vector2(3, 3)
		sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		obstacle.add_child(sprite)
	else:
		# Use colored rectangle
		var color_rect = ColorRect.new()
		color_rect.color = obstacle_textures[texture_index]
		color_rect.size = Vector2(60, 60)
		color_rect.position = Vector2(-30, -30)
		obstacle.add_child(color_rect)
	
	# Set up collision with simple RectangleShape2D (more reliable than CollisionPolygon2D)
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(60, 60)  # Simple rectangle collision
	collision.shape = shape
	collision.scale = Vector2(3, 3)
	
	obstacle.add_child(collision)
	
	return obstacle

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	$BGMusic.play()
	
	# Clear obstacles
	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()
	
	# Reset rabbit and camera
	$Rabbit.position = RABBIT_START
	$Rabbit.velocity = Vector2i(0, 0)
	$Camera2D.position = CAM_START
	
	# Reset ground tiles
	for tile in ground_tiles:
		if tile != $Ground:  # Don't delete the original ground
			tile.queue_free()
	ground_tiles = [$Ground]
	$Ground.position = Vector2i(0, 0)
	
	$HUD.get_node("Play").show()
	$GameOver.hide()

# Handle touch input
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch started
			touch_start_pos = event.position
			touch_active = true
			
			# Start game if not running
			if not game_running:
				game_running = true
				$HUD.get_node("Play").hide()
		else:
			# Touch ended
			touch_active = false

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
	
		# Update ground tiles - create new tiles as needed
		update_ground_tiles()
		
		# remove obs
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs)
			
	else:
		# Check for keyboard input (for desktop) or touch input (for mobile)
		if Input.is_action_just_pressed("ui_accept") or touch_active:
			game_running = true
			$HUD.get_node("Play").hide()

func update_ground_tiles():
	# Check if we need to add a new ground tile
	var rightmost_tile = ground_tiles[-1]
	var camera_right_edge = $Camera2D.position.x + screen_size.x / 2
	
	# If camera is approaching the right edge of the rightmost tile, add a new one
	if camera_right_edge > rightmost_tile.position.x + GROUND_WIDTH - screen_size.x:
		var new_ground = $Ground.duplicate()
		new_ground.position.x = rightmost_tile.position.x + GROUND_WIDTH
		add_child(new_ground)
		ground_tiles.append(new_ground)
	
	# Remove tiles that are far behind the camera
	var camera_left_edge = $Camera2D.position.x - screen_size.x / 2
	for i in range(ground_tiles.size() - 1, -1, -1):  # Iterate backwards
		var tile = ground_tiles[i]
		if tile.position.x + GROUND_WIDTH < camera_left_edge - screen_size.x:
			if tile != $Ground:  # Don't delete the original ground
				tile.queue_free()
				ground_tiles.remove_at(i)
		
func show_score():
	$HUD.get_node("Score").text = "SCORE: " + str(score / SCORE_MODIFIER)

func generate_obs():
	# Check if we should generate obstacles
	var should_generate = false
	if obstacles.is_empty():
		should_generate = true
		print("No obstacles, generating first obstacle")
	elif last_obs != null and last_obs.position.x < score + randi_range(400, 500):
		should_generate = true
		print("Generating new obstacle at score: ", score)
	
	if should_generate:
		print("Starting obstacle generation...")
		# Generate ground obstacles
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			if use_fallback:
				# Use fallback obstacle creation
				var texture_index = randi() % obstacle_textures.size()
				obs = create_fallback_obstacle(texture_index)
				print("Created fallback obstacle ", i, " with texture index: ", texture_index)
			else:
				# Use preloaded scenes
				var obs_type = obstacle_types[randi() % obstacle_types.size()]
				if obs_type != null:
					obs = obs_type.instantiate()
				else:
					continue
			
			if obs != null:
				var obs_x : int = screen_size.x + score + 500 + (i * 100)
				var obs_y : int = screen_size.y - 130
				last_obs = obs
				add_obs(obs, obs_x, obs_y)
				print("Spawned obstacle at: ", obs_x, ", ", obs_y)  # Debug
			else:
				print("Failed to create obstacle")
		
		# Additionally random chance to spawn a bird
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				# Generate bird obstacles
				if bird_scene != null and not use_fallback:
					obs = bird_scene.instantiate()
					if obs != null:
						var obs_x : int = screen_size.x + score + 400
						var obs_y : int = bird_heights[randi() % bird_heights.size()]
						add_obs(obs, obs_x, obs_y)
						print("Spawned bird at: ", obs_x, ", ", obs_y)  # Debug
		
func add_obs(obs, x, y):
	if obs != null:
		obs.position = Vector2i(x, y)
		obs.body_entered.connect(hit_obs)
		add_child(obs)
		obstacles.append(obs)
		print("Added obstacle to scene. Total obstacles: ", obstacles.size())  # Debug
	else:
		print("Cannot add null obstacle")
	
func adjust_difficulty():
	difficulty = score / SPEED_MOD
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY
		
func remove_obs(obs):
	if obs != null:
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
