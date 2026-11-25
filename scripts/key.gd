extends Area2D

var player_in_range = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false

func _process(delta):
	# Если игрок рядом и нажал E
	if player_in_range and Input.is_action_just_pressed("interact"):
		GameState.has_key = true
		queue_free() 
