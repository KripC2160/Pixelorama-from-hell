extends AcceptDialog

onready var tree : Tree = $HSplitContainer/Tree
onready var right_side : VBoxContainer = $HSplitContainer/ScrollContainer/VBoxContainer
onready var languages = $HSplitContainer/ScrollContainer/VBoxContainer/Languages
onready var themes = $HSplitContainer/ScrollContainer/VBoxContainer/Themes
onready var grid_guides = $"HSplitContainer/ScrollContainer/VBoxContainer/Grid&Guides"

func _ready() -> void:
	var root := tree.create_item()
	var language_button := tree.create_item(root)
	var theme_button := tree.create_item(root)
	var grid_button := tree.create_item(root)
	language_button.set_text(0, "  " + tr("Language"))
	language_button.set_metadata(0, "Language")
	language_button.select(0)
	theme_button.set_text(0, "  " + tr("Themes"))
	theme_button.set_metadata(0, "Themes")
	grid_button.set_text(0, "  " + tr("Guides & Grid"))
	grid_button.set_metadata(0, "Guides & Grid")

	for child in languages.get_children():
		if child is Button:
			child.connect("pressed", self, "_on_Language_pressed", [child])

	for child in themes.get_children():
		if child is Button:
			child.connect("pressed", self, "_on_Theme_pressed", [child])

	if Global.config_cache.has_section_key("preferences", "theme"):
		var theme_id = Global.config_cache.get_value("preferences", "theme")
		change_theme(theme_id)
		themes.get_child(theme_id + 1).pressed = true

func _on_Tree_item_selected() -> void:
	for child in right_side.get_children():
		child.visible = false
	var selected : String = tree.get_selected().get_metadata(0)
	if "Language" in selected:
		languages.visible = true
	elif "Themes" in selected:
		themes.visible = true
	elif "Guides & Grid" in selected:
		grid_guides.visible = true

func _on_Language_pressed(button : Button) -> void:
	var index := 0
	var i := -1
	for child in languages.get_children():
		if child is Button:
			if child == button:
				button.pressed = true
				index = i
			else:
				child.pressed = false
			i += 1
	if index == -1:
		TranslationServer.set_locale(OS.get_locale())
	else:
		TranslationServer.set_locale(Global.loaded_locales[index])



	Global.config_cache.set_value("preferences", "locale", TranslationServer.get_locale())
	Global.config_cache.save("user://cache.ini")

func _on_Theme_pressed(button : Button) -> void:
	var index := 0
	var i := 0
	for child in themes.get_children():
		if child is Button:
			if child == button:
				button.pressed = true
				index = i
			else:
				child.pressed = false
			i += 1

	change_theme(index)

	Global.config_cache.set_value("preferences", "theme", index)
	Global.config_cache.save("user://cache.ini")


func change_theme(ID : int) -> void:
	var font = Global.control.theme.default_font
	var main_theme
	var top_menu_style
	var ruler_style
	if ID == 0: #Dark Theme
		Global.theme_type = "Dark"
		Global.transparent_background.create_from_image(preload("res://Assets/Graphics/Canvas Backgrounds/Transparent Background Dark.png"), 0)
		VisualServer.set_default_clear_color(Color(0.247059, 0.25098, 0.247059))
		main_theme = preload("res://Themes & Styles/Dark Theme/Dark Theme.tres")
		top_menu_style = preload("res://Themes & Styles/Dark Theme/DarkTopMenuStyle.tres")
		ruler_style = preload("res://Themes & Styles/Dark Theme/DarkRulerStyle.tres")
	elif ID == 2: #Godot's Theme
		Global.theme_type = "Dark"
		Global.transparent_background.create_from_image(preload("res://Assets/Graphics/Canvas Backgrounds/Transparent Background Godot.png"), 0)
		VisualServer.set_default_clear_color(Color(0.27451, 0.278431, 0.305882))
		main_theme = preload("res://Themes & Styles/Godot\'s Theme/Godot\'s Theme.tres")
		top_menu_style = preload("res://Themes & Styles/Godot\'s Theme/TopMenuStyle.tres")
		ruler_style = preload("res://Themes & Styles/Godot\'s Theme/RulerStyle.tres")
	
	Global.control.theme = main_theme
	Global.control.theme.default_font = font
	Global.top_menu_container.add_stylebox_override("panel", top_menu_style)
	Global.horizontal_ruler.add_stylebox_override("normal", ruler_style)
	Global.horizontal_ruler.add_stylebox_override("pressed", ruler_style)
	Global.horizontal_ruler.add_stylebox_override("hover", ruler_style)
	Global.horizontal_ruler.add_stylebox_override("focus", ruler_style)
	Global.vertical_ruler.add_stylebox_override("normal", ruler_style)
	Global.vertical_ruler.add_stylebox_override("pressed", ruler_style)
	Global.vertical_ruler.add_stylebox_override("hover", ruler_style)
	Global.vertical_ruler.add_stylebox_override("focus", ruler_style)

	for button in get_tree().get_nodes_in_group("UIButtons"):
		var last_backslash = button.texture_normal.resource_path.get_base_dir().find_last("/")
		var button_category = button.texture_normal.resource_path.get_base_dir().right(last_backslash + 1)
		var normal_file_name = button.texture_normal.resource_path.get_file()
		button.texture_normal = load("res://Assets/Graphics/%s Themes/%s/%s" % [Global.theme_type, button_category, normal_file_name])
		if button.texture_pressed:
			var pressed_file_name = button.texture_pressed.resource_path.get_file()
			button.texture_pressed = load("res://Assets/Graphics/%s Themes/%s/%s" % [Global.theme_type, button_category, pressed_file_name])
		if button.texture_hover:
			var hover_file_name = button.texture_hover.resource_path.get_file()
			button.texture_hover = load("res://Assets/Graphics/%s Themes/%s/%s" % [Global.theme_type, button_category, hover_file_name])
		if button.texture_disabled:
			var disabled_file_name = button.texture_disabled.resource_path.get_file()
			button.texture_disabled = load("res://Assets/Graphics/%s Themes/%s/%s" % [Global.theme_type, button_category, disabled_file_name])

		# Make sure the frame text gets updated
		Global.current_frame = Global.current_frame

func _on_GridWidthValue_value_changed(value : float) -> void:
	Global.grid_width = value

func _on_GridHeightValue_value_changed(value : float) -> void:
	Global.grid_height = value

func _on_GridColor_color_changed(color : Color) -> void:
	Global.grid_color = color

func _on_GuideColor_color_changed(color : Color) -> void:
	Global.guide_color = color
	for canvas in Global.canvases:
		for guide in canvas.get_children():
			if guide is Guide:
				guide.default_color = color
