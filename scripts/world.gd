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
    _build_street_details()
    _build_building_details()
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
    environment.ambient_light_energy = 0.62
    environment.tonemap_mode = Environment.TONE_MAPPER_FILMIC
    environment.tonemap_exposure = 0.92
    environment.fog_enabled = true
    environment.fog_light_color = Color("#c4d9e8")
    environment.fog_density = 0.0009
    world.environment = environment
    add_child(world)

    var sun := DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-48, -32, 0)
    sun.light_color = Color("#fff1d6")
    sun.light_energy = 1.05
    sun.shadow_enabled = true
    sun.directional_shadow_max_distance = 90.0
    add_child(sun)

func _build_ground() -> void:
    # Compact urban district ground plane: no beach/empty countryside in the Manila slice.
    var ground := MeshInstance3D.new()
    var plane := PlaneMesh.new()
    plane.size = Vector2(150, 150)
    ground.mesh = plane
    ground.material_override = _mat(Color("#77766f"))
    add_child(ground)
    # Concrete lots and courtyards around the street grid.
    for x in [-38.0, 38.0]:
        for z in [-38.0, 38.0]:
            _box(self, Vector3(x, 0.025, z), Vector3(34, 0.05, 34), Color("#a9a49a"), "Urban block paving")
    _box(self, Vector3(0, 0.018, -46), Vector3(150, 0.04, 12), Color("#aaa69c"), "North block pavement")
func _build_roads() -> void:
    # Narrower, connected Manila-style streets with a central avenue and side streets.
    _box(self, Vector3(0, 0.06, 0), Vector3(14, 0.12, 112), ROAD, "Quiapo Avenue")
    _box(self, Vector3(0, 0.065, -24), Vector3(112, 0.13, 9), ROAD, "Market Street")
    _box(self, Vector3(-28, 0.06, 22), Vector3(8, 0.12, 52), ROAD, "West side street")
    _box(self, Vector3(29, 0.06, 22), Vector3(8, 0.12, 52), ROAD, "East side street")
    for side in [-1.0, 1.0]:
        _box(self, Vector3(side * 8.7, 0.12, 0), Vector3(3.2, 0.22, 112), SIDEWALK, "Main sidewalk")
        _box(self, Vector3(side * 7.15, 0.24, 0), Vector3(0.16, 0.12, 112), CONCRETE, "Main curb")
    for x in [-28.0, 29.0]:
        for side in [-1.0, 1.0]:
            _box(self, Vector3(x + side * 5.2, 0.12, 22), Vector3(2.4, 0.22, 52), SIDEWALK, "Side street sidewalk")
    for z in range(-50, 55, 8):
        _box(self, Vector3(0, 0.135, float(z)), Vector3(0.18, 0.025, 3.6), ASPHALT_LINE, "Lane marker")
    for x in range(-48, 49, 8):
        _box(self, Vector3(float(x), 0.14, -24), Vector3(3.5, 0.025, 0.18), ASPHALT_LINE, "Cross street marker")
    for i in range(8):
        _box(self, Vector3(-6.2 + i * 1.75, 0.16, 7.0), Vector3(1.25, 0.035, 0.2), Color("#f1eee5"), "Pedestrian crossing")
    # Sidewalk tile seams and storm drains.
    for side in [-1.0, 1.0]:
        for z in range(-52, 55, 3):
            _box(self, Vector3(side * 8.7, 0.245, float(z)), Vector3(3.0, 0.025, 2.85), Color("#c5c0b5"), "Sidewalk tile")
        for z in [-42.0, -12.0, 18.0, 48.0]:
            _box(self, Vector3(side * 10.35, 0.26, z), Vector3(0.42, 0.035, 1.2), Color("#666c6e"), "Drain cover")
func _build_city_blocks() -> void:
    # A small Quiapo-inspired district: market frontage, civic plaza and church landmark.
    _make_shop(Vector3(-18, 0, -13))
    _make_public_building(Vector3(19, 0, -18))
    _make_home(Vector3(-20, 0, 17))
    _make_home(Vector3(20, 0, 17))
    _make_small_store(Vector3(-31, 0, -29), Color("#d9c39b"), Color("#28728b"), "PANADERIA")
    _make_small_store(Vector3(31, 0, -2), Color("#e5d6c2"), Color("#a34b3d"), "BOTIKA")
    _make_small_store(Vector3(-31, 0, 28), Color("#d6c7ad"), Color("#28704e"), "TALIPAPA")
    _make_church_landmark(Vector3(0, 0, -48))
    _make_market_stalls()
    _make_skyline()

