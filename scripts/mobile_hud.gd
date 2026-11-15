extends CanvasLayer

func _ready() -> void:
    _add_title()
    _add_controls()

func _add_title() -> void:
    var title := Label.new()
    title.text = "PHILIPPINES LIFE  •  OPEN WORLD"
    title.position = Vector2(22, 18)
    title.add_theme_font_size_override("font_size", 24)
    title.add_theme_color_override("font_color", Color(1, 1, 1))
    add_child(title)

    var hint := Label.new()
    hint.text = "Prototype 0.1  |  Starter Town"
    hint.position = Vector2(24, 52)
    hint.add_theme_font_size_override("font_size", 15)
    hint.add_theme_color_override("font_color", Color(0.9, 0.95, 1))
    add_child(hint)

func _add_controls() -> void:
    _make_button("▲", Vector2(110, -150), "move_forward")
    _make_button("▼", Vector2(110, -45), "move_back")
    _make_button("◀", Vector2(55, -95), "move_left")
    _make_button("▶", Vector2(165, -95), "move_right")
    _make_button("JUMP", Vector2(-115, -85), "jump")

func _make_button(caption: String, offset: Vector2, action: String) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(76, 66) if caption != "JUMP" else Vector2(92, 66)
    button.anchor_left = 1.0 if offset.x < 0 else 0.0
    button.anchor_right = 1.0 if offset.x < 0 else 0.0
    button.anchor_top = 1.0
    button.anchor_bottom = 1.0
    button.position = offset - Vector2(button.custom_minimum_size.x, button.custom_minimum_size.y) / 2.0
    button.add_theme_font_size_override("font_size", 20)
    button.modulate = Color(1, 1, 1, 0.82)
    button.button_down.connect(func(): Input.action_press(action))
    button.button_up.connect(func(): Input.action_release(action))
    add_child(button)
