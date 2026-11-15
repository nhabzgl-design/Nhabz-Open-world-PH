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
var preview_root: Node3D
var preview_avatar: Node3D

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
    backdrop.color = Color(0.025, 0.04, 0.065, 0.98)
    backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(backdrop)

    var center := CenterContainer.new()
    center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(center)

    var panel := PanelContainer.new()
    panel.custom_minimum_size = Vector2(340, 560)
    panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
    var style := StyleBoxFlat.new()
    style.bg_color = Color(0.065, 0.09, 0.13, 1)
    style.set_corner_radius_all(22)
    style.set_content_margin_all(20)
    panel.add_theme_stylebox_override("panel", style)
    center.add_child(panel)

    var scroll := ScrollContainer.new()
    scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
    panel.add_child(scroll)
    content = VBoxContainer.new()
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 11)
    scroll.add_child(content)

func _clear_content() -> void:
    for child in content.get_children():
        child.queue_free()
    status_label = null
    preview_root = null
    preview_avatar = null

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
    button.custom_minimum_size.y = 49
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 17)
    button.pressed.connect(callback)
    content.add_child(button)

func _show_register() -> void:
    _clear_content()
    _heading("Gumawa ng account")
    username_input = _field("Username", "Hal. Nhabz")
    email_input = _field("Email", "you@example.com")
    password_input = _field("Password", "Gumawa ng password (6+ characters)", true)
    _button("MAG-REGISTER", _register_account)
    _button("May account na? Mag-login", _show_login)
    _message("Prototype account: sa device na ito lang naka-save. Hindi pa cloud account.")

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
    # Local prototype only. Replace with a secure server-side auth provider before release.
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
    intro.text = "I-preview ang avatar habang pinipili ang itsura nito."
    intro.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    intro.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    content.add_child(intro)

    _create_preview()
    character_name_input = _field("Pangalan ng character", "Hal. Nhabz")
    skin_picker = _picker("Kulay ng balat", ["Morena", "Kayumanggi", "Maputi"])
    hair_picker = _picker("Estilo ng buhok", ["Maikli", "Mahaba", "Kulot"])
    outfit_picker = _picker("Damit", ["Casual", "Streetwear", "Pang-araw-araw"])
    skin_picker.item_selected.connect(_refresh_preview)
    hair_picker.item_selected.connect(_refresh_preview)
    outfit_picker.item_selected.connect(_refresh_preview)
    _refresh_preview()
    _button("I-SAVE ANG CHARACTER", _save_character)
    _message("Prototype preview: maaari pang dagdagan ang mukha, damit at body options.")

func _create_preview() -> void:
    var frame := PanelContainer.new()
    frame.custom_minimum_size = Vector2(0, 280)
    var frame_style := StyleBoxFlat.new()
    frame_style.bg_color = Color(0.035, 0.055, 0.085, 1)
    frame_style.set_corner_radius_all(16)
    frame.add_theme_stylebox_override("panel", frame_style)
    content.add_child(frame)

    var view := SubViewportContainer.new()
    view.stretch = true
    view.custom_minimum_size = Vector2(0, 280)
    view.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    frame.add_child(view)

    var viewport := SubViewport.new()
    viewport.size = Vector2i(480, 360)
    viewport.own_world_3d = true
    viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
    view.add_child(viewport)

    var stage := Node3D.new()
    viewport.add_child(stage)
    preview_root = stage

    var camera := Camera3D.new()
    camera.position = Vector3(0, 1.45, 3.9)
    camera.look_at(Vector3(0, 1.0, 0), Vector3.UP)
    camera.fov = 38
    stage.add_child(camera)
    camera.current = true

    var key_light := DirectionalLight3D.new()
    key_light.rotation_degrees = Vector3(-28, -25, 0)
    key_light.light_energy = 1.25
    stage.add_child(key_light)
    var fill_light := OmniLight3D.new()
    fill_light.position = Vector3(-2, 2, 2)
    fill_light.light_energy = 0.55
    fill_light.omni_range = 7
    stage.add_child(fill_light)

    var floor_mesh := MeshInstance3D.new()
    var floor := CylinderMesh.new()
    floor.top_radius = 1.35
    floor.bottom_radius = 1.35
    floor.height = 0.08
    floor_mesh.mesh = floor
    floor_mesh.position.y = -0.06
    var floor_mat := StandardMaterial3D.new()
    floor_mat.albedo_color = Color(0.12, 0.18, 0.24)
    floor_mat.roughness = 0.9
    floor_mesh.material_override = floor_mat
    stage.add_child(floor_mesh)

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

