extends Sprite

const STRETCH_MODES = [
	['disabled', SceneTree.STRETCH_MODE_DISABLED],
	['2d', SceneTree.STRETCH_MODE_2D],
	['viewport', SceneTree.STRETCH_MODE_VIEWPORT],
]
const STRETCH_ASPECTS = [
	['ignore', SceneTree.STRETCH_ASPECT_IGNORE],
	['keep', SceneTree.STRETCH_ASPECT_KEEP],
	['keep_width', SceneTree.STRETCH_ASPECT_KEEP_WIDTH],
	['keep_height', SceneTree.STRETCH_ASPECT_KEEP_HEIGHT],
	['expand', SceneTree.STRETCH_ASPECT_EXPAND],
]
const NUM_STEPS = 12

# Size of window manager decorations
var BASE_SIZE = Vector2(320, 180)
var AMPLITUDE = 0.3
var MAX_SIZE = Vector2(ceil(BASE_SIZE.x * (1 + AMPLITUDE)), ceil(BASE_SIZE.y * (1 + AMPLITUDE)))
var TOP_LEFT = Vector2(2, 18)
var BOTTOM_RIGHT = Vector2(2, 2)
var GIF_MARGIN = 10

func _ready():
	run()

func run():
	for stretch_mode in STRETCH_MODES:
		for stretch_aspect in STRETCH_ASPECTS:
			get_tree().set_screen_stretch(stretch_mode[1], stretch_aspect[1], Vector2(16, 9), 1)
			OS.set_window_title('Mode = %s, Aspect = %s' % [stretch_mode[0], stretch_aspect[0]])
			var png_files = []
			for step in range(-1, NUM_STEPS):
				var phi = float(step) / NUM_STEPS * 2 * PI
				OS.window_size = BASE_SIZE * Vector2(1 - AMPLITUDE * sin(phi), 1 + AMPLITUDE * sin(phi))
				
				# There is noticeable flicker upon resizing the window. Wait for it to settle down.
				yield(get_tree().create_timer(0.4), 'timeout')
				
				if step >= 0:
					var pos = OS.window_position - TOP_LEFT
					var size = OS.window_size + TOP_LEFT + BOTTOM_RIGHT
					var crop = '%dx%d+%d+%d' % [size.x, size.y, pos.x, pos.y]
					var png_file = 'pngs/%s_%s_%02d.png' % [stretch_mode[0], stretch_aspect[0], step]
					OS.execute('/usr/bin/import', ['-window', 'root', '-crop', crop, '+repage', png_file], true)
					png_files.append(png_file)
			
			var convert_args = [
				'-repage', '440x274+10+10',
				'-background', '#008080',
				'-dispose', 'Previous',
				'-delay', '25',
				'-loop', '0',
				'-layers', 'Optimize',
			]
			for png_file in png_files:
				convert_args.push_back(png_file)
			var gif_file = 'gifs/stretch_%s_%s.gif' % [stretch_mode[0], stretch_aspect[0]]
			convert_args.push_back(gif_file)
			print('Creating %s...' % [gif_file])
			OS.execute('/usr/bin/convert', convert_args, true)

func _unhandled_input(event):
	if event is InputEventKey and event.is_pressed() and event.scancode == KEY_ESCAPE:
		get_tree().quit()