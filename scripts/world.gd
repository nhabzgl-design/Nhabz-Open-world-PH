extends Node3D

const ROAD := Color("#343a43")
const ASPHALT_LINE := Color("#f5d66c")
const SIDEWALK := Color("#b9b6aa")
const CONCRETE := Color("#d8d2c4")
const GLASS := Color("#8dc8d8")
const LEAF := Color("#247a43")

func _ready() -> void:
    _build_environment()
    _build_ground()
    _build_roads()
    _build_city_blocks()
    _build_vehicles()
    _build_trees()
    _build_npcs()
    _build_welcome_label()

func _mat(color: Color, roughness: float = 0.82, metallic: float = 0.0) -> StandardMaterial3D:
    var material := StandardMaterial3D.new()
    material.albedo_color = color
    material.roughness = roughness
    material.metallic = metallic
    return material

func _box(parent: Node3D, pos: Vector3, size: Vector3, color: Color, name: String = "") -> MeshInstance3D:
    var node := MeshInstance3D.new()
    node.name = name
    var mesh := BoxMesh.new()
    mesh.size = size
    node.mesh = mesh
    node.position = pos
    node.material_override = _mat(color)
    parent.add_child(node)
    return node

func _cylinder(parent: Node3D, pos: Vector3, radius: float, height: float, color: Color, sides: int = 12) -> MeshInstance3D:
    var node := MeshInstance3D.new()
    var mesh := CylinderMesh.new()
    mesh.top_radius = radius * 0.88
    mesh.bottom_radius = radius
    mesh.height = height
    mesh.radial_segments = sides
    node.mesh = mesh
    node.position = pos
    node.material_override = _mat(color)
    parent.add_child(node)
    return node

func _build_environment() -> void:
    var world := WorldEnvironment.new()
    var environment := Environment.new()
    environment.background_mode = Environment.BG_SKY
    var sky := Sky.new()
    var sky_material := ProceduralSkyMaterial.new()
    sky_material.sky_top_color = Color("#2385d8")
    sky_material.sky_horizon_color = Color("#d4e9f7")
    sky_material.ground_bottom_color = Color("#5b625b")
    sky_material.ground_horizon_color = Color("#c7d8dc")
    sky.sky_material = sky_material
    environment.sky = sky
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
    environment.ambient_light_color = Color("#d7e7ff")
    environment.ambient_light_energy = 0.9
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.tonemap_exposure = 1.1
    environment.fog_enabled = true
    environment.fog_light_color = Color("#c4d9e8")
    environment.fog_density = 0.0018
    world.environment = environment
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_color = Color("#fff1d6")
    sun.light_energy = 1.35
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 90.0
    add_child(sun)

func _build_ground() -> void:
    var ground := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(220, 220)
    ground.mesh = plane
    ground.material_override = _mat(Color("#6e9e55"))
    add_child(ground)

    var beach := MeshInstance3D.new()
    var beach_mesh := PlaneMesh.new()
    beach_mesh.size = Vector2(220, 18)
    beach.mesh = beach_mesh
    beach.position = Vector3(0, 0.02, -92)
    beach.material_override = _mat(Color("#d9c18a"))
    add_child(beach)

    var sea := MeshInstance3D.new()
    var sea_mesh := PlaneMesh.new()
    sea_mesh.size = Vector2(220, 45)
    sea.mesh = sea_mesh
    sea.position = Vector3(0, -0.02, -123)
    sea.material_override = _mat(Color("#268eb4"), 0.28, 0.12)
    add_child(sea)

