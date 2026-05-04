# Global game manager - handles game state and team initialization
extends Node

## Player teams
var player1_team: Array[Character] = []
var player2_team: Array[Character] = []
var current_enemies: Array[Character] = []

## Game state
var current_scene: String = "map"
var combat_active: bool = false
var current_round: int = 0

func _ready() -> void:
	# Initialize teams with default characters
	_initialize_teams()

## Initialize both player teams
func _initialize_teams() -> void:
	player1_team.clear()
	player2_team.clear()
	
	# Player 1 - Team A
	var p1_char1 = Character.new()
	p1_char1.max_health = 100
	p1_char1.current_health = 100
	p1_char1.attack = 12
	p1_char1.defense = 5
	p1_char1.speed = 10
	player1_team.append(p1_char1)
	
	var p1_char2 = Character.new()
	p1_char2.max_health = 80
	p1_char2.current_health = 80
	p1_char2.attack = 15
	p1_char2.defense = 3
	p1_char2.speed = 12
	player1_team.append(p1_char2)
	
	# Player 2 - Team B
	var p2_char1 = Character.new()
	p2_char1.max_health = 100
	p2_char1.current_health = 100
	p2_char1.attack = 12
	p2_char1.defense = 5
	p2_char1.speed = 10
	player2_team.append(p2_char1)
	
	var p2_char2 = Character.new()
	p2_char2.max_health = 80
	p2_char2.current_health = 80
	p2_char2.attack = 15
	p2_char2.defense = 3
	p2_char2.speed = 12
	player2_team.append(p2_char2)

## Initialize enemies for combat
func initialize_enemies(enemy_count: int = 3) -> void:
	current_enemies.clear()
	
	for i in range(enemy_count):
		var enemy = Character.new()
		enemy.max_health = 50 + randi() % 30
		enemy.current_health = enemy.max_health
		enemy.attack = 8 + randi() % 4
		enemy.defense = 2
		enemy.speed = 7 + randi() % 4
		current_enemies.append(enemy)

## Get all alive characters from a team
func get_alive_characters(team: Array[Character]) -> Array[Character]:
	var alive: Array[Character] = []
	for char in team:
		if char.is_alive:
			alive.append(char)
	return alive

## Check if a team has any alive characters
func is_team_alive(team: Array[Character]) -> bool:
	return get_alive_characters(team).size() > 0

## Start combat
func start_combat() -> void:
	combat_active = true
	current_round = 0
	initialize_enemies()

## End combat
func end_combat() -> void:
	combat_active = false
