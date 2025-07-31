extends HSlider

@export var bus_name: String
var fmod_bus: FmodBus

func _ready():
	fmod_bus = FmodServer.get_bus(bus_name)
	if fmod_bus == null: 
		print("Bus " + bus_name + " couldn't be found")
		return
	value_changed.connect(_on_value_changed)
	
	value = fmod_bus.volume
 
func _on_value_changed(new_value: float) -> void:
	if fmod_bus != null: fmod_bus.volume = new_value