func _make_church_landmark(pos: Vector3) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    var stone := Color("#d7c7a8")
    var trim := Color("#eee2c8")
    _box(root, Vector3(0, 5.2, 0), Vector3(22, 10.4, 16), stone, "Church nave")
    _box(root, Vector3(0, 10.55, 0), Vector3(23, 0.55, 17), trim, "Church cornice")
    _box(root, Vector3(0, 2.0, 8.1), Vector3(7.0, 4.0, 0.35), Color("#594333"), "Church main doors")
    for x in [-8.0, -4.0, 4.0, 8.0]:
        _cylinder(root, Vector3(x, 4.9, 8.25), 0.62, 9.2, trim, 16)
        _cylinder(root, Vector3(x, 9.6, 8.25), 0.82, 0.35, Color("#b79b72"), 16)
    for x in [-7.0, 7.0]:
        _box(root, Vector3(x, 13.0, 0), Vector3(4.0, 5.0, 4.0), stone, "Church bell tower")
        _box(root, Vector3(x, 15.7, 0), Vector3(4.5, 0.35, 4.5), trim, "Tower cornice")
        var spire := _cylinder(root, Vector3(x, 17.3, 0), 1.6, 3.2, Color("#8b765a"), 12)
    var pediment := MeshInstance3D.new()
    var pyramid := PrismMesh.new()
    pyramid.size = Vector3(12, 3.5, 0.7)
    pediment.mesh = pyramid
    pediment.position = Vector3(0, 12.2, 8.2)
    pediment.material_override = _mat(trim)
    root.add_child(pediment)
    _box(root, Vector3(0, 0.16, 13), Vector3(34, 0.32, 24), Color("#bdb5a6"), "Church plaza")
    var marker := Label3D.new()
    marker.text = "PLAZA"
    marker.font_size = 38
    marker.position = Vector3(0, 2.1, 15)
    marker.modulate = Color("#fff4d8")
    root.add_child(marker)

func _make_market_stalls() -> void:
    for i in range(5):
        var x := -25.0 + float(i) * 2.6
        _box(self, Vector3(x, 1.15, -5.0), Vector3(2.25, 1.6, 2.0), [Color("#b85c43"), Color("#d4a64b"), Color("#648b62"), Color("#477c9c"), Color("#a66b9a")][i], "Market stall counter")
        _box(self, Vector3(x, 2.15, -5.0), Vector3(2.45, 0.16, 2.2), Color("#e7d3ad"), "Market stall canopy")
        for crate in range(2):
            _box(self, Vector3(x - 0.45 + float(crate) * 0.9, 1.9, -4.0), Vector3(0.65, 0.42, 0.55), Color("#d5a44e"), "Produce basket")
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
    _make_jeepney(Vector3(-3.8, 0, 34), PI)
    _make_tricycle(Vector3(-3.5, 0, -31), PI / 2.0)
    _make_tricycle(Vector3(24.0, 0, 8), -PI / 2.0)
    _make_car(Vector3(4.0, 0, -43), Color("#e9e8e0"))
    _make_car(Vector3(-4.0, 0, 45), Color("#b63f35"))
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
    var outfits := [Color("#d94b3d"), Color("#2464a4"), Color("#e6bd43"), Color("#e8e4d9"), Color("#3d8054"), Color("#9b5c9d"), Color("#b66b3e"), Color("#42515f"), Color("#d48c9a"), Color("#557c9b"), Color("#8c704b"), Color("#65734c")]
    for i in range(12):
        var pos := Vector3(-6.5 + float(i % 6) * 2.5, 0, -1.0 - float(i / 6) * 3.2)
        _make_person(pos, outfits[i], i)
    for i in range(5):
        _make_person(Vector3(-26.0 + float(i) * 2.6, 0, -9.0), outfits[(i + 4) % outfits.size()], i + 12)
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


func _build_street_details() -> void:
    # Sidewalk paving, drains and street furniture make the street read as a lived-in place.
    for side in [-1.0, 1.0]:
        for z in range(-58, 60, 4):
            _box(self, Vector3(side * 9.0, 0.245, float(z)), Vector3(2.55, 0.025, 3.82), Color("#c8c2b5"), "Sidewalk paving slab")
            _box(self, Vector3(side * 10.45, 0.255, float(z) + 1.7), Vector3(0.42, 0.035, 0.18), Color("#777b78"), "Drain grate")
        for z in [-42.0, -12.0, 18.0, 48.0]:
            _make_street_lamp(Vector3(side * 11.2, 0, z))
        _make_power_pole(Vector3(side * 14.0, 0, -6.0 if side < 0 else 22.0))
    # Painted curb sections and a small public transport stop.
    for z in range(-50, 55, 10):
        _box(self, Vector3(-10.7, 0.32, float(z)), Vector3(0.18, 0.12, 4.2), Color("#f1eee2"), "Curb paint")
    _box(self, Vector3(-13.0, 1.55, -34.0), Vector3(4.0, 0.12, 2.0), Color("#23618a"), "Jeepney stop roof")
    for x in [-14.6, -11.4]:
        _box(self, Vector3(x, 0.85, -34.0), Vector3(0.12, 1.4, 0.12), Color("#4c5357"), "Jeepney stop post")
    _box(self, Vector3(-13.0, 0.48, -32.9), Vector3(3.0, 0.16, 0.5), Color("#8a6448"), "Waiting bench")
    var stop_sign := Label3D.new()
    stop_sign.text = "SAKAYAN"
    stop_sign.font_size = 30
    stop_sign.position = Vector3(-13.0, 2.0, -32.9)
    stop_sign.modulate = Color("#fff4d8")
    add_child(stop_sign)