func _refresh_preview(_index: int = 0) -> void:
    if preview_root == null or skin_picker == null:
        return
    if preview_avatar != null:
        preview_avatar.queue_free()
    preview_avatar = _build_avatar(
        str(skin_picker.get_item_text(skin_picker.selected)),
        str(hair_picker.get_item_text(hair_picker.selected)),
        str(outfit_picker.get_item_text(outfit_picker.selected))
    )
    preview_root.add_child(preview_avatar)

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
    _enter_world()

func _apply_avatar() -> void:
    var player := get_parent().get_node_or_null("Player")
    if player == null:
        return
    var old_visual := player.get_node_or_null("Visual")
    if old_visual:
        old_visual.visible = false
    var old_avatar := player.get_node_or_null("SavedAvatar")
    if old_avatar:
        old_avatar.queue_free()
    var avatar := _build_avatar(
        str(data.get_value("profile", "skin", "Morena")),
        str(data.get_value("profile", "hair", "Maikli")),
        str(data.get_value("profile", "outfit", "Casual"))
    )
    avatar.name = "SavedAvatar"
    player.add_child(avatar)

func _build_avatar(skin_name: String, hair_name: String, outfit_name: String) -> Node3D:
    # Prefer the approved, textured humanoid GLB when it has been added.
    # Keep the procedural avatar only as a clearly temporary development fallback.
    const REAL_CHARACTER_PATH := "res://assets/characters/filipino_male.glb"
    if ResourceLoader.exists(REAL_CHARACTER_PATH):
        var packed_character := load(REAL_CHARACTER_PATH) as PackedScene
        if packed_character != null:
            var imported_character := packed_character.instantiate() as Node3D
            if imported_character != null:
                imported_character.name = "FilipinoMaleCharacter"
                var animation_player := imported_character.find_child("AnimationPlayer", true, false) as AnimationPlayer
                if animation_player != null:
                    if animation_player.has_animation("Idle"):
                        animation_player.play("Idle")
                    elif animation_player.get_animation_list().size() > 0:
                        animation_player.play(animation_player.get_animation_list()[0])
                return imported_character

    var avatar := Node3D.new()
    var skin_color := Color(0.55, 0.32, 0.20)
    if skin_name == "Kayumanggi":
        skin_color = Color(0.70, 0.46, 0.31)
    elif skin_name == "Maputi":
        skin_color = Color(0.86, 0.66, 0.52)

    var shirt_color := Color(0.12, 0.38, 0.72)
    var pants_color := Color(0.10, 0.13, 0.19)
    if outfit_name == "Streetwear":
        shirt_color = Color(0.24, 0.18, 0.36)
        pants_color = Color(0.08, 0.08, 0.12)
    elif outfit_name == "Pang-araw-araw":
        shirt_color = Color(0.18, 0.43, 0.27)
        pants_color = Color(0.30, 0.23, 0.16)

    # Shoes, legs, torso and arms are separate meshes so the avatar reads as a person.
    _add_part(avatar, "LeftShoe", BoxMesh.new(), Vector3(-0.16, 0.08, 0.04), Vector3(0.25, 0.15, 0.38), Color(0.035, 0.04, 0.05))
    _add_part(avatar, "RightShoe", BoxMesh.new(), Vector3(0.16, 0.08, 0.04), Vector3(0.25, 0.15, 0.38), Color(0.035, 0.04, 0.05))
    _add_part(avatar, "LeftLeg", CapsuleMesh.new(), Vector3(-0.16, 0.43, 0), Vector3(0.14, 0.40, 0.15), pants_color)
    _add_part(avatar, "RightLeg", CapsuleMesh.new(), Vector3(0.16, 0.43, 0), Vector3(0.14, 0.40, 0.15), pants_color)
    _add_part(avatar, "Torso", CapsuleMesh.new(), Vector3(0, 1.02, 0), Vector3(0.32, 0.40, 0.19), shirt_color)
    _add_part(avatar, "Neck", CylinderMesh.new(), Vector3(0, 1.43, 0), Vector3(0.095, 0.12, 0.095), skin_color)
    _add_part(avatar, "Head", SphereMesh.new(), Vector3(0, 1.68, 0), Vector3(0.23, 0.28, 0.22), skin_color)
    _add_part(avatar, "LeftEar", SphereMesh.new(), Vector3(-0.225, 1.67, 0), Vector3(0.055, 0.075, 0.045), skin_color)
    _add_part(avatar, "RightEar", SphereMesh.new(), Vector3(0.225, 1.67, 0), Vector3(0.055, 0.075, 0.045), skin_color)
    _add_part(avatar, "LeftArm", CapsuleMesh.new(), Vector3(-0.39, 1.02, 0), Vector3(0.105, 0.34, 0.11), shirt_color, Vector3(0, 0, -8))
    _add_part(avatar, "RightArm", CapsuleMesh.new(), Vector3(0.39, 1.02, 0), Vector3(0.105, 0.34, 0.11), shirt_color, Vector3(0, 0, 8))
    _add_part(avatar, "LeftHand", SphereMesh.new(), Vector3(-0.42, 0.68, 0), Vector3(0.085, 0.10, 0.08), skin_color)
    _add_part(avatar, "RightHand", SphereMesh.new(), Vector3(0.42, 0.68, 0), Vector3(0.085, 0.10, 0.08), skin_color)

    # Face details are placed on the front (+Z) side of the head.
    var eye_color := Color(0.035, 0.025, 0.02)
    _add_part(avatar, "LeftEye", SphereMesh.new(), Vector3(-0.085, 1.72, 0.194), Vector3(0.025, 0.032, 0.018), eye_color)
    _add_part(avatar, "RightEye", SphereMesh.new(), Vector3(0.085, 1.72, 0.194), Vector3(0.025, 0.032, 0.018), eye_color)
    _add_part(avatar, "Nose", SphereMesh.new(), Vector3(0, 1.65, 0.215), Vector3(0.035, 0.045, 0.035), skin_color)
    _add_part(avatar, "HairCap", SphereMesh.new(), Vector3(0, 1.88, -0.005), Vector3(0.245, 0.13, 0.235), Color(0.055, 0.035, 0.025))

    if hair_name == "Mahaba":
        _add_part(avatar, "LongHairBack", CapsuleMesh.new(), Vector3(0, 1.62, -0.16), Vector3(0.20, 0.30, 0.12), Color(0.055, 0.035, 0.025))
        _add_part(avatar, "LongHairLeft", SphereMesh.new(), Vector3(-0.205, 1.62, -0.02), Vector3(0.075, 0.25, 0.10), Color(0.055, 0.035, 0.025))
        _add_part(avatar, "LongHairRight", SphereMesh.new(), Vector3(0.205, 1.62, -0.02), Vector3(0.075, 0.25, 0.10), Color(0.055, 0.035, 0.025))
    elif hair_name == "Kulot":
        for i in range(7):
            var x := -0.18 + float(i) * 0.06
            _add_part(avatar, "Curl" + str(i), SphereMesh.new(), Vector3(x, 1.91 + (0.015 if i % 2 == 0 else 0.0), 0.07), Vector3(0.075, 0.09, 0.075), Color(0.055, 0.035, 0.025))

    if outfit_name == "Streetwear":
        _add_part(avatar, "JacketZip", BoxMesh.new(), Vector3(0, 1.03, 0.194), Vector3(0.018, 0.55, 0.012), Color(0.65, 0.67, 0.72))
        _add_part(avatar, "JacketPocket", BoxMesh.new(), Vector3(0.20, 0.94, 0.18), Vector3(0.12, 0.12, 0.025), shirt_color)
    elif outfit_name == "Pang-araw-araw":
        _add_part(avatar, "ShirtLogo", SphereMesh.new(), Vector3(0.16, 1.13, 0.19), Vector3(0.045, 0.045, 0.018), Color(0.92, 0.84, 0.62))

    return avatar

func _add_part(parent: Node3D, part_name: String, mesh_resource: Mesh, part_position: Vector3, part_scale: Vector3, color: Color, rotation_degrees: Vector3 = Vector3.ZERO) -> void:
    var part := MeshInstance3D.new()
    part.name = part_name
    part.mesh = mesh_resource
    part.position = part_position
    part.scale = part_scale
    part.rotation_degrees = rotation_degrees
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = 0.78
    part.material_override = material
    parent.add_child(part)

func _enter_world() -> void:
    _apply_avatar()
    queue_free()
