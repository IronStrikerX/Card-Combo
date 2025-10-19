class_name Card
extends Resource

enum Rarity {COMMON, RARE, EPIC, LEGENDARY, MYTHIC}

# =========== @exports =============
@export var name: String = "Unnamed"
@export var extra_description: String = "" # Designer can type anything here
@export var value: int = -1
@export var mult: float = -1
@export var icon: Texture
@export var rarity: Rarity = Rarity.COMMON
@export var effect: CardEffectResource

# =========== Helper Functions ==========
var description: String:
	get:
		if effect == null:
			return "No Description" + ("\n" + extra_description if extra_description != "" else "")

		var desc := ""

		# --- Auto-generated description based on effect ---
		match effect.trigger:
			CardEffectResource.Trigger.ON_PLAY:
				desc += "Trigger: On Play\n"
			CardEffectResource.Trigger.ON_DISCARD:
				desc += "Trigger: On Discard\n"
			CardEffectResource.Trigger.ON_DRAW:
				desc += "Trigger: On Draw\n"
			CardEffectResource.Trigger.IN_DECK:
				desc += "Trigger: In Deck\n"

		match effect.type:
			CardEffectResource.Type.ADD:
				desc += "Effect: Add \n"
			CardEffectResource.Type.MULTIPLY:
				desc += "Effect: Multiply \n"
			CardEffectResource.Type.DISCARD_SIZE:
				desc += "Effect: Based on Discard Size "
			CardEffectResource.Type.AMPLIFY:
				desc += "Effect: Sum up X Rounds And Add it to Y Rounds "
			CardEffectResource.Type.PERMANENT:
				desc += "Effect: Permanently Increase \n"
		
		if effect.type != CardEffectResource.Type.DISCARD_SIZE and effect.type != CardEffectResource.Type.AMPLIFY:
			if effect.value_bonus != 0:
				desc += "Value: " + str(effect.value_bonus) + " \n"
			if effect.mult_bonus != 0:
				desc += "Mult: " + str(effect.mult_bonus) + " "

		match effect.condition:
			CardEffectResource.Condition.NONE:
				pass
			CardEffectResource.Condition.DECK_SIZE_ZERO:
				desc += "\nCondition: Deck Empty"
			CardEffectResource.Condition.AFTER_DISCARD:
				desc += "\nCondition: After Discard"
			CardEffectResource.Condition.NO_DISCARD:
				desc += "\nCondition: No Discards"
			CardEffectResource.Condition.DISCARD_DECK_SIZE_GREATER_THAN5:
				desc += "\nCondition: Discarded More Than or Equal To 5 Cards"
			CardEffectResource.Condition.PLAYED_DECK_SIZE_ZERO:
				desc += "\nCondition: Have Not Played A Card"
			CardEffectResource.Condition.AFTER_PLAY:
				desc += "\nCondition: After Playing a Card"

		if effect.duration - 1 > 0:
			desc += "\nDuration: " + str(effect.duration - 1) + " card(s)"

		# --- Append designer-specified text ---
		if extra_description != "":
			desc += "\n\n" + extra_description

		return desc
