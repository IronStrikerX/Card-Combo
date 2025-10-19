extends Control

@onready var round_label: Label = %RoundLabel
@onready var score_label: Label = %ScoreLabel
@onready var new_cards: HBoxContainer = %NewCards
@onready var description: Label = %description
@onready var selected_slot: Control = %SelectedSlot
@onready var selected_card_name: Label = %name


var selected_card: CardUI


func _ready():
	round_label.text = "round: " + str(DeckManager.current_round) + "/10"
	score_label.text = str(DeckManager.score)
	description.text = "none"
	DeckManager.current_round += 1
	selected_slot.get_child(0).queue_free()
	for child in new_cards.get_children():
		child.queue_free()
		
	pick_cards()
	
func pick_cards():
	for i in range(5):
		var rarity: String = CardLibrary.pick_rarity()
		var card_instance: CardInstance = CardLibrary.pick_card_from_rarity(rarity)

		var card_ui = DeckManager.CARD_UI.instantiate()
		new_cards.add_child(card_ui)
		card_ui.set_up(card_instance, CardUI.Source.INVENTORY)
		card_ui.connect("select_card", Callable(self, "_on_card_selected"))
		card_ui.on_spawning_card() # optional rarity animation
		
func _on_card_selected(card_ui: CardUI) -> void:
	card_ui.is_animating = true
	var old_global_pos = card_ui.global_position 
	if card_ui.source == card_ui.Source.INVENTORY:
		if selected_card:
			deselect(selected_card)

		selected_card = card_ui
		
		if card_ui.get_parent():
			card_ui.get_parent().remove_child(card_ui)
		selected_slot.add_child(card_ui)
		
		card_ui.global_position = old_global_pos
		card_ui.source = card_ui.Source.SELECT
		
		var target_global_pos = selected_slot.global_position
		var tween = create_tween()
		tween.tween_property(card_ui, "global_position", target_global_pos, 0.3)
		tween.tween_property(card_ui, "scale", Vector2(1, 1), 0.3)
		
		description.text = card_ui.card.data.description
		selected_card_name.text = card_ui.card.data.name

	elif card_ui.source == card_ui.Source.SELECT:
		DeckManager.current_deck.append(card_ui.card)
		var tween1 = create_tween()
		tween1.tween_property(card_ui, "global_position", card_ui.global_position + Vector2(0, 25), 0.2)
		await tween1.finished
		
		# Move up while rotating side-to-side
		var tween2 = create_tween()
		tween2.parallel()
		tween2.tween_property(card_ui, "rotation_degrees", 15, 0.2)  # everything after this happens at the same time
		tween2.tween_property(card_ui, "global_position", card_ui.global_position + Vector2(0, -150), 0.2)
		

		await tween2.finished
		card_ui.queue_free()
		
	
	card_ui.is_animating = false
		
func deselect(card_ui: CardUI):
	if card_ui.get_parent():
		card_ui.get_parent().remove_child(card_ui)
		new_cards.add_child(card_ui)
		card_ui.source = card_ui.Source.INVENTORY
		description.text = ""
		selected_card_name.text = ""

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Inventory/inventory_ui.tscn")
