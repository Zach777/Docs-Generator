tool
extends Popup

signal popup_closed()


func _ready() -> void :
	popup()

func _on_Button_pressed():
	emit_signal("popup_closed")
