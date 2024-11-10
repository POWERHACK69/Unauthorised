extends Control

@onready var line_edit: LineEdit = $ContentContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var terminal_text: TextEdit = $ContentContainer/HBoxContainer/MarginContainer/VBoxContainer/TextEdit
@onready var commands= $Commands
@onready var display_text: RichTextLabel = $ContentContainer/HBoxContainer/RichTextLabel

@onready var accept_sound: AudioStreamPlayer = $AcceptSound
@onready var reject_sound: AudioStreamPlayer = $RejectSound


var prompt
var text_input



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	terminal_text.get_v_scroll_bar().self_modulate = Color("white", 0.0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	line_edit.grab_focus.call_deferred()
	terminal_text.scroll_vertical = terminal_text.get_line_count()
	
	#if Input.is_action_just_pressed("numbers"):
		#key_click.play()
	#if Input.is_action_just_pressed("Space_Enter"):
		#key_click.play()
	
	if Input.is_action_just_pressed("Enter") and line_edit.text != "":
		#terminal_text.text += "\n"+"> "+line_edit.text
		text_input = line_edit.text
		prompt = text_input.split(" ")
		line_edit.text = ""
		user_command()

func user_command():
	if prompt[0] == "help" and prompt.size()==1:
		commands.help()
		accept_sound.play()
	elif prompt[0] == "open":
		if prompt.size()==1:
			terminal_text.text += "> Command requires atleast one argument\n> Type 'help' to see a list of commands"
			reject_sound.play()
		elif prompt.size()==2:
			commands.open(prompt[1], "")
			accept_sound.play()
		elif prompt.size()==3:
			commands.open(prompt[1], prompt[2])
			accept_sound.play()
		else:
			invalid_command()
	elif prompt[0] == "list":
		if prompt.size()==1:
			commands.list()
			accept_sound.play()
		else:
			invalid_command()
	elif prompt[0] == "back":
		if prompt.size()==1:
			commands.back()
			accept_sound.play()
		else:
			invalid_command()
	elif prompt[0] == "lost":
		if prompt.size()==1:
			commands.lost()
			accept_sound.play()
		else:
			invalid_command()
	elif prompt[0] == "cls" or prompt[0] == "clear":
		if prompt.size()==1:
			commands.cls()
			accept_sound.play()
		else:
			invalid_command()
	elif prompt[0] == "shutdown" or prompt[0] == "quit":
		if prompt.size()==1:
			accept_sound.play()
			accept_sound.connect("finished", Callable(get_tree(), "quit"))
		else:
			invalid_command()
	elif prompt[0] == "echo" or prompt[0] == "@echo":
		accept_sound.play()
		if prompt.size() ==1:
			terminal_text.text += "\n> ''"
		else :
			var echoed = text_input.replace(prompt[0]+" ","")
			terminal_text.text += "\n> '"+echoed+"'"
	elif prompt[0] == '#WTF???' and prompt.size() == 1:
		accept_sound.play()
		OS.shell_open("https://www.youtube.com/@-RedIndieGames")
		
	elif (prompt[0] == 'rickroll' or prompt[0] == 'rick') and prompt.size()==1:
		accept_sound.play()
		OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
		
	else:
		invalid_command()
	
func invalid_command():
	reject_sound.play()
	terminal_text.text += "\n>'"+text_input+ "' is not a valid command\n> Type 'help' to see a list of commands"

func display_file():
	$AnimationPlayer.play("animate_text")
	$TextDisplay.play()
