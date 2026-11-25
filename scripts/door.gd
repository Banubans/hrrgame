extends Area2D

@export var move_offset = Vector2(0, -64)
@export var anim_time = 0.5
@export_file("*.tscn") var next_level_path: String

var is_open = false
var start_pos: Vector2
var player_in_range = false
var is_showing_message = false # Защита от спама кнопкой E

@onready var sprite = $DoorSprite
@onready var block_shape = $DoorBlock/BlockShape
@onready var message_label = $MessageLabel

func _ready():
	start_pos = sprite.position
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body):
	if body.is_in_group("player"):
		player_in_range = false
		# УБРАЛИ строку, которая прятала текст. Теперь он исчезнет сам по таймеру.

func _process(delta):
	# Если игрок рядом, дверь закрыта, он нажал E и текст сейчас не показывается
	if player_in_range and not is_open and Input.is_action_just_pressed("interact") and not is_showing_message:
		try_open_door()

func try_open_door():
	if GameState.has_key:
		open_door()
		await get_tree().create_timer(anim_time).timeout
		if next_level_path != "":
			get_tree().change_scene_to_file(next_level_path)
	else:
		show_message()

func show_message():
	is_showing_message = true # Блокируем повторное нажатие, пока идет анимация
	message_label.text = "Дверь заперта, нужен ключ"
	
	# Если текст уже был виден (например, игрок успел нажать дважды), сбрасываем прозрачность
	message_label.modulate.a = 0.0 
	
	var tween = create_tween()
	tween.tween_property(message_label, "modulate:a", 1.0, 0.2) # Появление
	tween.tween_interval(1.5)                                  # Ожидание
	tween.tween_property(message_label, "modulate:a", 0.0, 0.5) # Исчезновение
	
	# Ждем, пока анимация закончится (0.2 + 1.5 + 0.5 = 2.2 сек)
	await tween.finished
	is_showing_message = false # Разрешаем показывать текст снова

func open_door():
	is_open = true
	block_shape.set_deferred("disabled", true)
	message_label.modulate.a = 0
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(sprite, "position", start_pos + move_offset, anim_time)
	tween.tween_property(sprite, "modulate:a", 0.0, anim_time)
