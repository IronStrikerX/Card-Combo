extends Control
# ========== Game Info ================
@onready var description_label: Label = %DescriptionLabel
@onready var score_label: Label = %ScoreLabel
@onready var selected_slot: Control = %SelectedSlot
@onready var hand: HBoxContainer = %Hand
@onready var cards_left_label: Label = %CardsLeftLabel
@onready var selected_card_name: Label = %name
@onready var effect_icons: GridContainer = %EffectIcons
@onready var tooltip_label: Label = %Tooltip_label
@onready var panel: Panel = %Panel
@onready var buff_label: Label = %BuffLabel
# ============ Deck Info =============
@onready var grid_container_deck_info: GridContainer = %GridContainerDeckInfo
@onready var selected_slot_name: Label = %SelectedSlotName
@onready var selected_slot_deck_info: Control = %SelectedSlotDeckInfo
@onready var description_deck_info: Label = %DescriptionDeckInfo
@onready var discard_deck_size: Label = %DiscardDeckSize
@onready var deck_info: Control = %DeckInfo

var selected_card: CardUI
var score: int : set = _set_score

var effect_duration_left: int



var icon_clicked := false

func _set_score(value: int):
	score = value
	score_label.text = ("Score: " + str(score))

func _ready() -> void:
	$GameUI/MarginContainer/VBoxContainer/BottomLayer/Deck.connect("deck_info", Callable(self, "_on_deck_info_clicked"))
	DeckManager.connect("effect_triggered", Callable(self, "_on_effect_triggered"))
	DeckManager.connect("effect_subtract", Callable(self, "_duration_subtract"))
	deck_info.visible = false

	for child in selected_slot.get_children():
		child.queue_free()
	for child in hand.get_children():
		child.queue_free()
	for child in effect_icons.get_children():
		child.queue_free()

	
	DeckManager.start_round()
	DeckManager.inplay_deck.shuffle()
	DeckManager.in_deck_effect()
	for i in range(5):
		add_card_to_hand()
	update_deck_size()
	description_label.text = ""
	selected_card_name.text = ""
	score = 0

func _on_card_selected(card_ui: CardUI) -> void:
	card_ui.is_animating = true
	var old_global_pos = card_ui.global_position 
	if card_ui.source == card_ui.Source.HAND:
		if selected_card:
			deselect(selected_card)

		selected_card = card_ui
		
		if card_ui.get_parent():
			card_ui.get_parent().remove_child(card_ui)
			
		var target_global_pos
		if deck_info.visible == false:
			selected_slot.add_child(card_ui)
		
			card_ui.global_position = old_global_pos
			card_ui.source = card_ui.Source.SELECT
			
			target_global_pos = selected_slot.global_position
			description_label.text = card_ui.card.data.description
			selected_card_name.text  = card_ui.card.data.name
		else:
			selected_slot_deck_info.add_child(card_ui)
			card_ui.global_position = old_global_pos
			card_ui.source = card_ui.Source.SELECT
			
			target_global_pos = selected_slot_deck_info.global_position
			description_deck_info.text = card_ui.card.data.description
			selected_slot_name.text  = card_ui.card.data.name

		var tween = create_tween()
		tween.tween_property(card_ui, "global_position", target_global_pos, 0.2)
		tween.tween_property(card_ui, "scale", Vector2(1, 1), 0.2)
		
	elif card_ui.source == card_ui.Source.SELECT:
		if deck_info.visible == false:
			DeckManager.play_card(card_ui.card)
			# Move slightly up first
			var tween1 = create_tween()
			tween1.tween_property(card_ui, "global_position", card_ui.global_position + Vector2(0, 25), 0.1)
			await tween1.finished
			
			# Move up while rotating side-to-side
			var tween2 = create_tween()
			tween2.parallel()
			tween2.tween_property(card_ui, "rotation_degrees", 15, 0.1)  # everything after this happens at the same time
			tween2.tween_property(card_ui, "global_position", card_ui.global_position + Vector2(0, -150), 0.1)

			await tween2.finished
			score += DeckManager.apply_score(card_ui.card)
			add_card_to_hand()
			DeckManager.in_deck_effect(false)
			update_deck_size()
			update_buff_label()
			card_ui.queue_free()
		else:
			if card_ui.get_parent():
				card_ui.get_parent().remove_child(card_ui)
				grid_container_deck_info.add_child(card_ui)
				card_ui.source = card_ui.Source.HAND
				description_label.text = ""
			
	card_ui.is_animating = false

func deselect(card_ui: CardUI):
	if card_ui.get_parent():
		card_ui.get_parent().remove_child(card_ui)
		if deck_info.visible == false:
			hand.add_child(card_ui)
		else:
			grid_container_deck_info.add_child(card_ui)
		card_ui.source = card_ui.Source.HAND
		description_label.text = ""

func add_card_to_hand():
	var new_card = DeckManager.draw_card()
	if new_card:
		var card_ui = DeckManager.CARD_UI.instantiate()
		hand.add_child(card_ui)
		card_ui.set_up(new_card, card_ui.Source.HAND)
		card_ui.connect("select_card", Callable(self, "_on_card_selected"))
		card_ui.connect("right_click", Callable(self, "_on_card_discard"))

func _on_card_discard(_card_ui: CardUI):
	add_card_to_hand()
	DeckManager.in_deck_effect(false)
	update_deck_size()
	update_buff_label()

