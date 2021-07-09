tool
extends GridMap


var ground = 10
var bumpiness = 5.0
var done = false
var e = 2.7182818284

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
	clear()
	var start = world_to_map(get_node("AreaStart").translation)
	var end = world_to_map(get_node("AreaEnd").translation)
	var step = 0
	var minM = 0
	var maxM = 0
	for x in range(start.x, end.x):
		for y in range(start.y, end.y):
			for z in range(start.z, end.z):
				if step == 400000:
					print(step)
					return
				step+=1
				var noiseHere = noise.get_noise_3d(x,y,z)
				if noiseHere-sigmoid((y-ground)/bumpiness) > 0:
					if noiseHere>maxM:
						maxM = noiseHere
					if noiseHere<minM:
						minM = noiseHere
					set_cell_item(x, y, z, 0)
					#we can't use GridMap, it crashes when above 40,000 cubes
					pass
	print(maxM)
	print(minM)

func sigmoid(x):
	return (1 / (1+pow(e, -x)) - 0.5)
