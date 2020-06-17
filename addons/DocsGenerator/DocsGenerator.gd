tool
extends EditorPlugin

#Get a packed scene for the scene we will use.
var scene = preload("res://addons/DocsGenerator/MainScene.tscn")
var current_popup : Popup = null


func _enter_tree():
	add_tool_menu_item("Docs Generator", self, "pressed")

func _exit_tree():
	remove_tool_menu_item("Docs Generator")
	if current_popup != null :
		current_popup.queue_free()

func pressed(_ud) -> void :
	current_popup = scene.instance()
	get_editor_interface().get_viewport().add_child(current_popup)
	current_popup.connect("popup_closed", self, "_exit_tree")
	current_popup.show()
