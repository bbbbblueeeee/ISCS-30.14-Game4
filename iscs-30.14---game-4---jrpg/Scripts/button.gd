# THIS CODE IS PROBABLY USELESS LOL


extends Button


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	focus_entered.connect(_on_focus_entered())
	focus_exited.connect(_on_focus_exited())


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if focus_entered:
		disabled=false
	if focus_exited:
		disabled=true

func _on_focus_entered():
	disabled=false

func _on_focus_exited():
	disabled=true
