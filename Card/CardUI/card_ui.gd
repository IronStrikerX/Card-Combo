class_name CardUI
extends Control

enum Source {INVENTORY, SELECT, HAND}

@onready var shadow: Panel = $Shadow
@onready var card_frame: TextureRect = $CardFrame
@onready var mult_label: Label = %MultLabel
@onready var value_label: Label = %ValueLabel
@onready var gemstone_slot_1: TextureRect = %GemstoneSlot1
@onready var gemstone_slot_2: TextureRect = %GemstoneSlot2
@onready var gemstone_slot_3: TextureRect = %GemstoneSlot3
@onready var icon: TextureRect = %Icon

const COMMON_CARD = preload("uid://b81e3aiq8tlxa")
const RARE_CARD = preload("uid://cr60ywuw73lp1")
const EPIC_CARD = preload("uid://dnu53wnl1024p")
const LEGENDARY_CARD = preload("uid://c5o2potvukml2")
const MYTHIC_CARD = preload("uid://st77i6xrf7gp")

signal select_card(card_ui: CardUI)
signal right_click(card_ui: CardUI)

var card: CardInstance
var source: Source
var is_animating: bool = false

func _ready() -> void:
	pivot_offset = size / 2 
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	connect("gui_input", Callable(self, "_on_mouse_clicked"))
	
func set_up(card_instance: CardInstance, origin: Source) -> void:
	card = card_instance
	mult_label.text = str(card.mult)
	value_label.text = str(card.value)
	source = origin
	var GEM_SLOTS_BY_RARITY = {
	card.data.Rarity.COMMON: 1,
	card.data.Rarity.RARE: 1,
	card.data.Rarity.EPIC: 2,
	card.data.Rarity.LEGENDARY: 2,
	card.data.Rarity.MYTHIC: 3,
}
	for slot in [gemstone_slot_1, gemstone_slot_2, gemstone_slot_3]:
		slot.hide()
	var slot_count = GEM_SLOTS_BY_RARITY.get(card.data.rarity, 0)
	if slot_count >= 1:
		gemstone_slot_1.show()
	if slot_count >= 2:
		gemstone_slot_2.show()
	if slot_count >= 3:
		gemstone_slot_3.show()
		
	match card.data.rarity:
		card.data.Rarity.COMMON: card_frame.texture = COMMON_CARD
		card.data.Rarity.RARE: card_frame.texture = RARE_CARD
		card.data.Rarity.EPIC: card_frame.texture = EPIC_CARD
		card.data.Rarity.LEGENDARY: card_frame.texture = LEGENDARY_CARD
		card.data.Rarity.MYTHIC: card_frame.texture = MYTHIC_CARD
		
	if card.data.icon:
		icon.texture = card.data.icon
	else:
		icon.texture = null
	
func _on_mouse_entered() -> void:
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.15)

	tween.parallel().tween_property(self, "rotation_degrees", 5, 0.07)
	tween.tween_property(self, "rotation_degrees", -5, 0.07)
	tween.tween_property(self, "rotation_degrees", 0, 0.07)


func _on_mouse_exited() -> void:
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1, 1), 0.15).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func _on_mouse_clicked(event: InputEvent) -> void:
	if is_animating:
		return
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		select_card.emit(self)
		
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed and source == Source.SELECT:
		is_animating = true
		if DeckManager.in_game:
			DeckManager.discard_card(card)
			print('discard')
			print("discard")
		right_click.emit(self)

		var tween = create_tween().set_parallel(true)
		tween.tween_property(self, "scale", Vector2(0.1, 0.1), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "rotation_degrees", 1000, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		await tween.finished
		queue_free()
		
func on_spawning_card() -> void:
	is_animating = true
	icon.texture = null
	value_label.text = ""
	mult_label.text = ""
	for slot in [gemstone_slot_1, gemstone_slot_2, gemstone_slot_3]:
		slot.hide()
	scale = Vector2(0.9, 0.9)

	# Define rarity textures in order
	var rarity_textures = [
		COMMON_CARD,
		RARE_CARD,
		EPIC_CARD,
		LEGENDARY_CARD,
		MYTHIC_CARD]

	var final_rarity := card.data.rarity
	var rarity_index := int(final_rarity) 
	
	# Start from common, even if higher rarity
	for i in range(rarity_index + 1):
		card_frame.texture = rarity_textures[i]

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

		# expand then shrink
		tween.tween_property(self, "scale", Vector2(1.2 + (i * 0.15), 1.2 + (i * 0.15)), 0.15)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)

		await tween.finished
		
	set_up(card, Source.INVENTORY)
	is_animating = false
