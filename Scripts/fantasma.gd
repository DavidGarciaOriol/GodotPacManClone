class_name Fantasma
extends CharacterBody2D

# Movimiento
@export var velocidad: float = 50.0 # Velocidad

# Inteligencia Artificial
var posicion_jugador: Vector2 # Posición del jugador
var posicion_inicial: Vector2 # Posición de inicio y retorno del fantasma

# Sprite y shading
@onready var sprite = $Sprite2D
@onready var shader_material = preload("res://shaders/negative_ghosts.gdshader")

# Agente de navegación
@onready var agente_navegacion = $NavigationAgent2D

# Puntuación interna
var puntos_otorgables: int = 200

# Estados
enum EstadoFantasma {
	Persiguiendo,
	Dispersion,
	Huyendo,
	Retornando
}

# Estado inicial
var estado_actual = EstadoFantasma.Persiguiendo

func _ready() -> void:
	# La posición inicial se guarda para el retorno
	posicion_inicial = global_position

func _physics_process(delta: float) -> void:
	match estado_actual:
		EstadoFantasma.Persiguiendo:
			perseguir_jugador()
			
			# Quitamos el shader
			sprite.material = null  
		
		EstadoFantasma.Dispersion:
			dispersarse()
			# No implementado realmente
		
		EstadoFantasma.Huyendo:
			huir_del_jugador()
			
			# Aplicamos el shader
			sprite.material = ShaderMaterial.new()
			sprite.material.shader = shader_material
			
		EstadoFantasma.Retornando:
			retornar_al_inicio()
			
			# Quitamos el shader
			sprite.material = null  
			
	move_and_slide()
	gestionar_colision()

func gestionar_colision():
	for i in range(get_slide_collision_count()):  # Iteramos sobre todas las colisiones del frame
		var colision = get_slide_collision(i)
		var objeto = colision.get_collider()

		if objeto is PacmanPlayer:
			if objeto.estado_actual == objeto.EstadosPacman.Invencible:
				cambiar_modo_retorno()
				objeto.sumar_puntos.emit(puntos_otorgables)  # Usa el signal en lugar de llamar directamente
			else:
				objeto.perder_vida()

# Estado convencional de la IA de los fantasmas
func perseguir_jugador():
	if posicion_jugador:
		agente_navegacion.target_position = posicion_jugador # Direcciona al fantasma hacia el jugador
		var direccion = agente_navegacion.get_next_path_position() - global_position
		if direccion.length() > 1:
			velocity = direccion.normalized() * velocidad
		else:
			velocity = Vector2.ZERO

func dispersarse():
	# TODO - Se desplazan a las esquinas del mapa
	# No sé cómo agregar esta función a nivel de diseño
	# ni cuánto se supone que están dispersándose, o cuándo hacerlo
	# por lo que la dejo como planteada y ya.
	
	# Tras un tiempo, vuelve a modo perseguir
	cambiar_modo_perseguir()
	
# Cuando el jugador coge un punto grande, durante la duración de su efecto
func huir_del_jugador():
	if posicion_jugador:
		var direccion_huida = (global_position - posicion_jugador).normalized()
		agente_navegacion.target_position = global_position + direccion_huida * 100  # Se mueve lejos
		velocity = direccion_huida * velocidad * 0.8  # Disminuye un poco la velocidad

# Si el fantasma es alcanzado por el jugador durante la duración del punto grande
func retornar_al_inicio():
	agente_navegacion.target_position = posicion_inicial
	var direccion = agente_navegacion.get_next_path_position() - global_position
	if direccion.length() > 1:
		velocity = direccion.normalized() * velocidad * 3  # Retorno más rápido
		sprite.modulate.a = 0.3  # Hacer el sprite semi-transparente
	else:
		sprite.modulate.a = 1.0  # Restaurar visibilidad
		cambiar_modo_perseguir()  # Al llegar, vuelve a la normalidad

func cambiar_modo_perseguir():
	cambiar_estado(EstadoFantasma.Persiguiendo)

func cambiar_modo_dispersion():
	cambiar_estado(EstadoFantasma.Dispersion)

func cambiar_modo_huir():
	cambiar_estado(EstadoFantasma.Huyendo)

func cambiar_modo_retorno():
	cambiar_estado(EstadoFantasma.Retornando)

# Función para cambiar el estado del fantasma
func cambiar_estado(nuevo_estado):
	estado_actual = nuevo_estado

# Comprueba cada poco tiempo la posición del jugador
func _on_timer_timeout() -> void:
	var jugador = get_node_or_null("/root/Node2D/PacmanPlayer")
	if jugador:
		posicion_jugador = jugador.global_position
		$NavigationAgent2D.target_position = posicion_jugador
