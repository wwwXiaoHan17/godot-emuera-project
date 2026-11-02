extends Control

@onready var grid_container: GridContainer = $GridContainer

func _ready() -> void:
	var label: Label = Label.new()
	label.text = "123"
	grid_container.add_child(label)
	label.size_flags_horizontal = Control.SIZE_EXPAND
	
