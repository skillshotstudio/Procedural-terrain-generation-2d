extends Node2D
#one meter == 150px

# status = complete
# tree_dependent script

#threads
var loopthread = Thread.new()
var loopstartcount = 0
var loopendcount = 0
var endloopthread = false

#preloads
var gravscene = preload("res://scens/map_items/antigravity.scn")
var gem_scene = preload("res://scens/map_items/gem.scn")
var tree_scene = preload("res://scens/map_items/tree.scn")
var coin_scene = preload("res://scens/map_items/coin.scn")
var fuel_scene = preload("res://scens/map_items/fuel_tank.scn")
var nitro_scene = preload("res://scens/map_items/nitro_boost.scn")
var mystrybox_scene = preload("res://scens/map_items/mystry_box.scn")
var stscene = preload("res://scens/map_items/soft_tree.scn")
var poolscene = preload("res://scens/map_items/pool.scn")
var zomscene = preload("res://scens/map_items/zombie.scn")
var house = preload("res://scens/map_items/house.scn")
var box = preload("res://scens/map_items/box.scn")
var barrel = preload("res://scens/map_items/barrel.scn")
var bush = preload("res://scens/map_items/bush.scn")
var bumper = preload("res://scens/map_items/bumper.scn")
var windmill = preload("res://scens/map_items/windmill.scn")
var phase = preload("res://scens/map_items/phaseshift.scn")
var ice = preload("res://scens/map_items/ice_cubes.scn")

#rady
var noise_map = FastNoiseLite.new()

#love u maths <3
@export var seed:int = Global.seed
@export var type:int = Global.type
@export var frequency = Global.frequency
@export var fractals:int = Global.fractals #default value
@export var height_initial:int = Global.height_initial #heighst y value for any point in 1st chunck
@export var height_increment:int = Global.height_increment #increase in irragularity/noise per chunck in pixels
@export var slope:int = Global.slope #slope of map,increment per chunck in pixels, +ve for everest/climb -ve for hell
@export var y_scale:int = Global.y_scale #least y distance
@export var itrations:int = 200 #200 is optimal # no. of points in a chunck,size of for loop
@export var x_scale:int = 50 #minimum distance between adjesent points in a chunck
@export var y_margine:int = 6000 #in pixels #distance between deepest chunck point and chunck vertical ending
var chunck_width = x_scale*itrations

#process veriables
var evenid:int = 0
var line : Line2D
var item_parent:Node
var currentid:int
var point:Vector2
var array = []
var global_vehicle_pos:int
var map_ending = -1500000 #heighest/lowest peak in pixels = 10km
var peak = 1500000 #setting the deepest point
var buffer:int #buffer is minimum distance for a chunck to build using build cycle.
var build_flag = false #triggers base generation
var item_flag = false #triggers item generation
var pointer = -5
var diss:int #collector buffer

func _ready():
	noise_map.seed = seed
	noise_map.noise_type = type
	noise_map.frequency = frequency
	noise_map.fractal_octaves = fractals
	prebuilt(1)
	prebuilt(2)

func loopthreadcall(id):
	if id >= 3:
		if array.size() == 0:
			loopstartcount += 1
			loopstartcount = clamp(loopstartcount,0,2)
			if loopstartcount == 1:
				loopthread.start(generate_array.bind(id))
#				print("thread started")
		if endloopthread == true:
			loopendcount += 1
			loopendcount = clamp(loopendcount,0,2)
			if loopendcount == 1:
				loopthread.wait_to_finish()
#				print("thread ended")
	pass

func generate_array(id): #its called excetly once
	for x in range( (id-1)*itrations,(id*itrations)+1 ):
		var bumps = height_initial + (sqrt(x)*height_increment/itrations) as int
		#print("bumps: ",bumps)
		var y = ((noise_map.get_noise_1d(x)*bumps - (x*slope/itrations))/y_scale) as int
		y = clamp(y,-1500000,1500000)
		var point = Vector2(x*x_scale,y*y_scale)
		var gap = (y*y_scale)+y_margine
		if gap >= map_ending:
			map_ending = gap as int
		var localpeak = y*y_scale
		if localpeak <= peak:
			peak = localpeak
		if array.size() <= itrations:
			array.append(point)
			var ze = x/id
	endloopthread = true

func collector(delta):
	diss = abs(global_vehicle_pos- $collector.position.x) as int
	if diss > 10000:
		$collector.position.x += 43400*delta # 62*700=43400
	elif diss < 10000:
		$collector.position.x += 0

func add_item(item,buffer,parent,vector,replace):
	var object = item.instantiate()
	object.position.x = vector.x
	object.position.y = vector.y-buffer
