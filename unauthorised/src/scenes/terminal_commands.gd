extends Node
class_name Commands

@export_dir var data_path

var filesystem_dictionary:Dictionary
var root_files
var previous_dir = []
var current_dir 
var dir := []
var note = "Your private notes go here."


func _ready() -> void:
	load_data()
	root_files = filesystem_dictionary["root"]
	current_dir = root_files
	var my_array = ["Documents", "Documents2", "Documents3"]
	my_array.remove_at(my_array.size() - 1)
	print(my_array)


func load_data():
	# For JSON custom prompts
	# Open the file for reading
	var f = FileAccess.open(data_path, FileAccess.READ)
	# Check if the file exists
	assert(f.file_exists(data_path),"File path does not exist")
	
	# Read the content of the file as text
	var json = f.get_as_text()
	var json_object = JSON.new()

	# Parse the JSON text
	json_object.parse(json)
	# Store the parsed data in the content dictionary
	filesystem_dictionary = json_object.data


func help():
	get_parent().terminal_text.text += "\n>|---COMMAND LIST---|"
	get_parent().terminal_text.text += "\n help -> Displays command list"
	get_parent().terminal_text.text += "\n list -> Lists all files in the current directory"
	get_parent().terminal_text.text += "\n lost -> Shows the current directory"
	get_parent().terminal_text.text += "\n open X -> Opens directory/file 'X'"
	get_parent().terminal_text.text += "\n open X Y -> Opens directory/file 'X'\n 	Using password 'Y'"
	get_parent().terminal_text.text += "\n meta X-> Displays the meta data of file X"
	get_parent().terminal_text.text += "\n note -> Opens your private notes"
	get_parent().terminal_text.text += "\n find X -> Opens hidden file using ID 'X'"
	get_parent().terminal_text.text += "\n clear -> Clears the left terminal display"
	get_parent().terminal_text.text += "\n back -> Navigate to parent directory"
	get_parent().terminal_text.text += "\n shutdown -> Powers off the system"
	get_parent().terminal_text.text += "\n #WTF??? -> ???"
	get_parent().terminal_text.text += "\n>|-------------------|"


func open(filename:String, password:String = ""):
	# Checks if filename exists in the current directory
	if current_dir.has(filename):
		get_parent().display_text.text = ""
		var file = current_dir[filename]
		if typeof(file) == TYPE_DICTIONARY:
			# If it's a directory, open it
			previous_dir.append(current_dir)
			current_dir = file
			get_parent().terminal_text.text += "\n> Opened directory: " + filename
			dir.append_array([filename])
		elif typeof(file) == TYPE_STRING:
			# If it's a file, check for password if applicable
			if password == "":
				get_parent().terminal_text.text += "\n> Opening file: " + filename
				get_parent().display_text.text = file
				get_parent().display_file() #To animate the text
			else:
				# Here you could add code to check if a password is actually required for certain files
				get_parent().terminal_text.text += "\n> Opening file with password: " + filename + "\n> Content: " + file
		else:
			get_parent().terminal_text.text += "\n> Error: Unknown file type for " + filename
	else:
		get_parent().terminal_text.text += "\n> Error: '" + filename + "' not found in the current directory."


func list():
	print(current_dir)
	print(previous_dir)
	print(previous_dir.size())
	get_parent().terminal_text.text += "\n>|---Contents---|"
	for file in current_dir:
		get_parent().terminal_text.text += "\n> " + str(file)
	get_parent().terminal_text.text += "\n>|--------------|"


func lost():
	# Displays the path to the current directory by iterating `previous_dir`
	var path = "root"
	for i in range(previous_dir.size()):
		path += "/" + dir[i]
	get_parent().terminal_text.text += "\n> Current Directory: " + path


#func finder(search:String):
	## Recursively search for a file or directory within the file system
	#func recursive_search(directory, search_key, path):
		#for key in directory:
			#var new_path = path + "/" + key
			#if key == search_key:
				#return new_path
			#elif typeof(directory[key]) == TYPE_DICTIONARY:
				#var result = recursive_search(directory[key], search_key, new_path)
				#if result != null:
					#return result
		#return null
	#
	#var result = recursive_search(filesystem_dictionary, search, "root")
	#if result:
		#get_parent().terminal_text.text += "\n>Found: " + search + " at " + result
	#else:
		#get_parent().terminal_text.text += "\n>Error: " + search + " not found."


func cls():
	get_parent().terminal_text.text = ""
	


func back():
	if previous_dir.size() > 0:
		current_dir = previous_dir.pop_back()
		get_parent().terminal_text.text += "\n> Moved up a level."
		dir.remove_at(dir.size() - 1)
		get_parent().display_text.text = ""
	else:
		get_parent().terminal_text.text += "\n> Already at the root level!"


func notes():
	get_parent().terminal_text.text += "\n> Private Notes:\n" + note
