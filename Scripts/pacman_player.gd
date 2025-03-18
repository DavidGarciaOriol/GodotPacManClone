class_name PacmanPlayer
extends CharacterBody2D

# Físicas
@export var velocidad: float = 100.0 # Velocidad de Pac Man
var direccion: Vector2 = Vector2.ZERO # Dirección del movimiento

# Pickups
@export var tilemap: Node
var tilemap_puntos: TileMapLayer
var tilemap_puntos_grandes: TileMapLayer

# Posición inicial
var posicion_inicial: Vector2

# Señales
signal vida_perdida # cuando es alcanzado por un fantasma
signal sumar_puntos(cantidad: int) # cuando recoge puntos

func _ready() -> void:
	posicion_inicial = global_position
	tilemap_puntos = tilemap.get_child(2)
	tilemap_puntos_grandes = tilemap.get_child(1)

# Invencibilidad por punto grande
var efecto_punto_grande_activo: bool = false

# Recibe los controles de movimiento.
func recibir_input():
	direccion = Vector2.ZERO
	
	if Input.is_action_pressed("dpad_right"):
		direccion = Vector2.RIGHT
	elif Input.is_action_pressed("dpad_left"):
		direccion = Vector2.LEFT
	elif Input.is_action_pressed("dpad_up"):
		direccion = Vector2.UP
	elif Input.is_action_pressed("dpad_down"):
		direccion = Vector2.DOWN
		
	velocity = direccion * velocidad

# Rotación del sprite.
func rotar_sprite():
	if direccion != Vector2.ZERO:
		var angulo = direccion.angle()
		$AnimatedSprite2D.rotation = angulo  # Gira el sprite hacia la dirección del movimiento

# Control de la animación
func manejar_animacion():
	if direccion != Vector2.ZERO:
		$AnimatedSprite2D.play("moverse")
	else:
		$AnimatedSprite2D.stop()

func comprobar_pickups_suelo():
	var grid_pos_puntos = tilemap_puntos.local_to_map(global_position)
	var grid_pos_puntos_grandes = tilemap_puntos_grandes.local_to_map(global_position)

	# Comprobar si hay un punto en la capa correspondiente
	if tilemap_puntos.get_cell_source_id(grid_pos_puntos) != -1:
		sumar_puntos.emit(10)
		tilemap_puntos.erase_cell(grid_pos_puntos)  # Borra el punto

	# Comprobar si hay punto grande en la capa correspondiente
	if tilemap_puntos_grandes.get_cell_source_id(grid_pos_puntos_grandes) != -1:
		sumar_puntos.emit(50)
		tilemap_puntos_grandes.erase_cell(grid_pos_puntos_grandes)  # Borra el punto grande

		efecto_punto_grande_activo = true
		
		# Avisar a todos los fantasmas de que deben huir
		for fantasma in get_tree().get_nodes_in_group("fantasmas"):
			fantasma.cambiar_estado(fantasma.EstadoFantasma.Huyendo)

		# Iniciar el temporizador de invencibilidad
		$Timer.start()

# Perder una vida
func perder_vida():
	# Enviamos la señal al Game Controller
	vida_perdida.emit()
	
	# Ocultamos temporalmente a pacman
	hide()

# Efectúa acciones
func _process(delta: float) -> void:
	recibir_input()
	move_and_slide()
	rotar_sprite()
	manejar_animacion()
	comprobar_pickups_suelo()

func _on_timer_timeout() -> void:
	print("El punto grande ha terminado. Los fantasmas vuelven a perseguir.")
	for fantasma in get_tree().get_nodes_in_group("fantasmas"):
		efecto_punto_grande_activo = false
		fantasma.cambiar_modo_perseguir()
