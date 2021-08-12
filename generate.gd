tool

extends Sprite

export(bool) var running = false setget set_running
export(int) var number setget set_number

func set_number(value):
	number = value
	texture = generate_texture(value)
		
func set_running(value):
	running = value
	if running:
		set_number(randi() % (1 << 32))
		property_list_changed_notify()
		running = false
		
func get_bit(byte : int, n) -> bool:
	return (byte & (1 << n)) >> n

#Can edit into an 8 color match statement
func get_color(input: int) -> Color:
	return Color(float(bool(input & 1 << 2)), float(bool(input & 1 << 1)), float(bool(input & 1 << 0)))
	
func color_to_byte_array(input: Color) -> Array:
	var bytes : int = input.to_rgba32()
	return [
		(bytes & (0xff000000)) >> 24,
		(bytes & (0x00ff0000)) >> 16,
		(bytes & (0x0000ff00)) >> 8,
		(bytes & (0x000000ff))
	]
		
func generate_texture(byte : int) -> ImageTexture:
	var rotated : bool = bool(byte & (1 << 31))
	var color : Color = get_color((byte & ((1 << 30) + (1 << 29) + (1 << 28))) >> 28)
	var color_array : Array = color_to_byte_array(color)
	var clear_array : Array = color_to_byte_array(Color.transparent)
	
	var data: Array = []

	if rotated:
		for x in [0, 1, 2, 3, 2, 1, 0]:
			for y in range(6, -1, -1):
				data.append_array(color_array if get_bit(byte, 27 - x - y*4) else clear_array)
	else: 
		for y in range(7):
			for x in [0, 1, 2, 3, 2, 1, 0]:
				data.append_array(color_array if get_bit(byte, 27 - x - y*4) else clear_array)
			
	var image: Image = Image.new()
	image.create_from_data(7, 7, false, Image.FORMAT_RGBA8, data)
	var image_texture: ImageTexture = ImageTexture.new()
	image_texture.create_from_image(image, 0)
	return image_texture
