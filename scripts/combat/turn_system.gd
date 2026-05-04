# Turn system - manages turn order and combat flow
class_name TurnSystem
extends Node

## Combat participants
var all_characters: Array[Character] = []
var turn_order: Array[Character] = []
var current_turn_index: int = 0

## Signals
signal turn_started(character: Character)
signal turn_ended(character: Character)
signal combat_round_ended

func _ready() -> void:
	pass

## Initialize turn order based on character speed
func initialize_turn_order(player1_team: Array[Character], player2_team: Array[Character], enemies: Array[Character]) -> void:
	all_characters.clear()
	
	# Combine all characters
	all_characters.append_array(player1_team)
	all_characters.append_array(player2_team)
	all_characters.append_array(enemies)
	
	# Filter only alive characters
	var alive_chars: Array[Character] = []
	for char in all_characters:
		if char.is_alive:
			alive_chars.append(char)
	
	# Sort by speed (highest speed goes first)
	alive_chars.sort_custom(func(a, b): return a.speed > b.speed)
	turn_order = alive_chars
	current_turn_index = 0

## Get current character's turn
func get_current_character() -> Character:
	if turn_order.size() == 0:
		return null
	return turn_order[current_turn_index]

## End current turn and move to next
func end_turn() -> void:
	if turn_order.size() == 0:
		return
	
	var current_char = get_current_character()
	turn_ended.emit(current_char)
	
	# Move to next character
	current_turn_index += 1
	
	# Check if round is complete
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
		combat_round_ended.emit()
	
	# Skip dead characters
	while current_turn_index < turn_order.size() and not turn_order[current_turn_index].is_alive:
		current_turn_index += 1
	
	# If we've gone past all characters, reset
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
		combat_round_ended.emit()
	
	# Start new turn
	if turn_order.size() > 0:
		var next_char = get_current_character()
		if next_char and next_char.is_alive:
			turn_started.emit(next_char)

## Get all characters' turn order info
func get_turn_order_info() -> Array[Dictionary]:
	var info: Array[Dictionary] = []
	for i in range(turn_order.size()):
		var char = turn_order[i]
		info.append({
			"index": i,
			"is_current": i == current_turn_index,
			"health": char.current_health,
			"max_health": char.max_health,
			"speed": char.speed,
			"is_alive": char.is_alive
		})
	return info

## Refresh turn order (call after characters die)
func refresh_turn_order() -> void:
	# Remove dead characters
	turn_order = turn_order.filter(func(char): return char.is_alive)
	
	# Reset index if needed
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
	
	# Re-sort by speed
	turn_order.sort_custom(func(a, b): return a.speed > b.speed)
