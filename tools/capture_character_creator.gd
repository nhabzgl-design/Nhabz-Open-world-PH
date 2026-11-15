extends SceneTree

func _initialize() -> void:
    call_deferred("_capture_preview")

func _capture_preview() -> void:
    var packed := load("res://scenes/Main.tscn") as PackedScene
    if packed == null:
        push_error("Could not load Main.tscn")
        quit(1)
        return

    var scene := packed.instantiate()
    root.add_child(scene)
    await process_frame

    var onboarding := scene.get_node_or_null("Onboarding")
    if onboarding == null:
        push_error("Onboarding node is missing")
        quit(1)
        return

    onboarding.call("_show_creator")
    for i in range(12):
        await process_frame

    var viewport_image := root.get_viewport().get_texture().get_image()
    var save_error := viewport_image.save_png("character_creator_preview.png")
    if save_error != OK:
        push_error("Failed to save preview image: " + str(save_error))
        quit(1)
        return

    print("Saved character_creator_preview.png")
    quit(0)