func update_deck_size():
	cards_left_label.text = str(DeckManager.inplay_deck.size())
	if DeckManager.inplay_deck.size() == 0 and hand.get_child_count() == 0:
		DeckManager.in_game = false
		DeckManager.score += score
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://Scenes/loot.tscn")

func _on_deck_info_clicked():
	deck_info.visible = true
	discard_deck_size.text = "D: %s\nP: %s" % [str(DeckManager.discard_deck.size()), str(DeckManager.played_deck.size())]
	var shuffled_in_play_cards = DeckManager.inplay_deck.duplicate()
	shuffled_in_play_cards.shuffle()
	for card_instance in shuffled_in_play_cards:
		var card_ui = DeckManager.CARD_UI.instantiate()
		grid_container_deck_info.add_child(card_ui)
		card_ui.set_up(card_instance, card_ui.Source.HAND)
		card_ui.connect("select_card", Callable(self, "_on_card_selected"))
	
func update_buff_label():
	buff_label.text = "power: +%s | boost: +%s\nx%s | x%s" % [DeckManager.next_card_add[0][0], DeckManager.next_card_add[0][1], DeckManager.next_card_mult[0][0], DeckManager.next_card_mult[0][1]]

func _on_effect_triggered(card: Card) -> void:
	if card.icon == null:
		return

	# Create wrapper
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(16, 16)
	effect_icons.add_child(wrapper)

	# Create icon inside wrapper
	var icon_sprite = TextureRect.new()
	icon_sprite.texture = card.icon
	icon_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon_sprite.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	icon_sprite.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	icon_sprite.scale = Vector2(0, 0) # start tiny
	wrapper.add_child(icon_sprite)

	# Connect using the icon (pass *data* only, not nodes that might be freed elsewhere)
	icon_sprite.connect("mouse_entered", Callable(self, "_on_icon_hovered").bind(icon_sprite, card))
	icon_sprite.connect("mouse_exited", Callable(self, "_on_icon_exited"))
	icon_sprite.connect("gui_input", Callable(self, "_on_gui_input"))

	# store the wrapper & icon (store the icon node for lookups)
	var entry := {
		"effect": card.effect,
		"icon": icon_sprite,
		"wrapper": wrapper,
		"remaining_duration": card.effect.duration
	}
	DeckManager.active_effects.append(entry)

	# Animate the scale to appear — keep a reference to the tween in the wrapper so we can kill it later if needed
	var tween := create_tween()
	wrapper.set_meta("in_icon_tween", tween) # store reference, optional
	tween.tween_property(icon_sprite, "scale", Vector2(1, 1), 0.2).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)




func _on_icon_hovered(icon_sprite: TextureRect, card: Card):
	# Find the active effect entry that corresponds to this icon
	var remaining_duration = ""
	for entry in DeckManager.active_effects:
		if entry["icon"] == icon_sprite:
			remaining_duration = str(entry["remaining_duration"])
			break

	tooltip_label.text = "%s\n%s\nDuration: %s" % [card.name, card.description, remaining_duration]

	if not icon_clicked:
		panel.scale = Vector2(0, 0)  # start small
		var tween2 = panel.create_tween()
		tween2.tween_property(panel, "scale", Vector2(1, 1), 0.1)
	
	panel.visible = true

func _on_icon_exited():
	if not icon_clicked:
		panel.visible = false
	
func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if icon_clicked:
			icon_clicked = false
			panel.visible = false
		else:
			icon_clicked = true
			
		

func _duration_subtract() -> void:
	var expired: Array = []

	for entry in DeckManager.active_effects:
		# Defensive: ensure the entry is valid structure
		if not entry.has("remaining_duration"):
			continue

		entry["remaining_duration"] -= 1

		# If wrapper no longer exists, mark for removal
		if not is_instance_valid(entry.get("wrapper")):
			expired.append(entry)
			continue

		if entry["remaining_duration"] <= 0:
			expired.append(entry)
		else:
			# safe small wiggle animation — ensure wrapper exists
			var wrapper = entry["wrapper"]
			if is_instance_valid(wrapper):
				# If there is a tween stored on the wrapper, kill it before making a new one
				if wrapper.has_meta("in_icon_tween"):
					var old_tween = wrapper.get_meta("in_icon_tween")
					if is_instance_valid(old_tween):
						old_tween.kill()
					wrapper.set_meta("in_icon_tween", null)

				var tween = create_tween()
				wrapper.set_meta("in_icon_tween", tween)
				tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
				tween.parallel().tween_property(wrapper, "rotation_degrees", 5, 0.07)
				tween.tween_property(wrapper, "rotation_degrees", -5, 0.07)
				tween.tween_property(wrapper, "rotation_degrees", 0, 0.07)

	# Clean up expired effects (deferred free)
	for e in expired:
		# stop any active tweens safely
		var w = e.get("wrapper")
		if is_instance_valid(w):
			if w.has_meta("in_icon_tween"):
				var t = w.get_meta("in_icon_tween")
				if is_instance_valid(t):
					t.kill()
			# Use deferred free (safer inside signal handlers)
			w.call_deferred("queue_free")
		DeckManager.active_effects.erase(e)


func _on_play_button_pressed() -> void:
	await get_tree().create_timer(0.15).timeout
	for child in grid_container_deck_info.get_children():
		child.queue_free()
	for child in selected_slot_deck_info.get_children():
		child.queue_free()
	deck_info.visible = false