#	parent.add_child(object)
	item_parent.add_child(object)
	object.name = str(parent.get_child_count())
	if replace == true:
		var index = randi_range(-1,0)
		if index == -1:
			object.set_z_index(-2)
	else:
		pass

func set_item(line,id,parent):
	pointer += 5
	if pointer >= itrations-5:
		item_flag = false
		pointer = -5
		line = null
	if item_flag == true:
		for i in range(pointer,pointer+5):
			var chance = randi_range(0,10000)
			point = line.get_point_position(i)
			if chance in range(1,20):
				add_item(mystrybox_scene,120,parent,point,false)
			#if chance in range(8885,8890):
				#add_item(gravscene,0,parent,point,false)
			if chance in range(300,600):
				add_item(coin_scene,120,parent,point,false)
			if chance in range(600,610):
				add_item(nitro_scene,120,parent,point,false)
			if chance in range(9000,9010+id):
				add_item(gem_scene,150,parent,point,false)
			if chance in range(9020,9050):
				add_item(ice,20,parent,point,false)
			if chance in range(1000,1200):
				add_item(tree_scene,0,parent,point,true)
			if chance in range(7000,7020):
				add_item(stscene,0,parent,point,false)
			if chance in range(50,100):
				add_item(poolscene,0,parent,point,false)
			if chance in range(500,550):
				add_item(house,0,parent,point,false)
			#if chance in range(50,55):
				#add_item(barrel,300,parent,point,true)
			if chance in range(2000,2050):
				add_item(bush,10,parent,point,true)
			#if chance in range(1030,1050):
				#add_item(bumper,0,parent,point,false)
			if chance in range(1200,1240):
				add_item(windmill,0,parent,point,false)
	pass

func prebuilt(id): #must be called twice
	for x in range( (id-1)*itrations,(id*itrations)+1 ):
		var bumps = height_initial + (sqrt(x)*height_increment/itrations) as int
		#print("bumps: ",bumps)
		var y = ((noise_map.get_noise_1d(x)*bumps - (x*slope/itrations))/y_scale) as int
		y = clamp(y,-1500000,1500000)
		var point = Vector2(x*x_scale,y*y_scale)
		var gap = (y*y_scale)+y_margine
		if gap >= map_ending:
			map_ending = gap as int
		var localpeak = y*y_scale
		if localpeak <= peak:
			peak = localpeak
		if array.size() <= itrations:
			array.append(point)
	generate_base(id)

func generate_items():
	if item_flag == true:
		set_item(line,currentid,item_parent)
	pass

func generate_base(id):
	var chunck = preload("res://scens/maps/chunck.scn").instantiate()
	chunck_width = x_scale*itrations
	chunck.name = str(id)
	
	var Line = chunck.find_child("main_line") as Line2D
	Line.points = array
	
	array.push_back(Vector2(chunck_width*id,map_ending))
	array.push_back(Vector2(chunck_width*(id-1),map_ending))
#	print(map_ending)
	
	var polygon = chunck.find_child("main_polygon") as Polygon2D
	polygon.polygon = array
	var collider = chunck.find_child("collider") as CollisionPolygon2D
	#collider.polygon = array
	var collider2 = chunck.find_child("collider2") as CollisionPolygon2D
	#collider2.polygon = array
	var area = chunck.find_child("ac") as CollisionPolygon2D
	#area.polygon = array
	
	var line_buffer = Geometry2D.offset_polyline(Line.points,Line.width/10)
	for small_polygones in line_buffer:
		#collider.polygon = small_polygones
		collider2.polygon = small_polygones
		area.polygon = small_polygones
	$chuncks.add_child(chunck) # add chunck
	
	currentid = id
	line = Line
	item_parent = chunck.find_child("items") as Node
	
	var Evenid = id/2 as int
	if Evenid > evenid:
		add_item(fuel_scene,200,item_parent,Line.get_point_position(200),false)
#		print("fuel added at: ",id)
	
	array.clear()
	evenid = id/2
	map_ending = -1500000
	loopstartcount = 0
	loopendcount = 0
	endloopthread = false
	if $chuncks.get_child_count() >= 4: #total child count = 3
		$chuncks.get_child(0).queue_free()
	build_flag = false
	item_flag = true

func called(delta):
	global_vehicle_pos = $"../../player".vehicle_position as int 
#	print(global_vehicle_pos)
	var pin_name = str_to_var($chuncks.get_child(-1).name)
	var id = pin_name+1
	buffer = abs(global_vehicle_pos-(pin_name)*chunck_width) as int
	loopthreadcall(id) # called every frame
	if id >=3:
		generate_items() # called every frame
	if buffer < chunck_width:
		build_flag = true
	elif buffer >= chunck_width:
		build_flag = false
	if build_flag == true:
		generate_base(id)
		pass

func _process(delta):
	called(delta)
	collector(delta)
	pass

