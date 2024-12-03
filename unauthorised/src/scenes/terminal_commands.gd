extends Node
class_name Commands

@export_dir var data_path

var filesystem_dictionary:Dictionary
var root_files
var secret_files
var previous_dir = []
var current_dir 
var dir := []
var note = "Your private notes go here."
var file_content


func _ready() -> void:
	load_data()
	root_files = filesystem_dictionary["root"]
	secret_files = filesystem_dictionary["root/.scrt"]["files"]["content"]
	current_dir = root_files


func load_data():
	# For JSON custom prompts
	# Open the file for reading
	var f = FileAccess.open(data_path, FileAccess.READ)
	
	# Read the content of the file as text
	var json = f.get_as_text()
	var json_object = JSON.new()

	# Parse the JSON text
	json_object.parse(json)
	# Store the parsed data in the filesystem dictionary
	filesystem_dictionary = json_object.data


func help():
	get_parent().accept_sound.play()
	get_parent().terminal_text.text += "\n>|---BASIC COMMANDS---|"
	get_parent().terminal_text.text += "\n Command    | Usage"
	get_parent().terminal_text.text += "\n------------|-----------------------|"
	get_parent().terminal_text.text += "\n _help      | Shows advanced commands"
	get_parent().terminal_text.text += "\n list       | Lists files in directory"
	get_parent().terminal_text.text += "\n lost       | Shows current directory"
	get_parent().terminal_text.text += "\n open X     | Opens 'X'"
	get_parent().terminal_text.text += "\n note       | Opens private note"
	get_parent().terminal_text.text += "\n back       | Goes to parent directory"
	get_parent().terminal_text.text += "\n clear      | Clears terminal"
	get_parent().terminal_text.text += "\n shutdown   | Powers off system"
	get_parent().terminal_text.text += "\n>|-------------------------------|"

func _help():
	get_parent().accept_sound.play()
	get_parent().terminal_text.text += "\n>|---ADVANCED COMMANDS---|"
	get_parent().terminal_text.text += "\n Command     | Usage"
	get_parent().terminal_text.text += "\n-------------|----------------------------|"
	get_parent().terminal_text.text += "\n help        | Shows basic commands"
	get_parent().terminal_text.text += "\n open X Y    | Opens 'X' with password 'Y'"
	get_parent().terminal_text.text += "\n meta X      | Shows metadata for 'X'"
	get_parent().terminal_text.text += "\n note X      | Saves 'X' in private note"
	get_parent().terminal_text.text += "\n find X      | Locates 'X' in filesystem"
	get_parent().terminal_text.text += "\n access X    | Opens secret file 'X'"
	get_parent().terminal_text.text += "\n #WTF???     | ???"
	get_parent().terminal_text.text += "\n>|------------------------------------|"


func open(filename:String, password:String = ""):
	# Checks if filename exists in the current directory
	if current_dir.has(filename):
		get_parent().display_text.text = ""
		var file = current_dir[filename]
		if typeof(file) == TYPE_DICTIONARY:
			#Check for password
			if file.has("password") and file["password"] != password:
				get_parent().terminal_text.text += "\n> Error: Incorrect password for " + filename
				get_parent().reject_sound.play()
				return
			
			if file.has("content"):
				if typeof(file["content"]) == TYPE_DICTIONARY:
					get_parent().accept_sound.play()
				# If it's a directory, open it
					previous_dir.append(current_dir)
					current_dir = file["content"]
					get_parent().terminal_text.text += "\n> Opened folder: " + filename
					dir.append_array([filename])
					print(dir)
					
					
				elif typeof(file["content"]) == TYPE_STRING:
					get_parent().accept_sound.play()
					var txt = file["content"]
					
					get_parent().terminal_text.text += "\n> Opening file: " + filename
					if file["content"].contains("res://"):
						if file["content"].contains("res://assets/photos"):
							txt = "[img]%s[/img]"%str(file["content"])
						else:
							var f = FileAccess.open(file["content"], FileAccess.READ)
							# Read the content of the file as text
							txt = f.get_as_text()
						
					display_file_content(str(txt))
					
				else:
					get_parent().terminal_text.text += "\n> Error: Unknown file type for " + filename
					
	else:
		get_parent().reject_sound.play()
		get_parent().terminal_text.text += "\n> Error: '" + filename + "' not found in the current directory."

