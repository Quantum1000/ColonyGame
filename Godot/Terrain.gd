
extends Spatial


var ground = 10
var bumpiness = 5.0
var done = false
var e = 2.7182818284
var terrainGrid = []
var height = 0
var width = 0
var length = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !done:
		generate()
		done = true


func generate():
	var noise = OpenSimplexNoise.new()
	noise.seed = 1236
	noise.octaves = 4
	noise.period = 40.0
	noise.persistence = 0.8
	var start = get_node("AreaStart").translation
	var end = get_node("AreaEnd").translation
	#TODO: decouple world size from tile size
	height = int(abs(start.y-end.y))
	width = int(abs(start.x-end.x))
	length = int(abs(start.z-end.z))
	terrainGrid.resize(height)
	for i in terrainGrid:
		i = Image.new().create(width,length,false,Image.FORMAT_R8)
	var step = 0
	for y in range(start.y, end.y):
		#insert multithreading here?
		for x in range(start.x, end.x):
			for z in range(start.z, end.z):
				if step == 400000:
					print(step)
					return
				step+=1
				var noiseHere = noise.get_noise_3d(abs(x-start.x),abs(y-start.y),abs(z-start.z))
				setGridCell(x, y, z, noiseHere-sigmoid((y-ground)/bumpiness), terrainGrid)
	for y in range(start.y,end.y):
		for x in range(start.x, end.x):
			for z in range(start.z, end.z):
				if(getGridCell(x, y, z, terrainGrid) > 0):
					#Then there is terrain in this 3d pixel
					#In that case, check in each direction for whether or not there is terrain
					#If there is no terrain in a direction 
					pass

func setGridCell(x, y, z, val, grid):
	grid[y].set_pixel(x, z, Color(int(clamp(val+1,-1,1)*128),0,0))

func getGridCell(x, y, z, grid):
	if 0<x and x<width and 0<y and y<height and 0<z and z<length:
		return grid[y].get_pixel(x, z).r8/128.0-1.0
	else:
		return -1.0


func sigmoid(x):
	return (1 / (1+pow(e, -x)) - 0.5)

