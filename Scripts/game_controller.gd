extends Node

# Máquina de estados de partida
enum EstadosPartida{
	PartidaEnCurso,
	Pausa,
	Victoria,
	GameOver
}

# Estado inicial por defecto de la partida
var estado_actual: EstadosPartida = EstadosPartida.PartidaEnCurso

# Vidas del jugador
@export var vidas: int = 3

# Label vidas
@export var label_vidas: Label

# Puntuación del jugador
var puntuacion: int = 0

# Label puntuación
@export var label_puntuacion: Label

# Cantidad de objetos punto y puntos grandes recogidos por el jugador
var numero_puntos_recogidos: int = 0

# Total de puntos y puntos grandes del nivel
var numero_maximo_puntos_nivel: int = 20

@export var pacman: CharacterBody2D
@export var fantasma_amarillo: CharacterBody2D
@export var fantasma_azul: CharacterBody2D
@export var fantasma_rojo: CharacterBody2D
@export var fantasma_rosa: CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func sumar_puntos(cantidad: int):
	puntuacion += cantidad
	numero_puntos_recogidos += 1
	modificar_display_puntuacion()
	comprueba_victoria()

func modificar_display_puntuacion():
	if label_puntuacion:
		label_puntuacion.text = "Puntos: " + str(puntuacion)

func comprueba_victoria():
	if numero_puntos_recogidos >= numero_maximo_puntos_nivel:
		victoria()

func victoria():
	pass

func perder_vida():
	if vidas >= 0:
		vidas -= 1
		modificar_display_vidas()
		comprueba_game_over()

func modificar_display_vidas():
	if label_vidas:
		label_vidas.text = "Vidas: " + str(vidas)

func comprueba_game_over():
	if vidas <= 0:
		game_over()

func game_over():
	pass
