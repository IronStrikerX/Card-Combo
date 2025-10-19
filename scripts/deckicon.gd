extends Control

signal deck_info()

func _ready() -> void:
	connect("gui_input", Callable(self, "_on_mouse_clicked"))
	
func _on_mouse_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		emit_signal("deck_info")
		DeckManager.show_current_buffs()
		
