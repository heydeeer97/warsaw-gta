
extends Node3D

var player: CharacterBody3D
var camera: Camera3D
var move_direction := Vector2.ZERO
var jump_requested := false

const SPEED := 6.0
const GRAVITY := 18.0
const JUMP := 6.0

func _ready():
    create_environment()
    create_ground()
    create_city()
    create_player()
    create_controls()

func create_environment():
    var env = WorldEnvironment.new()
    var environment = Environment.new()
    environment.background_mode = Environment.BG_SKY
    environment.sky = Sky.new()
    environment.sky.sky_material = ProceduralSkyMaterial.new()
    environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
    env.environment = environment
    add_child(env)

    var sun = DirectionalLight3D.new()
    sun.rotation_degrees = Vector3(-45, -30, 0)
    sun.shadow_enabled = true
    add_child(sun)

func create_ground():
    var ground = StaticBody3D.new()

    var mesh = MeshInstance3D.new()
    var plane = PlaneMesh.new()
    plane.size = Vector2(220, 220)
    mesh.mesh = plane

    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.20, 0.25, 0.20)
    mesh.material_override = mat
    ground.add_child(mesh)

    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(220, 1, 220)
    collision.shape = shape
    collision.position.y = -0.5
    ground.add_child(collision)

    add_child(ground)

func create_city():
    var colors = [
        Color(0.7, 0.65, 0.55),
        Color(0.6, 0.65, 0.7),
        Color(0.8, 0.75, 0.65),
        Color(0.5, 0.55, 0.6)
    ]

    for x in range(-3, 4):
        for z in range(-3, 4):

            if abs(x) <= 1 and abs(z) <= 1:
                continue

            var height = randf_range(8, 20)
            var building = StaticBody3D.new()

            building.position = Vector3(
                x * 19,
                height / 2,
                z * 19
            )

            var mesh = MeshInstance3D.new()
            var box = BoxMesh.new()
            box.size = Vector3(12, height, 12)
            mesh.mesh = box

            var mat = StandardMaterial3D.new()
            mat.albedo_color = colors.pick_random()
            mesh.material_override = mat
            building.add_child(mesh)

            var collision = CollisionShape3D.new()
            var shape = BoxShape3D.new()
            shape.size = box.size
            collision.shape = shape
            building.add_child(collision)

            add_child(building)

func create_player():
    player = CharacterBody3D.new()
    player.name = "Player"
    player.position = Vector3(0, 1, 0)

    var body = MeshInstance3D.new()
    var capsule = CapsuleMesh.new()
    capsule.height = 1.8
    capsule.radius = 0.4
    body.mesh = capsule
    body.position.y = 0.9

    var mat = StandardMaterial3D.new()
    mat.albedo_color = Color(0.1, 0.25, 0.8)
    body.material_override = mat
    player.add_child(body)

    var collider = CollisionShape3D.new()
    var shape = CapsuleShape3D.new()
    shape.height = 1.8
    shape.radius = 0.4
    collider.shape = shape
    collider.position.y = 0.9
    player.add_child(collider)

    camera = Camera3D.new()
    camera.position = Vector3(0, 3, 7)
    camera.rotation_degrees.x = -15
    camera.current = true
    player.add_child(camera)

    add_child(player)

func _physics_process(delta):
    if not player:
        return

    if not player.is_on_floor():
        player.velocity.y -= GRAVITY * delta
    elif jump_requested:
        player.velocity.y = JUMP

    jump_requested = false

    var input_dir = move_direction

    if Input.is_key_pressed(KEY_W):
        input_dir.y = -1
    elif Input.is_key_pressed(KEY_S):
        input_dir.y = 1

    if Input.is_key_pressed(KEY_A):
        input_dir.x = -1
    elif Input.is_key_pressed(KEY_D):
        input_dir.x = 1

    var direction = Vector3(input_dir.x, 0, input_dir.y).normalized()

    player.velocity.x = direction.x * SPEED
    player.velocity.z = direction.z * SPEED

    if direction.length() > 0:
        player.rotation.y = atan2(direction.x, direction.z)

    player.move_and_slide()

func create_controls():
    var layer = CanvasLayer.new()
    add_child(layer)

    var panel = HBoxContainer.new()
    panel.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
    panel.position = Vector2(20, -110)
    panel.size = Vector2(350, 90)
    panel.add_theme_constant_override("separation", 8)
    layer.add_child(panel)

    add_button(panel, "◀", Vector2(-1, 0))
    add_button(panel, "▲", Vector2(0, -1))
    add_button(panel, "▼", Vector2(0, 1))
    add_button(panel, "▶", Vector2(1, 0))

    var jump = Button.new()
    jump.text = "JUMP"
    jump.position = Vector2(0, 0)
    jump.custom_minimum_size = Vector2(100, 75)
    jump.pressed.connect(func():
        jump_requested = true
    )
    panel.add_child(jump)

func add_button(parent, caption, direction):
    var button = Button.new()
    button.text = caption
    button.custom_minimum_size = Vector2(65, 75)

    button.button_down.connect(func():
        move_direction = direction
    )

    button.button_up.connect(func():
        move_direction = Vector2.ZERO
    )

    parent.add_child(button)