func meta(filename: String):
	if current_dir.has(filename):
		get_parent().accept_sound.play()
		var password_protected = false
		if current_dir[filename].has("password") and current_dir[filename]["password"] != "":
			password_protected = true
		if current_dir.has(filename) and current_dir[filename].has("meta_data"):
			get_parent().terminal_text.text += "\n>--- Metadata for " + filename + ":\n" + current_dir[filename]["meta_data"] + "\nPassword Protected: %s"%str(password_protected)
			get_parent().terminal_text.text += "\n>------------------------------|"
		else:
			get_parent().terminal_text.text += "\n> Metadata for %s was not found!"%filename
	else :
		get_parent().reject_sound.play()
		get_parent().terminal_text.text += "\n> Error: '%s' not found in the current directory"%filename

func list():
	var file_type:String
	var password_status = "_"
	get_parent().accept_sound.play()
	get_parent().terminal_text.text += "\n>|---Contents---|"
	for file in current_dir:
		# Skip `meta_data`, `password`, and `content`
		#if file in ["meta_data", "password", "content", "file_type"]:
			#continue
		if current_dir[file].has("file_type"):
			file_type = current_dir[file]["file_type"]
		if current_dir[file].has("password"):
			if current_dir[file]["password"] == "":
				password_status = "_"
			else:
				password_status = "#"
		get_parent().terminal_text.text += "\n> " + "[%s] "%password_status+str(file) + " [%s]"%file_type
	get_parent().terminal_text.text += "\n>|--------------|"


func lost():
	# Displays the path to the current directory by iterating `previous_dir`
	var path = "root"
	for i in range(previous_dir.size()):
		path += "/" + dir[i]
	get_parent().accept_sound.play()
	get_parent().terminal_text.text += "\n> Current Directory: " + path


func finder(search:String):
	# Recursively search for a file or directory within the file system
	for hidden_name in ["meta_data", "password", "content", "file_type"]:
		if search == hidden_name:
			get_parent().reject_sound.play()
			get_parent().terminal_text.text += "\n> Error: " + search + " not found."
			return
			
	var result = recursive_search(filesystem_dictionary, search, "")
	if result:
		for hidden_name in ["meta_data", "password", "content", "file_type"]:
			result = result.replace("/%s"%hidden_name, "")
		get_parent().accept_sound.play()
		get_parent().terminal_text.text += "\n> Found: " + search + " at " + result
	else:
		get_parent().reject_sound.play()
		get_parent().terminal_text.text += "\n> Error: " + search + " not found."

func cls():
	get_parent().accept_sound.play()
	get_parent().terminal_text.text = ""
	

func access(search: String):
	if secret_files.has(search):
		var file = secret_files[search]
		get_parent().terminal_text.text += "\n> Accessing file: "+search
		if file.has("content"):
			if typeof(file["content"]) == TYPE_STRING:
				get_parent().accept_sound.play()
				var txt = file["content"]
				
				if file["content"].contains("res://"):
					var f = FileAccess.open(file["content"], FileAccess.READ)
					
					# Read the content of the file as text
					txt = f.get_as_text()
					
				display_file_content(txt)
				
			else:
				get_parent().terminal_text.text += "\n> Error: Unknown file type for " + search
				
	else:
		get_parent().reject_sound.play()
		get_parent().terminal_text.text += "\n> Error: No secret file named '" + search + "' was found."

func back():
	if previous_dir.size() > 0:
		get_parent().accept_sound.play()
		current_dir = previous_dir.pop_back()
		get_parent().terminal_text.text += "\n> Moved up a level."
		dir.remove_at(dir.size() - 1)
		get_parent().display_text.text = ""
	else:
		get_parent().reject_sound.play()
		get_parent().terminal_text.text += "\n> Already at the root level!"


func notes():
	get_parent().accept_sound.play()
	get_parent().terminal_text.text += "\n> Private Note:\n" + note + "\n----------------------"

func  note_saved():
	get_parent().accept_sound.play()
	get_parent().terminal_text.text += "\n> Note saved!\n"


func recursive_search(directory, search_key, path):
	for key in directory:
		var new_path = path + "/" + key
		if key == search_key:
			return new_path #I can adjust this to bring more than one value
		elif typeof(directory[key]) == TYPE_DICTIONARY:
			var result = recursive_search(directory[key], search_key, new_path)
			if result != null:
				return result
	return null

# Helper to display file content with sound and animation
func display_file_content(content):
	get_parent().accept_sound.play()
	get_parent().display_text.text = content
	get_parent().display_file()
