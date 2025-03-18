class_name EscanerDePuntos
extends Node

var total_puntos: int = 0

@export var tilemap: Node
var tilemap_puntos: TileMapLayer
var tilemap_puntos_grandes: TileMapLayer

signal total_puntos_escaneados(puntos: int)

func _ready() -> void:
	
	# Establece la cantidad base de puntos a cero
	# para contar el total real
	total_puntos = 0
	
	# asociamos los TileMapLayers del Nodo Tilemap
	tilemap_puntos = tilemap.get_child(2)
	tilemap_puntos_grandes = tilemap.get_child(1)
	
	# Cuenta los puntos entre los normales y los grandes
	# en sus layers correspondientes
	escanear_tilemap(tilemap_puntos)
	escanear_tilemap(tilemap_puntos_grandes)
	
	# Emitimos la cantidad total escaneada al Game Controller
	total_puntos_escaneados.emit(total_puntos)

# Función que escanea el número de tiles activos en un TileMapLayer
# Lo usamos para contar los puntos del layer de puntos correspondiente
func escanear_tilemap(tilemapLayer: TileMapLayer):
	for tile in tilemapLayer.get_used_cells():
		total_puntos += 1
