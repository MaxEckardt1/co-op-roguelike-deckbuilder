# Item and ability system with rarity levels
class_name ItemSystem
extends Node

## Item data structure
class Item:
	var id: String
	var name: String
	var rarity: String  # common, uncommon, rare, epic, legendary
	var description: String
	var attack_bonus: int = 0
	var defense_bonus: int = 0
	var health_bonus: int = 0
	var speed_bonus: int = 0
	
	func _init(p_id: String, p_name: String, p_rarity: String, p_description: String, p_attack: int = 0, p_defense: int = 0, p_health: int = 0, p_speed: int = 0):
		id = p_id
		name = p_name
		rarity = p_rarity
		description = p_description
		attack_bonus = p_attack
		defense_bonus = p_defense
		health_bonus = p_health
		speed_bonus = p_speed
	
	func get_rarity_color() -> Color:
		match rarity:
			"common": return Color.GRAY
			"uncommon": return Color.GREEN
			"rare": return Color.BLUE
			"epic": return Color.MAGENTA
			"legendary": return Color.YELLOW
		return Color.WHITE

## Ability data structure
class Ability:
	var id: String
	var name: String
	var rarity: String
	var description: String
	var damage_multiplier: float = 1.0
	var mana_cost: int = 0
	var cooldown: int = 0
	var current_cooldown: int = 0
	
	func _init(p_id: String, p_name: String, p_rarity: String, p_description: String, p_damage: float = 1.0, p_mana: int = 0, p_cooldown: int = 0):
		id = p_id
		name = p_name
		rarity = p_rarity
		description = p_description
		damage_multiplier = p_damage
		mana_cost = p_mana
		cooldown = p_cooldown
		current_cooldown = 0

## Item database
var items: Dictionary = {}

## Ability database
var abilities: Dictionary = {}

func _ready() -> void:
	_initialize_items()
	_initialize_abilities()

## Initialize all items
func _initialize_items() -> void:
	items["iron_sword"] = Item.new(
		"iron_sword",
		"Iron Sword",
		"common",
		"A basic sword for combat",
		5, 0, 0, 0
	)
	
	items["steel_armor"] = Item.new(
		"steel_armor",
		"Steel Armor",
		"uncommon",
		"Heavy armor that provides protection",
		0, 8, 0, 0
	)
	
	items["ring_of_strength"] = Item.new(
		"ring_of_strength",
		"Ring of Strength",
		"rare",
		"Increases attack power significantly",
		12, 0, 0, 0
	)
	
	items["amulet_of_vitality"] = Item.new(
		"amulet_of_vitality",
		"Amulet of Vitality",
		"epic",
		"Greatly increases max health and defense",
		0, 5, 30, 0
	)
	
	items["boots_of_speed"] = Item.new(
		"boots_of_speed",
		"Boots of Speed",
		"legendary",
		"Legendary boots that increase speed dramatically",
		0, 0, 0, 8
	)

## Initialize all abilities
func _initialize_abilities() -> void:
	abilities["power_strike"] = Ability.new(
		"power_strike",
		"Power Strike",
		"common",
		"A powerful strike dealing 1.5x damage",
		1.5, 5, 1
	)
	
	abilities["defensive_stance"] = Ability.new(
		"defensive_stance",
		"Defensive Stance",
		"uncommon",
		"Reduce incoming damage this turn",
		0.5, 10, 2
	)
	
	abilities["whirlwind_attack"] = Ability.new(
		"whirlwind_attack",
		"Whirlwind Attack",
		"rare",
		"Attack all enemies for 2x damage",
		2.0, 15, 3
	)

## Get item by ID
func get_item(item_id: String) -> Item:
	return items.get(item_id, null)

## Get ability by ID
func get_ability(ability_id: String) -> Ability:
	return abilities.get(ability_id, null)

## Get all items
func get_all_items() -> Array:
	return items.values()

## Get all abilities
func get_all_abilities() -> Array:
	return abilities.values()

## Generate random item based on rarity chance
func generate_random_item() -> Item:
	var rand = randf()
	var rarity: String
	
	if rand < 0.5:
		rarity = "common"
	elif rand < 0.75:
		rarity = "uncommon"
	elif rand < 0.9:
		rarity = "rare"
	elif rand < 0.98:
		rarity = "epic"
	else:
		rarity = "legendary"
	
	# Filter items by rarity
	var rarity_items = items.values().filter(func(item): return item.rarity == rarity)
	if rarity_items.size() > 0:
		return rarity_items[randi() % rarity_items.size()]
	
	return items["iron_sword"]