func _build_roads() -> void:
    _box(self, Vector3(0, 0.06, 0), Vector3(15, 0.12, 130), ROAD, "Main Avenue")
    _box(self, Vector3(0, 0.065, -25), Vector3(112, 0.13, 10), ROAD, "Cross Street")

    for side in [-1.0, 1.0]:
        _box(self, Vector3(side * 9.0, 0.12, 0), Vector3(2.8, 0.22, 130), SIDEWALK, "Sidewalk")
        _box(self, Vector3(side * 9.0, 0.24, 0), Vector3(0.18, 0.12, 130), CONCRETE, "Curb")
    for z in range(-57, 58, 8):
        _box(self, Vector3(0, 0.135, float(z)), Vector3(0.22, 0.025, 3.8), ASPHALT_LINE, "Center lane marker")
    for x in range(-48, 49, 8):
        _box(self, Vector3(float(x), 0.14, -25), Vector3(3.8, 0.025, 0.2), ASPHALT_LINE, "Cross lane marker")

    for i in range(8):
        _box(self, Vector3(-7.0 + i * 2.0, 0.16, 8.0), Vector3(1.45, 0.035, 0.22), Color("#eee9dc"), "Pedestrian crossing")
    for side in [-1.0, 1.0]:
        for z in range(-48, 50, 16):
            _box(self, Vector3(side * 10.7, 0.28, float(z)), Vector3(0.16, 0.5, 0.16), Color("#d8d1bd"), "Street bollard")

func _build_city_blocks() -> void:
    _make_shop(Vector3(-17, 0, -14))
    _make_public_building(Vector3(17, 0, -18))
    _make_home(Vector3(-19, 0, 15))
    _make_home(Vector3(20, 0, 14))
    _make_skyline()

func _make_shop(pos: Vector3) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    _box(root, Vector3(0, 3.2, 0), Vector3(12, 6.4, 9), Color("#e7d2a9"), "Sari sari store")
    _box(root, Vector3(0, 6.55, 0), Vector3(12.5, 0.45, 9.5), Color("#b94d37"), "Roof fascia")
    _box(root, Vector3(0, 4.9, 4.58), Vector3(10.8, 1.0, 0.16), Color("#174c76"), "Store signboard")
    var sign := Label3D.new()
    sign.text = "TINDahan NI ALING MARIA"
    sign.font_size = 42
    sign.pixel_size = 0.012
    sign.position = Vector3(0, 4.88, 4.72)
    sign.modulate = Color("#fff3cf")
    root.add_child(sign)
    _box(root, Vector3(-3.1, 2.0, 4.62), Vector3(2.4, 3.3, 0.18), Color("#5b3427"), "Door")
    _box(root, Vector3(1.0, 2.7, 4.63), Vector3(4.8, 2.1, 0.18), GLASS, "Shop window")
    _box(root, Vector3(1.0, 1.55, 4.78), Vector3(5.1, 0.22, 0.7), Color("#d9a35e"), "Counter")
    _box(root, Vector3(0, 0.18, 0), Vector3(13, 0.35, 10), CONCRETE, "Store step")
    _box(root, Vector3(0, 0.3, 5.3), Vector3(13, 0.25, 1.0), Color("#c5b89e"), "Store frontage")

func _make_public_building(pos: Vector3) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    _box(root, Vector3(0, 5.5, 0), Vector3(13, 11, 11), Color("#d8e0e4"), "Municipal building")
    _box(root, Vector3(0, 11.1, 0), Vector3(13.6, 0.5, 11.6), Color("#315b80"), "Roof")
    _box(root, Vector3(0, 8.7, 5.58), Vector3(8.8, 1.15, 0.16), Color("#164b73"), "Municipal sign")
    var sign := Label3D.new()
    sign.text = "CITY HALL"
    sign.font_size = 46
    sign.position = Vector3(0, 8.65, 5.72)
    sign.modulate = Color.WHITE
    root.add_child(sign)
    for x in [-4.2, -1.4, 1.4, 4.2]:
        for y in [3.0, 5.8, 7.8]:
            _box(root, Vector3(x, y, 5.58), Vector3(1.55, 1.35, 0.12), GLASS, "Office window")
    _box(root, Vector3(0, 1.7, 5.62), Vector3(2.1, 3.2, 0.2), Color("#6d503c"), "Main entrance")
    _box(root, Vector3(0, 0.2, 0), Vector3(14, 0.4, 12), CONCRETE, "Hall plaza")

