# Base character class for all units (players, allies, enemies)
class_name Character
extends Node2D

## Character stats
var max_health: int = 100
var current_health: int = 100
var attack: int = 10
var defense: int = 5
var speed: int = 10

## Inventory
var items: Array[String] = []
var abilities: Array[String] = []
var current_ability: String = ""

## State
var is_alive: bool = true
var current_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	current_health = max_health

## Take damage with defense calculation
func take_damage(damage: int) -> void:
	var actual_damage = max(1, damage - defense)
	current_health -= actual_damage
	
	if current_health <= 0:
		current_health = 0
		is_alive = false

## Heal character
func heal(amount: int) -> void:
	current_health = min(max_health, current_health + amount)

## Add item to inventory
func add_item(item_id: String) -> void:
	items.append(item_id)

## Add ability to character
func add_ability(ability_id: String) -> void:
	abilities.append(ability_id)

## Perform an action (attack, ability, etc)
func perform_action(target: Character, action_type: String) -> int:
	if action_type == "attack":
		return perform_attack(target)
	elif action_type in abilities:
		return perform_ability(target, action_type)
	return 0

## Basic attack
func perform_attack(target: Character) -> int:
	var damage = attack + randi() % 5  # Add some variance
	target.take_damage(damage)
	return damage

## Perform ability action
func perform_ability(target: Character, ability_id: String) -> int:
	# TODO: Implement ability system with effects
	var damage = attack * 2
	target.take_damage(damage)
	return damage

## Get character info
func get_info() -> Dictionary:
	return {
		"health": current_health,
		"max_health": max_health,
		"attack": attack,
		"defense": defense,
		"speed": speed,
		"is_alive": is_alive,
		"items": items,
		"abilities": abilities
	}
