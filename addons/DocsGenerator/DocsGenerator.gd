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
		remove_popup()

func pressed(_ud) -> void :
	current_popup = scene.instance()
	get_editor_interface().get_viewport().add_child(current_popup)
	current_popup.connect("popup_closed", self, "remove_popup")
	current_popup.show()

func remove_popup() -> void :
	current_popup.queue_free()
	current_popup = null