func _make_home(pos: Vector3) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    _box(root, Vector3(0, 2.0, 0), Vector3(8, 4, 7), Color("#f0dfc3"), "Concrete house")
    _box(root, Vector3(0, 4.25, 0), Vector3(8.8, 0.5, 7.8), Color("#9d4536"), "Roof")
    _box(root, Vector3(-1.8, 1.6, 3.58), Vector3(1.6, 2.8, 0.15), Color("#76513a"), "Front door")
    _box(root, Vector3(1.4, 2.35, 3.6), Vector3(2.1, 1.5, 0.12), GLASS, "Front window")
    _box(root, Vector3(0, 0.18, 0), Vector3(9, 0.35, 8), CONCRETE, "House footing")

func _make_skyline() -> void:
    var colors := [Color("#8aa8b8"), Color("#b8c4c8"), Color("#d2bda1"), Color("#7898a8")]
    for i in range(12):
        var x := -55.0 + float(i) * 10.0
        var z := -55.0 - float(i % 3) * 7.0
        var height := 15.0 + float((i * 7) % 19)
        var width := 6.0 + float(i % 3) * 1.5
        _box(self, Vector3(x, height / 2.0, z), Vector3(width, height, 7), colors[i % colors.size()], "Distant city tower")
        for floor_index in range(2, int(height) - 2, 4):
            _box(self, Vector3(x, float(floor_index), z + 3.56), Vector3(width * 0.72, 1.1, 0.08), GLASS, "Tower windows")

func _build_vehicles() -> void:
    _make_jeepney(Vector3(3.7, 0, -8), 0.0)
    _make_tricycle(Vector3(-3.5, 0, -31), PI / 2.0)
    _make_car(Vector3(4.0, 0, -43), Color("#e9e8e0"))

func _wheel(parent: Node3D, pos: Vector3, radius: float = 0.52) -> void:
    var wheel := _cylinder(parent, pos, radius, 0.28, Color("#202329"), 16)
    wheel.rotation.z = PI / 2.0
    var hub := _cylinder(parent, pos, radius * 0.42, 0.30, Color("#b7bec2"), 12)
    hub.rotation.z = PI / 2.0

func _make_jeepney(pos: Vector3, yaw: float) -> void:
    var root := Node3D.new()
    root.position = pos
    root.rotation.y = yaw
    add_child(root)
    _box(root, Vector3(0, 1.35, 0), Vector3(2.6, 1.45, 6.4), Color("#e8b52d"), "Jeepney body")
    _box(root, Vector3(0, 2.35, -0.1), Vector3(2.5, 0.85, 4.6), Color("#1766a1"), "Jeepney upper cabin")
    _box(root, Vector3(0, 2.84, -0.1), Vector3(2.55, 0.16, 4.7), Color("#f5d54d"), "Jeepney roof trim")
    _box(root, Vector3(0, 1.42, 3.25), Vector3(2.35, 0.8, 0.16), Color("#d9e9ee"), "Jeepney windshield")
    _box(root, Vector3(0, 0.78, 0), Vector3(2.8, 0.22, 6.5), Color("#30343a"), "Jeepney chassis")
    _box(root, Vector3(0, 2.0, 2.42), Vector3(2.62, 0.13, 0.12), Color("#f6df76"), "Front visor")
    for x in [-1.34, 1.34]:
        for z in [-2.1, -0.7, 0.7, 2.1]:
            _wheel(root, Vector3(x, 0.62, z), 0.48)
    for x in [-0.8, 0.8]:
        var lamp := _box(root, Vector3(x, 1.42, 3.36), Vector3(0.35, 0.28, 0.12), Color("#fff4c4"), "Headlight")
    var route := Label3D.new()
    route.text = "PHILIPPINAS"
    route.font_size = 34
    route.position = Vector3(0, 2.45, 3.38)
    route.modulate = Color("#fff6d7")
    root.add_child(route)

func _make_tricycle(pos: Vector3, yaw: float) -> void:
    var root := Node3D.new()
    root.position = pos
    root.rotation.y = yaw
    add_child(root)
    _box(root, Vector3(0, 0.95, 0), Vector3(1.15, 0.9, 2.2), Color("#d4d7d8"), "Motorcycle body")
    _box(root, Vector3(1.0, 1.0, 0.0), Vector3(1.6, 1.5, 2.0), Color("#c74432"), "Tricycle sidecar")
    _box(root, Vector3(1.0, 1.8, 0), Vector3(1.7, 0.12, 2.1), Color("#292d35"), "Sidecar roof")
    _wheel(root, Vector3(-0.1, 0.48, 0.85), 0.42)
    _wheel(root, Vector3(-0.1, 0.48, -0.85), 0.42)
    _wheel(root, Vector3(1.0, 0.48, 0.8), 0.42)