func _make_street_lamp(pos: Vector3) -> void:
    _cylinder(self, pos + Vector3(0, 3.0, 0), 0.09, 6.0, Color("#444b50"), 10)
    _box(self, pos + Vector3(0, 5.95, -0.55), Vector3(0.12, 0.12, 1.2), Color("#444b50"), "Lamp arm")
    var lamp := _box(self, pos + Vector3(0, 5.85, -1.05), Vector3(0.55, 0.16, 0.42), Color("#f4e7b5"), "Street light")
    lamp.material_override.emission_enabled = true
    lamp.material_override.emission = Color("#e6d49a")
    lamp.material_override.emission_energy_multiplier = 0.18

func _make_power_pole(pos: Vector3) -> void:
    _cylinder(self, pos + Vector3(0, 5.0, 0), 0.16, 10.0, Color("#745a43"), 8)
    _box(self, pos + Vector3(0, 8.4, 0), Vector3(2.2, 0.13, 0.16), Color("#6b5746"), "Power crossarm")
    for x in [-0.8, 0.0, 0.8]:
        _cylinder(self, pos + Vector3(x, 8.75, 0), 0.07, 0.55, Color("#ded8c8"), 8)
    _wire_between(pos + Vector3(-0.8, 8.9, 0), pos + Vector3(0.8, 8.9, -26.0))
    _wire_between(pos + Vector3(0.0, 8.9, 0), pos + Vector3(0.0, 8.9, -26.0))
    _wire_between(pos + Vector3(0.8, 8.9, 0), pos + Vector3(-0.8, 8.9, -26.0))

func _wire_between(a: Vector3, b: Vector3) -> void:
    var delta := b - a
    var wire := _cylinder(self, (a + b) * 0.5, 0.025, delta.length(), Color("#252c32"), 6)
    wire.look_at(b, Vector3.UP)
    wire.rotate_object_local(Vector3.RIGHT, PI / 2.0)

func _build_building_details() -> void:
    # Add layered trim, awnings, window frames and small details to the existing buildings.
    for pos in [Vector3(-19, 0, 15), Vector3(20, 0, 14)]:
        _box(self, pos + Vector3(0, 2.1, 3.62), Vector3(8.1, 0.16, 0.22), Color("#eee5d4"), "House front lintel")
        _box(self, pos + Vector3(0, 0.55, 4.2), Vector3(8.5, 0.12, 1.0), Color("#9b8a72"), "House front step")
        for x in [-2.8, 2.8]:
            _box(self, pos + Vector3(x, 2.35, 3.68), Vector3(0.12, 1.8, 0.14), Color("#f6ebd9"), "Window trim")
    # Market crates and colorful awning beside the sari-sari store.
    for i in range(4):
        var crate_color := [Color("#c65c36"), Color("#d9ad42"), Color("#4e8955"), Color("#4779a4")][i]
        _box(self, Vector3(-22.0 + float(i) * 1.05, 0.62, -8.2), Vector3(0.85, 1.0, 0.8), crate_color, "Market produce crate")
    _box(self, Vector3(-17.0, 4.0, -8.9), Vector3(11.8, 0.18, 1.0), Color("#e6a94c"), "Store awning")
    for x in [-21.5, -17.0, -12.5]:
        _box(self, Vector3(x, 3.45, -8.9), Vector3(0.1, 1.1, 0.1), Color("#76583f"), "Awning support")
    # Additional low-rise storefronts to avoid a lonely isolated block.
    _make_small_store(Vector3(-29, 0, -28), Color("#d9c39b"), Color("#28728b"), "PANADERIA")
    _make_small_store(Vector3(30, 0, -2), Color("#e5d6c2"), Color("#a34b3d"), "BOTIKA")

func _make_small_store(pos: Vector3, wall: Color, sign_color: Color, title_text: String) -> void:
    var root := Node3D.new()
    root.position = pos
    add_child(root)
    _box(root, Vector3(0, 2.2, 0), Vector3(9.0, 4.4, 7.0), wall, "Neighborhood shop")
    _box(root, Vector3(0, 4.55, 0), Vector3(9.4, 0.28, 7.4), Color("#8c4939"), "Shop roof edge")
    _box(root, Vector3(0, 3.5, 3.58), Vector3(7.2, 0.72, 0.15), sign_color, "Shop sign")
    var sign := Label3D.new()
    sign.text = title_text
    sign.font_size = 36
    sign.position = Vector3(0, 3.46, 3.72)
    sign.modulate = Color("#fff1d8")
    root.add_child(sign)
    _box(root, Vector3(-2.1, 1.65, 3.6), Vector3(1.45, 2.4, 0.16), Color("#68452f"), "Shop door")
    _box(root, Vector3(1.4, 2.0, 3.61), Vector3(3.3, 1.55, 0.12), GLASS, "Shop display window")
    _box(root, Vector3(0, 0.16, 0), Vector3(9.4, 0.32, 7.4), CONCRETE, "Shop foundation")
