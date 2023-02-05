extends WorldEnvironment

func _process(delta):
	environment.sky_rotation.y += 0.00005

func _ready():
	$"../Control".player = $"../Player"
