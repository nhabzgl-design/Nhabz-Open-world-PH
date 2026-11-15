extends CanvasLayer

const SAVE_PATH := "user://philippines_life_profile.cfg"
var data := ConfigFile.new()
var email_input: LineEdit
var password_input: LineEdit
var username_input: LineEdit
var character_name_input: LineEdit
var skin_picker: OptionButton
var hair_picker: OptionButton
var outfit_picker: OptionButton
var status_label: Label
var content: VBoxContainer

func _ready() -> void:
    layer = 20
    _build_shell()
    var err := data.load(SAVE_PATH)
    if err == OK and data.get_value("account", "email", "") != "":
        _show_login()
    else:
        _show_register()

func _build_shell() -> void:
    var backdrop := ColorRect.new()
    backdrop.color = Color(0.035, 0.055, 0.085, 0.97)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)

    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(320, 500)
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.08, 0.11, 0.16, 1)
    style.set_corner_radius_all(22)
    style.set_content_margin_all(22)
    panel.add_theme_stylebox_override("panel", style)
    center.add_child(panel)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.add_child(scroll)
    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 12)
    scroll.add_child(content)

func _clear_content() -> void:
    for child in content.get_children():
        child.queue_free()
    status_label = null

func _heading(subtitle: String) -> void:
    var title := Label.new()
    title.text = "PHILIPPINES LIFE"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    title.add_theme_font_size_override("font_size", 25)
    title.add_theme_color_override("font_color", Color(0.35, 0.82, 0.98))
    content.add_child(title)
    var sub := Label.new()
    sub.text = subtitle
    sub.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    sub.add_theme_font_size_override("font_size", 18)
    sub.add_theme_color_override("font_color", Color.WHITE)
    content.add_child(sub)

func _field(caption: String, hint: String, secret := false) -> LineEdit:
    var label := Label.new()
    label.text = caption
    label.add_theme_color_override("font_color", Color(0.83, 0.88, 0.95))
    content.add_child(label)
    var field := LineEdit.new()
    field.placeholder_text = hint
    field.secret = secret
    field.custom_minimum_size.y = 48
    field.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_child(field)
    return field

func _message(message: String, warning := false) -> void:
    if status_label == null:
        status_label = Label.new()
        status_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
        status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
        content.add_child(status_label)
    status_label.text = message
    status_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.42) if warning else Color(0.55, 0.9, 0.72))

func _button(caption: String, callback: Callable) -> void:
    var button := Button.new()
    button.text = caption
    button.custom_minimum_size.y = 48
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 17)
    button.pressed.connect(callback)
    content.add_child(button)

func _show_register() -> void:
    _clear_content()
    _heading("Gumawa ng account")
    username_input = _field("Username", "Hal. Nhabz")
    email_input = _field("Email", "you@example.com")
    password_input = _field("Password", "Gumawa ng password", true)
    _button("MAG-REGISTER", _register_account)
    _button("May account na? Mag-login", _show_login)
    _message("Prototype muna: naka-save ang account sa device na ito. Hindi pa cloud account.")

func _show_login() -> void:
    _clear_content()
    _heading("Welcome back!")
    email_input = _field("Email", "Ilagay ang registered email")
    password_input = _field("Password", "Ilagay ang password", true)
    _button("LOGIN", _login_account)
    _button("Gumawa ng bagong account", _show_register)
    _message("Local device login prototype. Hindi pa gumagana ang cloud sync.")

func _register_account() -> void:
    var username := username_input.text.strip_edges()
    var email := email_input.text.strip_edges().to_lower()
    var password := password_input.text
    if username.length() < 3 or not email.contains("@") or password.length() < 6:
        _message("Kailangan ng username (3+), valid email, at password na 6+ characters.", true)
        return
    data.set_value("account", "username", username)
    data.set_value("account", "email", email)
    data.set_value("account", "password_hash", password.sha256_text())
    data.set_value("profile", "has_character", false)
    var err := data.save(SAVE_PATH)
    if err != OK:
        _message("Hindi ma-save ang account. Subukan muli.", true)
        return
    _show_creator()

func _login_account() -> void:
    var saved_email := str(data.get_value("account", "email", "")).to_lower()
    var saved_hash := str(data.get_value("account", "password_hash", ""))
    if email_input.text.strip_edges().to_lower() != saved_email or password_input.text.sha256_text() != saved_hash:
        _message("Mali ang email o password.", true)
        return
    if bool(data.get_value("profile", "has_character", false)):
        _enter_world()
    else:
        _show_creator()

