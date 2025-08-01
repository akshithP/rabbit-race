extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800
const FAST_FALL_SPEED : int = 3000  # Speed for fast falling

# Touch controls
var touch_start_pos := Vector2.ZERO
var touch_active := false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:  
			$RunCol.disabled = false
			if Input.is_action_just_pressed("jump") or touch_active:
				velocity.y = JUMP_SPEED
				$JumpSound.play()
			else:
				$AnimatedSprite2D.play("running")
	else:
		# When in the air, check for fast fall
		if Input.is_action_pressed("down"):
			velocity.y = FAST_FALL_SPEED  # Fast fall down
			$AnimatedSprite2D.play("down")  # Play the down animation
		else:
			$AnimatedSprite2D.play("jumping")
		
	move_and_slide()

# Handle touch input for jumping
func _input(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			# Touch started - jump
			touch_start_pos = event.position
			touch_active = true
		else:
			# Touch ended
			touch_active = false