func _make_car(pos: Vector3, color: Color) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    _box(root, Vector3(0, 0.85, 0), Vector3(2.0, 0.85, 4.2), color, "Car body")
    _box(root, Vector3(0, 1.45, -0.2), Vector3(1.7, 0.65, 2.2), GLASS, "Car windows")
    for x in [-1.0, 1.0]:
        for z in [-1.35, 1.35]:
            _wheel(root, Vector3(x, 0.48, z), 0.38)

func _build_trees() -> void:
    for pos in [Vector3(-29, 0, -8), Vector3(29, 0, 9), Vector3(27, 0, -39), Vector3(-31, 0, 37), Vector3(33, 0, -61), Vector3(-35, 0, -45)]:
        _make_palm(pos)

func _make_palm(pos: Vector3) -> void:
    var trunk := _cylinder(self, pos + Vector3(0, 3.1, 0), 0.34, 6.2, Color("#8a5a35"), 10)
    trunk.rotation.z = -0.08
    for i in range(7):
        var angle := TAU * float(i) / 7.0
        var frond := _cylinder(self, pos + Vector3(cos(angle) * 1.65, 5.9, sin(angle) * 1.65), 0.16, 3.5, LEAF, 8)
        frond.rotation = Vector3(cos(angle) * 0.55, 0, -sin(angle) * 0.55)
    var crown := MeshInstance3D.new()
    var sphere := SphereMesh.new()
    sphere.radius = 0.65
    sphere.height = 1.2
    crown.mesh = sphere
    crown.position = pos + Vector3(0, 6.0, 0)
    crown.material_override = _mat(Color("#277344"))
    add_child(crown)

func _build_npcs() -> void:
    var outfits := [Color("#d94b3d"), Color("#2464a4"), Color("#e6bd43"), Color("#e8e4d9"), Color("#3d8054"), Color("#9b5c9d")]
    for i in range(6):
        _make_person(Vector3(-7.5 + float(i) * 2.8, 0, -1.0 - float(i % 2) * 3.0), outfits[i], i)

func _make_person(pos: Vector3, shirt_color: Color, variant: int) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    var skin := _mat([Color("#bd815f"), Color("#d29a72"), Color("#9c654b")][variant % 3])
    var shirt := _mat(shirt_color)
    var pants := _mat(Color("#303b4a"))
    var head := MeshInstance3D.new()
    var head_mesh := SphereMesh.new()
    head_mesh.radius = 0.23
    head_mesh.height = 0.48
    head.mesh = head_mesh
    head.position = Vector3(0, 1.55, 0)
    head.material_override = skin
    root.add_child(head)
    _box(root, Vector3(0, 1.02, 0), Vector3(0.52, 0.62, 0.3), shirt_color, "NPC shirt")
    _box(root, Vector3(-0.16, 0.43, 0), Vector3(0.17, 0.58, 0.2), Color("#303b4a"), "Left leg")
    _box(root, Vector3(0.16, 0.43, 0), Vector3(0.17, 0.58, 0.2), Color("#303b4a"), "Right leg")
    var left_arm := _cylinder(root, Vector3(-0.36, 1.0, 0), 0.09, 0.62, skin.albedo_color, 8)
    left_arm.rotation.z = -0.18
    var right_arm := _cylinder(root, Vector3(0.36, 1.0, 0), 0.09, 0.62, skin.albedo_color, 8)
    right_arm.rotation.z = 0.18

func _build_welcome_label() -> void:
    var label := Label3D.new()
    label.text = "MALIGAYANG PAGDATING SA PILIPINAS!"
    label.position = Vector3(0, 5.0, -34)
    label.font_size = 48
    label.modulate = Color("#fff0c8")
    add_child(label)