func _show_creator() -> void:
    _clear_content()
    _heading("Gumawa ng character")
    var intro := Label.new()
    intro.text = "Piliin ang itsura ng avatar mo. Ito ang gagamitin mong character sa laro."
    intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(intro)
    character_name_input = _field("Pangalan ng character", "Hal. Nhabz")
    skin_picker = _picker("Kulay ng balat", ["Morena", "Kayumanggi", "Maputi"])
    hair_picker = _picker("Estilo ng buhok", ["Maikli", "Mahaba", "Kulot"])
    outfit_picker = _picker("Damit", ["Casual", "Streetwear", "Pang-araw-araw"])
    _button("I-SAVE ANG CHARACTER", _save_character)
    _message("Maaari pa itong baguhin sa susunod na update.")

func _picker(caption: String, choices: Array[String]) -> OptionButton:
    var label := Label.new()
    label.text = caption
    content.add_child(label)
    var picker := OptionButton.new()
    picker.custom_minimum_size.y = 46
    picker.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    for choice in choices:
        picker.add_item(choice)
    content.add_child(picker)
    return picker

func _save_character() -> void:
    var character_name := character_name_input.text.strip_edges()
    if character_name.length() < 2:
        _message("Maglagay ng pangalan na hindi bababa sa 2 character.", true)
        return
    data.set_value("profile", "character_name", character_name)
    data.set_value("profile", "skin", skin_picker.get_item_text(skin_picker.selected))
    data.set_value("profile", "hair", hair_picker.get_item_text(hair_picker.selected))
    data.set_value("profile", "outfit", outfit_picker.get_item_text(outfit_picker.selected))
    data.set_value("profile", "has_character", true)
    var err := data.save(SAVE_PATH)
    if err != OK:
        _message("Hindi ma-save ang character. Subukan muli.", true)
        return
    _apply_avatar()
    _enter_world()

func _apply_avatar() -> void:
    var player := get_parent().get_node_or_null("Player")
    if player == null:
        return
    var old_visual := player.get_node_or_null("Visual")
    if old_visual:
        old_visual.visible = false

    var avatar := player.get_node_or_null("SavedAvatar")
    if avatar:
        avatar.queue_free()
    avatar = Node3D.new()
    avatar.name = "SavedAvatar"
    player.add_child(avatar)

    var skin_name := str(data.get_value("profile", "skin", "Morena"))
    var skin_color := Color(0.55, 0.32, 0.20)
    if skin_name == "Kayumanggi":
        skin_color = Color(0.70, 0.46, 0.31)
    elif skin_name == "Maputi":
        skin_color = Color(0.86, 0.66, 0.52)

    var outfit_name := str(data.get_value("profile", "outfit", "Casual"))
    var shirt_color := Color(0.12, 0.38, 0.72)
    if outfit_name == "Streetwear":
        shirt_color = Color(0.22, 0.18, 0.32)
    elif outfit_name == "Pang-araw-araw":
        shirt_color = Color(0.20, 0.48, 0.30)

    _add_avatar_part(avatar, "Torso", BoxMesh.new(), Vector3(0, 0.95, 0), Vector3(0.62, 0.72, 0.34), shirt_color)
    _add_avatar_part(avatar, "Head", SphereMesh.new(), Vector3(0, 1.55, 0), Vector3(0.38, 0.42, 0.36), skin_color)
    _add_avatar_part(avatar, "LeftLeg", BoxMesh.new(), Vector3(-0.16, 0.38, 0), Vector3(0.22, 0.62, 0.25), Color(0.12, 0.16, 0.22))
    _add_avatar_part(avatar, "RightLeg", BoxMesh.new(), Vector3(0.16, 0.38, 0), Vector3(0.22, 0.62, 0.25), Color(0.12, 0.16, 0.22))
    _add_avatar_part(avatar, "LeftArm", BoxMesh.new(), Vector3(-0.42, 0.98, 0), Vector3(0.18, 0.68, 0.22), skin_color)
    _add_avatar_part(avatar, "RightArm", BoxMesh.new(), Vector3(0.42, 0.98, 0), Vector3(0.18, 0.68, 0.22), skin_color)

    var hair_name := str(data.get_value("profile", "hair", "Maikli"))
    var hair_mesh := SphereMesh.new()
    var hair_scale := Vector3(0.40, 0.18, 0.38)
    if hair_name == "Mahaba":
        hair_scale = Vector3(0.43, 0.35, 0.40)
    elif hair_name == "Kulot":
        hair_scale = Vector3(0.45, 0.24, 0.42)
    _add_avatar_part(avatar, "Hair", hair_mesh, Vector3(0, 1.77, 0), hair_scale, Color(0.08, 0.055, 0.04))

func _add_avatar_part(parent: Node3D, part_name: String, mesh_resource: Mesh, part_position: Vector3, part_scale: Vector3, color: Color) -> void:
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = mesh_resource
    part.position = part_position
    part.scale = part_scale
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.82
    part.material_override = material
    parent.add_child(part)

func _enter_world() -> void:
    _apply_avatar()
    queue_free()
