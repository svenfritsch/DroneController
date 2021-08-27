extends Area2D

# Detect the input that has not been handled by ANY other input handlers
# http://docs.godotengine.org/en/stable/learning/features/inputs/inputevent.html
func _input_event(viewport, event, shape_idx):
	# Detect a left mouse click
	# http://docs.godotengine.org/en/stable/classes/class_inputevent.html
	if event.type == InputEvent.MOUSE_BUTTON:
		if event.button_index == BUTTON_LEFT and event.pressed:
			
			# Note that the code below using the get_tree().set_input_handled() method won't help us
			# here because the CollisionObject._input_event(...) notifications are all sent out
			# as a batch (i.e. they are all receiving the same copy of the event data at once).
			# Therefore, you cannot prevent future iterations of _input_event from picking up
			# the event. If you wished to prevent CollisionObject._input_event from triggering
			# after some other nodes' _input(ev), Control._input_event(ev), or _unhandled_input(ev)
			# notification, THEN you would want to simply call get_tree().set_input_handled()
			# (no need to even check is_input_handled() in that case).
			# if get_tree().is_input_handled():
				# get-tree().set_input_handled()
			
			# Without the ability to detect it from the input handling side, we must detect draw order
			# from the arrangement of the nodes in the environment (as best as I can tell).
			# ^ Would be great if someone could prove me wrong on this point as I'm not 100% sure.
			# Note that by default, nodes are rendered in the order of their being a child, i.e.
			# world
			# - child1
			# - child2
			# => child1 will be rendered first, then child2 will be rendered on top of child1 (so child2 is visible)
			# You can confirm this by hiding the visibility (click the "eye" icon next to the node) of the "bottom" node
			# and observing how "bottom" disappears from view)
			
			# You can statically define an ordering at design-time using the Z property on Node2D.
			# It is NOT runtime-updated with whatever the "most visible" Node2D is.
			# As such, the "left" and "right" nodes both report a "z" of 0, which is the default.
			# For the "yleft" and "yright" nodes, we have a YSort node that is manually drawing the nodes
			# relative to their Y positions (further down the screen, i.e. higher Y, means rendered on top).
			# I specifically set the "z" of yright to be greater even though it is higher up to illustrate
			# how its rendering order is "overriding" the YSort behavior because of its "z" value. It shows
			# up on top of "yleft" despite the fact that "yleft" is positioned at a lower elevation / higher Y value.
			print(get_parent().get_name())
			
			# Also note how, based on the ordering of this print statement when clicking on overlapped areas,
			# even though we overrode the default ordering using "z" for the YSort, we still can't guarantee
			# that the top-visibility node's _input_event function will execute prior to other one's. The
			# _input_event functions are received in the order of child relationship (yleft's _input_event
			# triggers before yright's because yleft.get_index() < yright.get_index()). Notice also that nonybottom
			# triggers before both of them because it's parent "Node1" is processing the event first and cascading
			# it down to its children prior to allowing the next child, YSort, to begin its cascading input handlers.
			
			# This would appear to show an inconsistency in the tree flow between input handling and draw order (?):
			# Input handling is working in a cascading, children-first model whereas the draw order is happening
			# level-by-level from shallow to deep, and in child order after that.
			
			# The most efficient way to only do something with the top-most node is to figure out which one
			# it is, and then skip the content for the other nodes by checking for some common comparison value.
			# It seems as though the nodes are rendered from most shallow to most deep since "bottom" is rendering
			# on top of "left" and "right even though it comes before them both in child ordering of "world".
			# This doesn't appear to be the case with the YSort'd "yleft" and "yright" nodes which are rendering
			# themselves AROUND the non-y-bottom node which rests between them but is not part of the YSort children.
			# I would attribute this to the YSort taking into account other nodes' Y position in the vicinity, and not
			# anything related to the "nonybottom" node's "z" value, child-ordering, depth, or anything of that sort.
			
			# Get an Array with a list of all areas, NOT INCLUDING THIS ONE, that
			# also are overlapping with this Area2D
			var areas = get_overlapping_areas()
			
			# Get a list that has all of the areas we are examining
			areas.append(self)
			
			# A variable for the area that we actually want to have DO something, i.e. the top-most visible
			# one that we have clicked on.
			var desired_area = null
			
			# Cycle through each area in this list
			for area in areas:
				print(area.get_parent().get_name())
				# Here, you have to decide how you want to compare all of the areas
				# You could compare their get_z() values if you have set them in the editor
				# You could compare their depth in the tree by doing something like...
				# get_script().get_path().replace("res://","").split("/").size()
				# ^ not sure if that's quite right, but you get the idea.
	
	# What might be the simplest way to handle it is to rely on the input handlers of Control nodes
	# to catch what the top-most click is for you, but for that you would need an invisible TextureButton that follows
	# your Sprite around and uses the same texture as a mask somehow (so that clicking right outside
	# of the Sprite's Texture doesn't result in an input handler callback).
	# If it's a non-moving image, you can just use a TextureButton for this and use set_click_mask(BitMap mask) to 
	# define the region that should be clickable, then set the alpha of the texture to be 0 so that it is not visible,
	# but will still pick up clicks (I'm not 100% sure if setting hidden/visible/visibility/whatever to not visible will
	# allow clicks to still be picked up).
	# This doesn't appear to be perfectly possible for animated images without some sort of streaming texture to use as
	# a bitmask (not even sure how that would work).
	# Regardless Godot 2.1 doesn't appear to have any visual streaming textures like Godot 3.0 does.
