extends Area2D

@export var move_offset = Vector2(0, -64) # Куда уезжает дверь (по умолчанию вверх на 64 пикселя)
@export var anim_time = 0.5               # Время анимации в секундах
@export_file("*.tscn") var next_level_path: String # <-- НОВОЕ: путь к следующей сцене

var is_open = false
var start_pos: Vector2

@onready var sprite = $DoorSprite
@onready var block = $DoorBlock
@onready var block_shape = $DoorBlock/BlockShape

func _ready():
	# Запоминаем начальную позицию двери
	start_pos = sprite.position
	
	# Подключаем сигналы входа и выхода игрока из зоны
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	# Если вошел игрок и дверь еще закрыта
	if body.is_in_group("player") and not is_open:
		open_door()
		
		# Ждем, пока проиграется анимация открытия
		await get_tree().create_timer(anim_time).timeout
		
		# Проверяем, что игрок всё ещё в зоне и дверь всё ещё открыта (не начал закрываться)
		if is_open: 
			if next_level_path != "":
				get_tree().change_scene_to_file(next_level_path)
			else:
				print("Ошибка: не указан путь Next Level Path в инспекторе!")

func _on_body_exited(body):
	# Если игрок вышел и дверь открыта
	if body.is_in_group("player") and is_open:
		close_door()

func open_door():
	is_open = true
	
	# Выключаем физическую преграду
	block_shape.set_deferred("disabled", true)
	
	# Создаем анимацию
	var tween = create_tween().set_parallel(true)
	# 1. Двигаем спрайт
	tween.tween_property(sprite, "position", start_pos + move_offset, anim_time)
	# 2. Делаем прозрачным (alpha = 0)
	tween.tween_property(sprite, "modulate:a", 0.0, anim_time)

func close_door():
	is_open = false
	
	# Включаем физическую преграду обратно
	block_shape.set_deferred("disabled", false)
	
	# Создаем анимацию
	var tween = create_tween().set_parallel(true)
	# 1. Возвращаем спрайт на место
	tween.tween_property(sprite, "position", start_pos, anim_time)
	# 2. Возвращаем непрозрачность
	tween.tween_property(sprite, "modulate:a", 1.0, anim_time)
