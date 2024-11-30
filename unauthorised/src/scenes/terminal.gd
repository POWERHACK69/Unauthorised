extends Control

@onready var line_edit: LineEdit = $ContentContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/LineEdit
@onready var terminal_text: TextEdit = $ContentContainer/HBoxContainer/MarginContainer/VBoxContainer/TextEdit
@onready var commands= $Commands
@onready var display_text: RichTextLabel = $ContentContainer/HBoxContainer/RichTextLabel

@onready var accept_sound: AudioStreamPlayer = $AcceptSound
@onready var reject_sound: AudioStreamPlayer = $RejectSound


var prompt
var text_input




func _ready() -> void:
	terminal_text.get_v_scroll_bar().self_modulate = Color("white", 0.0)
	line_edit.grab_focus() 

func _process(_delta: float) -> void:
	terminal_text.scroll_vertical = terminal_text.get_line_count()
	line_edit.grab_focus()
	if Input.is_action_just_pressed("Enter") and line_edit.text != "":
		text_input = line_edit.text
		prompt = text_input.split(" ")
		line_edit.text = ""
		user_command()
	if Input.is_action_just_pressed("prev_command") and line_edit.text == "":
		line_edit.text = text_input

func play_sound(is_accepted: bool) -> void:
	if is_accepted:
		accept_sound.play()
	else:
		reject_sound.play()

func require_argument(command_name: String) -> void:
	terminal_text.text += "\n> Command '"+command_name+"' requires at least one argument\n> Type 'help' to see a list of commands"
	play_sound(false)

func user_command():
	match prompt[0]:
		"help", "man":
			if prompt.size() == 1:
				commands.help()
			else:
				invalid_command()
		"_help", "_man":
			if prompt.size() == 1:
				commands._help()
			else:
				invalid_command()
		"open", "xdg-open", "cd":
			if prompt.size() == 1:
				require_argument("open")
			elif prompt.size() == 2:
				commands.open(prompt[1])
			elif prompt.size() == 3:
				commands.open(prompt[1], prompt[2])
			else:
				invalid_command()
		"find":
			if prompt.size() == 1:
				require_argument("find")
			elif prompt.size() == 2:
				commands.finder(prompt[1])
			else:
				invalid_command()
		"access", "cat":
			if prompt.size() == 1:
				require_argument("access")
			elif prompt.size() == 2:
				commands.access(prompt[1])
			else:
				invalid_command()
		"meta":
			if prompt.size() == 1:
				require_argument("meta")
			elif prompt.size() == 2:
				commands.meta(prompt[1])
			else:
				invalid_command()
		"list", "ls":
			if prompt.size() == 1:
				commands.list()
			else:
				invalid_command()
		"back", "cd..":
			if prompt.size() == 1:
				commands.back()
			else:
				invalid_command()
		"note":
			if prompt.size() == 1:
				commands.notes()
			else:
				commands.note = text_input.replace("note ", "").substr(0, 128)
				commands.note_saved()
		"lost", "pwd":
			if prompt.size() == 1:
				commands.lost()
			else:
				invalid_command()
		"cls", "clear":
			if prompt.size() == 1:
				commands.cls()
			else:
				invalid_command()
		"shutdown", "quit":
			if prompt.size() == 1:
				play_sound(true)
				accept_sound.connect("finished", Callable(get_tree(), "quit"))
			else:
				invalid_command()
		"echo", "@echo":
			play_sound(true)
			if prompt.size() == 1:
				terminal_text.text += "\n> ''"
			else:
				var echoed = text_input.replace(prompt[0] + " ", "")
				terminal_text.text += "\n> '" + echoed + "'"
		"CRT":
			if prompt.size()== 1:
				play_sound(true)
				$CRTShader.visible = !$CRTShader.visible
		"#WTF???":
			if prompt.size() == 1:
				play_sound(true)
				OS.shell_open("https://www.youtube.com/@-RedIndieGames")
			else:
				invalid_command()
		"rickroll", "rick":
			if prompt.size() == 1:
				play_sound(true)
				OS.shell_open("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
			else:
				invalid_command()
		_:
			invalid_command()
	
func invalid_command():
	terminal_text.text += "\n>'"+text_input+"' is not a valid command\n> Type 'help' to see a list of commands"
	play_sound(false)


func display_file():
	$AnimationPlayer.play("animate_text")
	$TextDisplay.play()


func get_last_prompt():
	return 


func _on_rich_text_label_meta_clicked(meta: Variant) -> void:
	print(str(meta))
	OS.shell_open(str(meta))
