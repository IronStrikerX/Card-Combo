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

		match effect.trigger:
			CardEffectResource.Trigger.ON_PLAY:
				desc += "Trigger: On Play.\n"
			CardEffectResource.Trigger.ON_DISCARD:
				desc += "Trigger: On Discard.\n"
			CardEffectResource.Trigger.ON_DRAW:
				desc += "Trigger: When Drawn.\n"
			CardEffectResource.Trigger.IN_DECK:
				desc += "Trigger: While in Deck.\n"
			CardEffectResource.Trigger.IN_PLAYED_DECK:
				desc += "Trigger: Persistent After Play.\n"


		match effect.type:
			CardEffectResource.Type.ADD:
				desc += "Effect: Increases:\n"
			CardEffectResource.Type.MULTIPLY:
				desc += "Effect: Multiplies: \n"
			CardEffectResource.Type.DISCARD_SIZE:
				desc += "Effect: Gain extra X Power and Boost for Each Discard\n"
			CardEffectResource.Type.AMPLIFY:
				desc += "Effect: Adds the combined Power and Boost from upcoming X turns to the next Y rounds.\n"
			CardEffectResource.Type.PERMANENT:
				desc += "Effect: Permanently increase: \n"
			CardEffectResource.Type.EFFECT_SIZE:
				desc += "Effect: Adds X Power and Boost depending on how many active effects are in play.\n"
			CardEffectResource.Type.EFFECT_SIZE_MULT:
				desc += "Effect: Multiplies X Power and Boost based on the number of active effects.\n"
			CardEffectResource.Type.AMPLIFY_MULT:
				desc += "Effect: Collects the future X rounds total Power and Boost, then multiplies it across next Y turns.\n"
			CardEffectResource.Type.DUPLICATE_CARDS:
				desc += "Effect: Creates duplicates of X random cards (excluding cards with this same effect).\n"
			CardEffectResource.Type.MAX_DECK_SIZE_ADD:
				desc += "Effect: Permanently increases your maximum deck size by +1.\n"


		if effect.type == CardEffectResource.Type.ADD or effect.type == CardEffectResource.Type.MULTIPLY or effect.type == CardEffectResource.Type.PERMANENT:
			if effect.value_bonus != 0:
				desc += "Power: " + str(effect.value_bonus + (1 if effect.type == CardEffectResource.Type.MULTIPLY else 0)) + " \n"
			if effect.mult_bonus != 0:
				desc += "Boost: " + str(effect.mult_bonus + (1 if effect.type == CardEffectResource.Type.MULTIPLY else 0)) + " "

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
			CardEffectResource.Condition.DECK_SIZE_NOT_ZERO:
				desc += "\nCondition: Deck Size is Not Empty"

		if effect.duration - 1 > 0:
			desc += "\nDuration: " + str(effect.duration - 1) + " card(s)"
		elif effect.type != CardEffectResource.Type.DUPLICATE_CARDS:
			desc += "\nEffect Applies to Current Card"

		# --- Append designer-specified text ---
		if extra_description != "":
			desc += "\n\n" + extra_description

		return desc
