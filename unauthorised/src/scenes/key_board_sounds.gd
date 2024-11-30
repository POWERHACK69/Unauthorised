extends Node

# Attach this to a Node in your scene

@onready var general_sound = preload("res://assets/sounds/Sfx/key.wav")
@onready var special_sound = preload("res://assets/sounds/Sfx/spacebar-click-keyboard-199448.wav")

func _input(event):
	if event is InputEventKey and event.pressed:
		# Check if the key pressed is Space or Enter
		if Input.is_action_pressed("Space_Enter"):
			# Play the special sound for Space and Enter keys
			return
		else:
			## Play the general sound for any other key
			play_sound(general_sound)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Space_Enter"):
		play_sound(special_sound)

func play_sound(sound):
	# This creates an AudioStreamPlayer2D on the fly and plays the sound.
	var player = AudioStreamPlayer2D.new()
	player.stream = sound
	player.volume_db = -5
	player.pitch_scale = randf_range(0.5, 1.5)
	add_child(player)
	player.play()
	
	#Queue the player for deletion once the sound is done
	player.connect("finished", Callable(player, "queue_free"))
