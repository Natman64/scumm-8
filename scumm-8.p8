pico-8 cartridge // http://www.pico-8.com
version 10
__lua__

-- scumm-8
-- paul nicholas

-- debugging
show_debuginfo = false
show_collision = false
show_perfinfo = true
enable_mouse = true

-- game verbs (used in room definitions and ui)
verbs = {
	--verb, name, bounds{},
	{"open", "open"},
	{"close", "close"},
	{"give", "give"},
	{"pickup", "pick-up"},
	{"lookat", "look-at"},
	{"talkto", "talk-to"},
	{"push", "push"},
	{"pull", "pull"},
	{"use", "use"}
}
verb_default = {"walkto", "walk to"} -- verb to use when just clicking aroung (e.g. move actor)
verb_maincol = 12  -- main color (lt blue)
verb_hovcol = 7   -- hover color (white)
verb_shadcol = 1   -- shadow (dk blue)
verb_defcol = 10    -- default action (yellow)

-- object states
state_closed = "closed"
state_off = "off"
state_here = "here"
state_open = "open"
state_on = "on"
state_gone = "gone"

-- object classes
class_untouchable = "untouchable" -- will not register when the cursor moves over it. the object is invisible to the user.
class_pickupable = "pickupable"   -- can be placed in actor inventory



-- #######################################################
-- actor definitions
-- 

face_front = 1	-- states for actor direction
face_left = 2   -- (not sprite #'s)
face_back = 3		
face_right = 4

pos_infront = 1 
pos_behind = 3
pos_left = 2
pos_right = 4
pos_inside = 5

-- actor animations
anim_face = 1	 -- position the actor immediately to the direction indicated
anim_turn = 2  -- show the turning stages of animation


main_actor = { 		-- initialize the actor object
	x = 127/2 - 16,
	y = 127/2 -16,
	sprw = 1,
	sprh = 4,
	face_dir = face_front, 	-- direction facing
	idle = {1,3,73,3},	-- sprites for idle (front, back, left) - right=flip
	walk_anim = {2,3,4,3},
	flip = false, 		-- used for flipping the sprite (left/right dir)
	col = 12,				-- speech text colour
	trans_col = 11,
	speed = 0.75,  	-- walking speed
	moving = 0, 		-- 0=stopped, 1=walking, 2=arrived
	tmr = 1, 				-- internal timer for managing animation
	anim_pos = 1, 	-- used to track anim pos
	inventory = {
		-- object1,
		-- object2
	}
}

-- set which actor the player controls by default
selected_actor = main_actor

-- #######################################################
-- room definitions
-- 
first_room = {
	map = {
		x = 0,
		y = 0,
		w = 16,	-- default these?
		h = 8	-- 
	},
	--sounds = {},
	--costumes = {},
	enter = function()
		-- animate fireplace
		while true do		
			set_state("fire", "frame1")
			break_time(8)
			set_state("fire", "frame2")
			break_time(8)
			set_state("fire", "frame3")
			break_time(8)
		end
	end,
	exit = function()
		-- todo: anything here?
	end,
	lighting = 0, -- state of lights in current room
	scripts = {	  -- scripts that are at room-level
		move_bozo = function()
			while true do		
				set_state("bozo", "frame1")
				break_time(8)
				set_state("bozo", "frame2")
				break_time(8)
				set_state("bozo", "frame1")
				break_time(8)
				set_state("bozo", "frame3")
				break_time(8)
				set_state("bozo", "frame3")
				break_time(8)
			end
		end
	},		
	objects = {
		fire = {
			name = "fire",
			state = "frame1",
			x = 8*8, -- (*8 to use map cell pos)
			y = 4*8,
			states = {
				-- states are spr values
				frame1 = 23, 
				frame2 = 24,
				frame3 = 25
			},
			w = 1,	-- relates to spr or map cel, depending on above
			h = 1,  --
			transcol = 0,
			--use_pos (defaults to spr bottom)
			use_dir = face_back,
			use_pos = pos_infront,
			--[dependent-on object-name being object-state]

			verbs = {
				lookat = function()
					say_line(selected_actor, "it's a nice, warm fire...")
					wait_for_message()
					break_time(10)
					do_anim(selected_actor, anim_turn, face_front)
					--selected_actor.face_dir = actor_face_front
					say_line(selected_actor, "ouch! it's hot!;*stupid fire*")
					wait_for_message()
				end,
				talkto = function()
					say_line(selected_actor, "'hi fire...'")
					wait_for_message()
					break_time(10)
					do_anim(selected_actor, anim_turn, face_front)
					say_line(selected_actor, "the fire didn't say hello back;burn!!")
					wait_for_message()
				end
			}
		},
		front_door = {
			name = "front door",
			--dependent_on = "closet-door",
			--dependent_on_state = state_closed,
			state = state_closed,
			x = 1*8, -- (*8 to use map cell pos)
			y = 2*8,
			states = {
				-- states are spr values
				closed = 15, -- state_closed
				open = 0 -- state_open
			},
			flip_x = false, -- used for flipping the sprite
			flip_y = false,
			w = 1,	-- relates to spr or map cel, depending on above
			h = 4,  --
			use_pos = pos_right,
			verbs = {
				walkto = function(me)
					printh("me = "..type(me))
					if state_of(me) == state_open then
						-- go to new room!
						come_out_door(second_room.objects.back_door, second_room)
					else
						say_line(selected_actor, "the door is closed")
					end
				end,
				open = function(me)
					if (isnull(me)) printh("me is null!")
					printh("me = "..me.name)
					if state_of(me) == state_open then
						say_line(selected_actor, "it's already open!")
					else
						set_state(me, state_open)
					end
				end,
				close = function()
					set_state(me, state_closed)
				end
			}
		},
		hall_door_kitchen = {
			name = "kitchen",
			state = state_open,
			--[[states = {
				open = 15 -- state_open
			},]]
			x = 14 *8, -- (*8 to use map cell pos)
			y = 2 *8,
			w = 1,	-- relates to spr or map cel, depending on above
			h = 4,  --
			use_pos = pos_left,
			verbs = {
				walkto = function()
					-- go to new room!
					--change_room(second_room)
					come_out_door(second_room.objects.kitchen_door_hall, second_room) -- ()
				end
			}
		},
		bat = {
			name = "bat",
			class = class_pickupable,
			state = state_closed,
			x = 13 *8, -- (*8 to use map cell pos)
			y = 6 *8,
			w = 1,	-- relates to spr or map cel, depending on above
			h = 1,  --
			states = {
				-- states are spr values
				closed = 239 -- state_closed
				--open = 0 -- state_open
			},
			--owner (set on pickup)
			--[dependent-on object-name being object-state]
			--class is class-state [class-state]  (e.g. untouchable = invisible + non-collidable)
			verbs = {
				lookat = function()
					if owner_of("bat") == selected_actor then
						say_line(selected_actor, "it is a bat in my pocket!")
					else
						say_line(selected_actor, "it is a bat!")
					end
				end,
				pickup = function()
					printh("b4 pickup")
					pickup_obj("bat")
				end,
				use = function()
					if (noun2_curr.name == "window") then
						set_state("window", state_open)
					end
				end
			}
		},
		bozo = {
			name = "bozo",
			state = "frame1",
			x = 2*8, -- (*8 to use map cell pos)
			y = 6*8,
			states = {
				-- states are spr values
				frame1 = 64, 
				frame2 = 65,
				frame3 = 66
			},
			w = 1,	-- relates to spr or map cel, depending on above
			h = 1,  --
			verbs = {
				push = function()
					if script_running(room_curr.scripts.move_bozo) then
						stop_script(room_curr.scripts.move_bozo)
						set_state(me, "frame1")
					else
						start_script(room_curr.scripts.move_bozo)
					end
				end,
				pull = function()
					stop_script(room_curr.scripts.move_bozo)
					set_state(me, "frame1")
				end
			}
		},
		window = {
			name = "window",
			state = state_closed,
			x = 4*8, -- (*8 to use map cell pos)
			y = 1*8,
			w = 2,	-- relates to spr or map cel, depending on above
			h = 2,  --
			states = {
				-- states are spr values
				closed = 80, -- state_closed
				open = 82 -- state_open
			}
		}
	}
}

second_room = {
	map = {
		x = 16,
		y = 0,
		w = 24,	-- default these?
		h = 8	-- 
	},
	enter = function()
		-- todo: anything here?
	end,
	exit = function()
		-- todo: anything here?
	end,
	scripts = {	  -- scripts that are at room-level
	},
	objects = {
		kitchen_door_hall = {
			name = "hall",
			state = state_open,
			x = 1 *8, -- (*8 to use map cell pos)
			y = 2 *8,
			w = 1,	-- relates to spr or map cel, depending on above
			h = 4,  --
			use_pos = pos_right,
			verbs = {
				walkto = function()
					-- go to new room!
					--change_room(second_room)
					come_out_door(first_room.objects.hall_door_kitchen, first_room)
				end
			}
		},
		back_door = {
			name = "back door",
			--dependent_on = "closet-door",
			--dependent_on_state = state_closed,
			state = state_closed,
			x = 22*8, -- (*8 to use map cell pos)
			y = 2*8,
			states = {
				-- states are spr values
				closed = 15, -- state_closed
				open = 0 -- state_open
			},
			flip_x = true, -- used for flipping the sprite
			flip_y = false,
			w = 1,	-- relates to spr or map cel, depending on above
			h = 4,  --
			use_pos = pos_left,
			verbs = {
				walkto = function(me)
					printh("me = "..type(me))
					if state_of(me) == state_open then
						-- go to new room!
						come_out_door(first_room.objects.front_door, first_room)
					else
						say_line(selected_actor, "the door is closed")
					end
				end,
				open = function(me)
					printh("me = "..me.name)
					if state_of(me) == state_open then
						say_line(selected_actor, "it's already open!")
					else
						set_state(me, state_open)
						default_verb = "close"
					end
				end,
				close = function()
					set_state(me, state_closed)
					default_verb = "open"
				end
			}
		},
	},
}


-- set which room to start the game in 
-- (could be a "pseudo" room for title screen!)
selected_room = first_room
--selected_room = second_room

-- logic used to determine a "default" verb to use
-- (e.g. when you right-click an object)
function find_default_verb(obj)
  local default_verb = nil
	-- look for verbs in the following order of priority
	local verb_ordered_list = {
		"open", "close", "talkto", "lookat", "push", "pull"
	}

	for v in all(verb_ordered_list) do
		-- if object supports current verb
	  if valid_verb(v, obj) then
			-- check for reasons not to use this verb
			if (v == "open" and obj.state != state_closed) 
			or (v == "close" and obj.state != state_open)
			--or (v == "talkto" and obj.class == class_actor!!!)
			--or (v == "lookat")
			then
				-- not suitable ver, continue
			else
				-- found default verb
				default_verb = v
				break
			end
		end
	end
	-- now find the full verb definition
	for v in all(verbs) do
		if (v[1] == default_verb) default_verb=v break
	end
	return default_verb
end















-- #######################################################
-- internal scumm-8 workings
-- 


-- global vars
--scene=1
screenwidth = 127
screenheight = 127
stage_top = 16

-- offset to display speech above actors (dist in px from their feet)
text_offset = (selected_actor.sprh-1)*8

cam = {
	x = 0,
	max = 0, -- the maximum x position the camera can move to in the current room
	min = 0,  -- the minimum x position the camera can move to in the current room
	mode = 0, -- 0=follow, 1=static, 2=pan-to
	following_actor = selected_actor,
	-- pan_to_x=0
	-- pan_to_y=0
}

cursor = {
  x = screenwidth/2,
  y = screenheight/2,
	i = 1, -- for cutscenes (<=0 - disable cursor)
  tmr = 0, -- used to animate cursor col
  cols = {7,12,13,13,12,7},
  colpos = 1 
}
-- keeps reference to currently hovered items
-- e.g. objects, ui elements, etc.
hover_curr = {
	-- verb, 
	-- default_verb,
	-- object, 
	-- ui_arrow
}
last_mouse_x = 0
last_mouse_y = 0
-- wait for button release before repeating action
ismouseclicked = false

room_curr = nil			-- contains the current room definition
room_stash = nil		-- contains the "paused" room before cutscene(s)
verb_curr = nil 		--verb_default
noun1_curr = nil 		-- main/first object in command
noun2_curr = nil 		-- holds whatever is used after the preposition (e.g. "with <noun2>")
cmd_curr = "" 			-- contains last displayed or actioned command
executing_cmd = false
dialog_curr = nil 	-- {x,y,col}
--me = nil 						-- same as noun1_curr (to make scripting easier)

global_scripts = {}	-- table of scripts that are at game-level
local_scripts = {}	-- table of scripts that are actively running





-- game loop

function _init()
-- this function runs as soon as the game loads
	
	-- use mouse input?
	if (enable_mouse) poke(0x5f2d, 1)

	-- load the initial room
	change_room(selected_room)
end

function _update60()  -- _update()
	gameupdate()
end

function _draw()
	gamedraw()
end

-- update functions

function gameupdate()
	-- process selected_actor threads/actions
	if selected_actor.thread and not coresume(selected_actor.thread) then
		selected_actor.thread = nil
	end

	--printh("#scripts="..#local_scripts)
	-- update all the active scripts
	-- (will auto-remove those that have ended)
	for scr_obj in all(local_scripts) do
		if scr_obj[2] and not coresume(scr_obj[2], scr_obj[3]) then
			del(local_scripts, scr_obj)
			scr_obj = nil
		end
	end

	-- player/ui control
	playercontrol()

	-- check for collisions
	checkcollisions()
end


function gamedraw()
	--local gametxt = "game screen"

	-- clear screen every frame?
	rectfill(0,0,screenwidth, screenheight, 0)

	-- move camera
	--printh("cam.x:"..cam.x)
	cam.x = mid(0, selected_actor.x - 64, (room_curr.map.w*8)-screenwidth-1)
	camera(cam.x, 0)

	-- clip room bounds
	clip(0, stage_top, screenwidth, 64)

	-- draw room (bg + objects + actors)
	roomdraw()

	-- reset camera for "static" content
	camera(0,0)
	-- reset clip
	clip()

	-- draw active dialog
	dialogdraw()

	-- draw current command (verb/object)
	commanddraw()

	-- draw ui and inventory
	uidraw()

	cursordraw()

	if (show_perfinfo) print("cpu: "..stat(1), 0, stage_top - 16, 8) print("mem: "..stat(0), 0, stage_top - 8, 8)
	if (show_debuginfo) print("x: "..cursor.x.." y:"..cursor.y, 80, stage_top - 8, 8)
	
end


-- handle button inputs
function playercontrol()	
	-- 
	if (btn(0)) cursor.x-=1 
	if (btn(1)) cursor.x+=1 
	if (btn(2)) cursor.y-=1
	if (btn(3)) cursor.y+=1

	if (btnp(4)) input_button_pressed(1) 
	if (btnp(5)) input_button_pressed(2)

	-- only update position if mouse moved
	if (enable_mouse) then	
		if (stat(32)-1 != last_mouse_x) cursor.x = stat(32)-1	-- mouse xpos
		if (stat(33)-1 != last_mouse_y) cursor.y = stat(33)-1	-- mouse ypos
		-- don't repeat action if same press/click
		if (stat(34) > 0) then
			if (not ismouseclicked) then
				input_button_pressed(stat(34))
				ismouseclicked = true
			end
		else
			ismouseclicked = false
		end
		-- store for comparison next cycle
		last_mouse_x = stat(32)-1
		last_mouse_y = stat(33)-1
	end

	-- keep cursor within screen
	cursor.x = max(cursor.x, 0)
	cursor.x = min(cursor.x, 127)
	cursor.y = max(cursor.y, 0)
	cursor.y = min(cursor.y, 127)
end

-- 1 = z/lmb, 2 = x/rmb, (4=middle)
function input_button_pressed(button_index)	

	local verb_in = verb_curr

	for k,h in pairs(hover_curr) do
		if type(h) != nil then
			-- found something being hovered...
			if k == "verb" then
				verb_curr = h
				printh("verb = "..h[1])
				break
			elseif k == "object" then
				-- if valid obj, complete command
				-- else, abort command (clear verb, etc.)
				if button_index == 1 then
					if verb_curr[1] == "use" and notnull(noun1_curr) then
						noun2_curr = h
						printh("noun2_curr = "..noun2_curr.name)					
					else
						noun1_curr = h
						--me = noun1_curr
						printh("noun1_curr = "..noun1_curr.name)
					end
				elseif (notnull(hover_curr.default_verb)) then
					-- perform default verb action (if present)
					verb_curr = hover_curr.default_verb
					noun1_curr = h
					--me = noun1_curr
					-- force repaint of command (to reflect default verb)
					commanddraw()	
					break
				end
				break
			elseif k == "ui_arrow" then
				-- todo: ui arrow clicked...
				break
			--[[elseif k == "inv_object" then
				-- todo: inventory object clicked
				break]]
			else
				-- what else could there be? actors!?
			end
		end
	end

	-- attempt to use verb on object
	if (noun1_curr != nil) then
		-- are we starting a 'use' command?
		if verb_curr[1] == "use" then
			if notnull(noun2_curr) then
				-- 'use' part 2
			else
				-- 'use' part 1 (e.g. "use hammer")
				-- wait for noun2 to be set
				return
			end
		end

		-- execute verb script
		executing_cmd = true
		selected_actor.thread = cocreate(function(actor, obj, verb)
			if isnull(obj.owner) then
				-- todo: walk to use pos and face dir
				if (notnull(obj.use_pos)) printh("obj use_pos="..obj.use_pos)
				printh("obj x="..obj.x..",y="..obj.y)
				printh("obj w="..obj.w..",h="..obj.h)
				dest_pos = get_use_pos(obj)

				walk_to(selected_actor, dest_pos.x, dest_pos.y)
				-- default use direction
				use_dir=selected_actor.face_dir
				--use_dir=face_back
				if (notnull(obj.use_dir)) use_dir = obj.use_dir
				--if (verb == verb_default) use_dir=selected_actor.face_dir	-- face obj (unless walking)
				
				-- anim to use dir
				do_anim(selected_actor, anim_turn, use_dir)
			end
			-- does current object support active verb?
			if valid_verb(verb,obj) then
				-- finally, execute verb script
				printh("verb_obj_script!")
				printh("verb = "..verb[1])
				printh("obj = "..obj.name)
				start_script(obj.verbs[verb[1]], obj)
			elseif verb[1] != verb_default[1] then
				say_line(selected_actor, "i don't think that will work")
			end
			-- clear current command
			--break_time(5)
			clear_curr_cmd()
		end)
		coresume(selected_actor.thread, selected_actor, noun1_curr, verb_curr)
	elseif (cursor.y > stage_top and cursor.y < stage_top+64) then
		-- in map area
		executing_cmd = true
		-- attempt to walk to target
		selected_actor.thread = cocreate(function(x,y)
			walk_to(selected_actor, x, y)
			-- clear current command
			--break_time(5)
			clear_curr_cmd()
		end)
		coresume(selected_actor.thread, cursor.x, cursor.y - stage_top)
	end

	printh("--------------------------------")
end

-- collision detection
function checkcollisions()
	-- reset hover collisions
	hover_curr = {}

	-- check room/object collisions
	for k,obj in pairs(room_curr.objects) do
	
			if iscursorcolliding(obj) then
				hover_curr.object = obj
			end
	end

	-- todo: check ui/inventory collisions
	for v in all(verbs) do
		if iscursorcolliding(v) then
			hover_curr.verb = v
		end
	end

	-- default to walkto (if nothing set)
	if (verb_curr == nil) then
		verb_curr = verb_default
	end

	-- update "default" verb for hovered object (if any)
	if notnull(hover_curr.object) then
		hover_curr.default_verb = find_default_verb(hover_curr.object)
	end
end

function roomdraw()
	-- draw current room (base layer)
	room_map = room_curr.map
	map(room_map.x, room_map.y, 0, stage_top, room_map.w, room_map.h) --,layer
	
	-- debug walkable areas
	if show_collision then
		celx = flr((cursor.x + cam.x) /8) + room_curr.map.x
		--celx = flr((cursor.x+cam.x)/8)
		cely = flr((cursor.y - stage_top)/8)-- + room_curr.map.y
		spr_num = mget(celx, cely)
		
		--printh("mapa x="..celx..",y="..cely)
		--printh("spr:"..spr_num)

		walkable = fget(spr_num,0)
		--printh("flg:"..flags)
		if walkable then
			rect((celx-room_curr.map.x)*8, stage_top+(cely*8), (celx-room_curr.map.x)*8+7, stage_top+(cely*8)+7, 11)
		end
	end

	-- draw all "visible" room objects (e.g. check dependent-on's)
	for k,obj in pairs(room_curr.objects) do

		-- todo: check dependent-on's

		if (notnull(obj.states)) 
		  and (obj.states[obj.state] > 0)
		  and (isnull(obj.owner)) then
			-- something to draw
			draw_object(obj)
		end

		-- capture bounds (even for "invisible" objects)
		-- todo: exclude class_untouchable
		if isnull(obj.class)
		  or (notnull(obj.class) and obj.class != class_untouchable) then
			recalc_obj_bounds(obj, cam.x, cam.y)
			if (show_collision) rect(obj.bounds.x, obj.bounds.y, obj.bounds.x1, obj.bounds.y1, 8)
		end
	end

	-- draw actors
	actordraw(selected_actor)
end

-- draw actor(s)
function actordraw(actor)
	--sprnum = actor.idle
 	-- offets
	local offset_x = actor.x - (actor.sprw *8) /2
	local offset_y = actor.y -(actor.sprh * 8) +2
	
	if (actor.moving == 1) then
		actor.tmr += 1
		if (actor.tmr > 5) then
			actor.tmr = 1
			actor.anim_pos += 1
			if (actor.anim_pos > #actor.walk_anim) actor.anim_pos=1
		end
		sprnum = actor.walk_anim[actor.anim_pos]
	else
		-- idle
		sprnum = actor.idle[actor.face_dir]
	end

	sprdraw(sprnum, offset_x, offset_y, 
		actor.sprw , actor.sprh, actor.trans_col, 
		actor.flip, false)
end

function commanddraw()
	-- draw current command
	command = ""
	cmd_col = 12

	if not executing_cmd then
		if notnull(verb_curr) then
			command = verb_curr[2]
		end
		if notnull(noun1_curr) then
			command = command.." "..noun1_curr.name
		end
		if verb_curr[1] == "use" and notnull(noun1_curr) then
			command = command.." with"
		end
		if notnull(noun2_curr) then
			command = command.." "..noun2_curr.name
		elseif notnull(hover_curr.object) 
			-- don't show use object with itself!
			and ( isnull(noun1_curr) or (noun1_curr != hover_curr.object) ) then
			command = command.." "..hover_curr.object.name
		end
		cmd_curr = command
	else
		-- highlight active command
		command = cmd_curr
		cmd_col = 7
	end

	print(smallcaps(command), 
		hcenter(command), 
		stage_top + 66, cmd_col)
end

function dialogdraw()
	-- alignment 
	--   0 = no align
	--   1 = center 
	if type(dialog_curr) != 'nil' then
		line_offset_y = 0
		for l in all(dialog_curr.msg_lines) do
			line_offset_x=0
			-- center-align line
			if dialog_curr.align == 1 then
				line_offset_x = ((dialog_curr.char_width*4)-(#l*4))/2
			end
			outline_text(
				l, 
				dialog_curr.x + line_offset_x, 
				dialog_curr.y + line_offset_y, 
				dialog_curr.col)
			line_offset_y += 6
		end

		-- update message lifespan
		dialog_curr.time_left -= 1
		if (dialog_curr.time_left <=0) dialog_curr = nil
	end
end

-- draw ui and inventory
function uidraw()
	-- draw verbs
	xpos = 0
	ypos = stage_top + 75
	col_len=0


	for v in all(verbs) do
		txtcol=verb_maincol

		-- highlight default verb
		if notnull(hover_curr.default_verb)
		  and (v == hover_curr.default_verb) then
			txtcol = verb_defcol
		end		
		if (v == hover_curr.verb) txtcol=verb_hovcol
		print(v[2], xpos, ypos+1, verb_shadcol)  -- shadow
		print(v[2], xpos, ypos, txtcol)  -- main
		
		-- capture bounds
		v["bounds"] = {
			x = xpos,
			y = ypos,
			x1 = xpos + #v[2]*4-1,
			y1 = ypos+5,
			cam_off_x = 0,
			cam_off_y = 0
		}
		if (show_collision) rect(v.bounds.x, v.bounds.y, v.bounds.x1, v.bounds.y1, 8)
		-- auto-size column
		if (#v[2] > col_len) col_len = #v[2]
		ypos += 8
		-- move to next column
		if ypos >= stage_top + 95 then
			ypos = stage_top + 75
			xpos += (col_len + 1.0) * 4
			col_len = 0
		end
	end

	-- draw arrows
	sprdraw(16, 75, stage_top + 60, 1, 1, 0)
	sprdraw(48, 75, stage_top + 73, 1, 1, 0)

	-- draw inventory
	xpos = 86
	ypos = 76
	for ipos=1, 8 do
		-- draw inventory bg
		rectfill(xpos-1, stage_top+ypos-1, xpos+8, stage_top+ypos+8, 1)
		obj = selected_actor.inventory[ipos]
		if type(obj) != 'nil' then
			-- something to draw
			obj.x = xpos
			obj.y = ypos
			-- draw object/sprite
			draw_object(obj)
			-- re-calculate bounds (as pos may have changed)
			recalc_obj_bounds(obj,0,0)
		end
		xpos += 11
		if xpos >= 125 then
			ypos += 12
			xpos=86
		end
		ipos += 1
	end
end

-- draw cursor
function cursordraw()
	col = cursor.cols[cursor.colpos]
	-- switch sprite color accordingly
	pal(7,col)
	spr(32, cursor.x-4, cursor.y-3, 1, 1, 0)
	pal() --reset palette

	cursor.tmr += 1
	if (cursor.tmr > 7) then
		--reset timer
		cursor.tmr = 1
		-- move to next color?
		cursor.colpos += 1
		if (cursor.colpos > #cursor.cols) cursor.colpos = 1
	end
end

function sprdraw(n, x, y, w, h, transcol, flip_x, flip_y)
	-- switch transparency
 	palt(0, false)
 	palt(transcol, true)
	 -- draw sprite
	spr(n, x, stage_top + y, w, h, flip_x, flip_y) --
	-- restore trans
	palt(transcol, false)
	palt(0, true)
end

-- scumm core functions -------------------------------------------

function get_use_pos(obj)
	pos = {}
	-- determine use pos
	if isnull(obj.use_pos) or
		(obj.use_pos == pos_infront) then
		pos.x = obj.x+((obj.w*8)/2)-cam.x
		pos.y = obj.y+(obj.h*8) +2

	elseif (obj.use_pos == pos_left) then
		pos.x = obj.x-cam.x
		pos.y = obj.y+((obj.h*8) -2)

	elseif (obj.use_pos == pos_right) then
		pos.x = obj.x+(obj.w*8)-cam.x
		pos.y = obj.y+((obj.h*8) -2)
	end
	
	return pos
end

function do_anim(actor, cmd_type, cmd_value)
	-- is target dir left?
	actor.flip = (cmd_value == face_left)

	if cmd_type == anim_face then
		printh(" > anim_face")
		actor.face_dir = cmd_value

	elseif cmd_type == anim_turn then
		printh(" > anim_turn")
		while (actor.face_dir != cmd_value) do
			if (actor.face_dir < cmd_value) then
				actor.face_dir += 1
			else 
				actor.face_dir -= 1
			end
			--if (actor.face_dir < 1) actor.face_dir = 4
			break_time(10)
		end
	end

	-- flip?
	
end

function come_out_door(door_obj, new_room)
	-- todo: switch to new room and...	
	printh("door1a x:"..door_obj.x..", y:"..door_obj.y)
	change_room(new_room)
	printh("door1b x:"..door_obj.x..", y:"..door_obj.y)
	-- ...auto-position actor at door_obj
	pos = get_use_pos(door_obj)
	printh("pos x:"..pos.x..", y:"..pos.y)
	selected_actor.x = pos.x
	selected_actor.y = pos.y

	-- (in opposite use direction)
	do_anim(selected_actor, face_dir, door_obj.use_pos)
	-- printh("face 1:"..selected_actor.face_dir)
	-- selected_actor.face_dir = door_obj.use_pos
	-- printh("face 2:"..selected_actor.face_dir)
end

function change_room(new_room)
printh("change_room()...")
	-- switch to new room
	-- execute the exit() script of old room
	if notnull(room_curr) and notnull(room_curr.exit) then
		start_script(room_curr.exit)
		-- todo wait_for_script (to finish)
	end
	
	-- stop all active (local) scripts
	break_time(1)
	local_scripts = {}
	-- clear current command
	clear_curr_cmd()

	-- todo: transition to new room (e.g. iris/swipe)	
	room_curr = new_room

	-- reset camera
	cam.x = 0

	-- execute the enter() script of new room
	if notnull(room_curr.enter) then
		start_script(room_curr.enter)
	end
end

function valid_verb(verb, object)
	-- check params
	if (isnull(object)) return false
	if (isnull(object.verbs)) return false
	-- look for verb
	if type(verb) == "table" then
		if (notnull(object.verbs[verb[1]])) return true
	else
		if (notnull(object.verbs[verb])) return true
	end
	--[[for k,v_func in pairs(object.verbs) do
		if k == verb[1] then
			-- valid verb
			return true
		end
	end]]
	-- must not be valid if reached here
	return false
end

function pickup_obj(objname)
	obj = find_object(objname)
	if notnull(obj) 
	 and notnull(obj.class) 
	 and obj.class == class_pickupable
	 and isnull(obj.owner) then
	 	printh("adding to inv")
		-- assume selected_actor picked-up at this point
		add(selected_actor.inventory, obj)
		obj.owner = selected_actor
	end
end

function owner_of(objname)
	obj = find_object(objname)
	if notnull(obj) then
		return obj.owner
	end
end

function state_of(objname, state)
	obj = find_object(objname)
	if notnull(obj) then
		return obj.state
	end
end

function set_state(objname, state)
	obj = find_object(objname)
	if notnull(obj) then
		obj.state = state
	end
end

-- find object by ref or name
function find_object(name)
	-- if object passed, just return object!
	--printh("type(name): "..type(name))
	if (type(name) == "table") return name
	-- else look for object by unique name
	for k,obj in pairs(room_curr.objects) do
		if (k == name) return obj
	end
end

function start_script(func, me)	-- me == this
	-- create new thread for script and add to list of local_scripts
	local thread = cocreate(func)
	add(local_scripts, {func, thread, me} )
end

function script_running(func)
	printh("script_running()")
	-- find script and stop it running
	for k,scr_obj in pairs(local_scripts) do
		printh("...")
		if (scr_obj[1] == func) then 
			printh("found!")
			return true
		end
	end
	-- must not be running
	return false
end

function stop_script(func)
	printh("stop_script()")
	-- find script and stop it running
	for k,scr_obj in pairs(local_scripts) do
		printh("...")
		if (scr_obj[1] == func) then 
			printh("found!")
			del(local_scripts, scr_obj)
			printh("deleted!")
			scr_obj = nil
		end
	end
end

function break_time(jiffies)
	-- draw object (depending on state!)
	for x = 1, jiffies do
		yield()
	end
end

function wait_for_message()
	-- draw object (depending on state!)
	while dialog_curr != nil do
		yield()
	end
end

-- uses actor's position and color
function say_line(actor, msg)
	-- get pos above actor's head
	ypos = actor.y-text_offset
	-- call the base print_line to show actor line
	print_line(msg, actor.x, ypos, actor.col, 1)
end


function print_line(msg, x, y, col, align)
	--printh("print_line()...")
  -- todo: punctuation...
	--  > ":" new line, shown after text prior expires
	--  > "," new line, shown immediately

	-- todo: an actor's talk animation is not activated as it is with say-line.
	local col=col or 7 		-- default to white
	local align=align or 0	-- default to no align

	printh(msg)
	--printh("align:"..align)
	--printh("x:"..x.." y:"..y)
	-- default max width (unless hit a screen edge)
	local lines={}
	local currline=""
	local curword=""
	local curchar=""
	local msg_left="" --used for splitting messages with ";"
	
	longest_line=0
	-- auto-wrap
	-- calc max line width based on x-pos/available space
	screen_space = min(x, screenwidth - x)
	-- (or no less than min length)
	max_line_length = max(flr(screen_space/2), 16)

	local upt=function(max_length)
		if #curword + #currline > max_length then
			add(lines,currline)
			if (#currline > longest_line) longest_line = #currline
			currline=""
		end
		currline=currline..curword
		curword=""
	end

	for i = 1, #msg do
		curchar=sub(msg,i,i)
		curword=curword..curchar
		if (curchar == " ")
		 or (#curword > max_line_length-1) then
			upt(max_line_length)
		elseif #curword>max_line_length-1 then
			curword=curword.."-"
			upt(max_line_length)
		elseif curchar == "," then -- line break
			printh("line break!")
			currline=currline..sub(curword,1,#curword-1)
			curword=""
			upt(0)
		elseif curchar == ";" then -- msg break
			printh("msg break!")
			-- show msg up to this point
			-- and process the rest as new message
			currline=currline..sub(curword,1,#curword-1)
			curword=""
			upt(0)
			-- next message?
			msg_left = sub(msg,i+1)
			printh("msg_left:"..msg_left)
			break
		end
	end

	upt(max_line_length)
	if currline~="" then
		add(lines,currline)
		if (#currline > longest_line) longest_line = #currline
	end

	-- center-align text block
	if align == 1 then
		xpos = x - ((longest_line*4)/2)
	end

	-- screen bound check
	-- left
	xpos = max(2,xpos)	
	-- top
	ypos = max(18,y)
	-- right
	xpos = min(xpos, screenwidth - (longest_line*4)+4)

	dialog_curr = {
		msg_lines = lines,
		x = xpos,
		y = ypos,
		col = col,
		align = align,
		time_left = (#msg-#msg_left)*8,
		char_width = longest_line
	}

	-- if message was split...
	if (#msg_left > 0) then
		wait_for_message()
		print_line(msg_left, x, y, col, align)
	end
end

function draw_object(obj)
	-- draw object (depending on state!)
	sprdraw(obj.states[obj.state], obj.x, obj.y, obj.w, obj.h, obj.transcol, obj.flip_x)
end

-- walk actor to position
function walk_to(actor, x, y)

	--offset for camera
	x += cam.x

	local distance = sqrt((x - actor.x) ^ 2 + (y - actor.y) ^ 2)
	local step_x = actor.speed * (x - actor.x) / distance
	local step_y = actor.speed * (y - actor.y) / distance

	-- abort if we're already there!
	if (distance < 1) return

	-- check target position is in walkable block
	celx = flr(x/8) + room_curr.map.x
	cely = flr(y/8)
	printh("mapb x="..celx..",y="..cely)
	spr_num = mget(celx, cely)	
	printh("spr:"..spr_num)
	
	walkable = fget(spr_num, 0) -- flag 0 = walkable
	-- if it is...
	if walkable then
		printh("walkable!")
		actor.moving = 1 --walking
		actor.flip = (step_x<0)
		-- face dir (at end of walk)
		actor.face_dir = face_right
		if (actor.flip) actor.face_dir = face_left

		for i = 0, distance/actor.speed do
			--printh("walking...")
			actor.x += step_x
			actor.y += step_y
			yield()
		end
		actor.moving = 2 --arrived
	else
		actor.moving = 0 --stopped
	end
end



-- internal functions -----------------------------------------------

function clear_curr_cmd()
	-- reset all command values
	verb_curr = verb_default
	noun1_curr = nil
	noun2_curr = nil
	me = nil
	executing_cmd = false
	cmd_curr = ""
	printh("command wiped")
end

function recalc_obj_bounds(obj, cam_off_x, cam_off_y)
	obj["bounds"] = {
			x = obj.x,
			y = stage_top + obj.y,
			x1 = obj.x + (obj.w*8) + -1,
			y1 = stage_top + obj.y + (obj.h*8) -1,
			cam_off_x = cam_off_x,
			cam_off_y = cam_off_y
		}
end

-- library functions -----------------------------------------------

function outline_text(str,x,y,c0,c1)

 local c0=c0 or 7
 local c1=c1 or 0

 str = smallcaps(str)

 print(str,x,y+1,c1)
 print(str,x,y-1,c1)
 print(str,x+1,y,c1)
 print(str,x+1,y+1,c1)
 print(str,x+1,y-1,c1)
 print(str,x-1,y,c1)
 print(str,x-1,y+1,c1)
 print(str,x-1,y-1,c1)

 print(str,x,y,c0)
end

--- center align from: pico-8.wikia.com/wiki/centering_text
function hcenter(s)
	-- string length times the 
	-- pixels in a char's width
	-- cut in half and rounded down
	return (screenwidth / 2)-flr((#s*4)/2)
end

function vcenter(s)
	-- string char's height
	-- cut in half and rounded down
	return (screenheight /2)-flr(5/2)
end

--- collision check
function iscursorcolliding(obj)
	-- check params
	if (isnull(obj.bounds)) return false
	bounds=obj.bounds
	if (cursor.x + bounds.cam_off_x > bounds.x1 or cursor.x + bounds.cam_off_x < bounds.x) 
	 or (cursor.y>bounds.y1 or cursor.y<bounds.y) then
		return false
	else
		return true
	end
end

function smallcaps(s)
	local d=""
	local l,c,t=false,false
	for i=1,#s do
		local a=sub(s,i,i)
		if a=="^" then
			if(c) d=d..a
				c=not c
			elseif a=="~" then
				if(t) d=d..a
				t,l=not t,not l
			else 
				if c==l and a>="a" and a<="z" then
				for j=1,26 do
					if a==sub("abcdefghijklmnopqrstuvwxyz",j,j) then
						a=sub("\65\66\67\68\69\70\71\72\73\74\75\76\77\78\79\80\81\82\83\84\85\86\87\88\89\90\91\92",j,j)
					break
					end
				end
			end
			d=d..a
			c,t=false,false
		end
	end
	return d
end

function isnull(var)
	return (type(var) == 'nil')
end

function notnull(var)
	return (type(var) != 'nil')
end

__gfx__
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1111111100000000f9e9f9f9ddd5ddd500000000ffffffff7777777766666666cccccccc3333333344444444
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb11111111000000009eee9f9fdd5ddd5d00000000ffffffff7777777766666666cccccccc333333334ffffff4
00000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb1111111100000000feeef9f9d5ddd5dd00000000ffffffff7777777766666666cccccccc333333334f444494
00000000b444449bb494449bb494449bb494449b11111111000000009fef9fef5ddd5ddd00000000ffffffff7777777766666666cccccccc333333334f444494
00000000444044494944444949444449494444491111111100000000f9f9feeeddd5ddd500000000ffffffff7777777766666666cccccccc333333334f444494
000000004040000449440004494400044944000411111111000000009f9f9eeedd5ddd5d00000000ffffffff7777777766666666cccccccc333333334f444494
0000000004ffff000440fffb0440fffb0440fffb1111111100000000f9f9feeed5ddd5dd00000000ffffffff7777777766666666cccccccc333333334f444494
000000000f9ff9f004f0f9fb04f0f9fb04f0f9fb11111111000000009f9f9fef5ddd5ddd00000000ffffffff7777777766666666cccccccc333333334f444494
000cc0000f5ff5f000fff5fb00fff5fb00fff5fbcccccccc0000000000000000000000000000000000000000000000000000000000000000000000004f444494
00c11c004ffffff440ffffff40ffffff40ffffffcccccccc0000000000000000000a00000000000000000000000000000000000000000000000000004f444494
0c1001c0bff44ffbb0fffff4b0fffff4b0fffff4cccccccc0000000000000000000000000000000000000000000000000000000000000000000000004f449994
ccc00cccb6ffff6bb6fffffbb6fffffbb6fffffbcccccccc0000000000a0a000000aa000000a0a00cccccccc55555555dddddddd11111111000000004f994444
00c00c00bb6556bbbb6ff55bbb6ff55bbb6ff55bcccccccc0000000000aaaa0000aaaa0000aaa000cccccccc55555555dddddddd111111110000000044444444
00c00c00bbb66bbbbbb66bbbbbb66bbbbbb66bbbcccccccc0000000000a9aa0000a99a0000aa9a00cccccccc55555555dddddddd111111110000000044444444
00cccc00bdc55cdbbbddcbbbbbbddbbbbbddcbbbcccccccc0000000000a99a0000a99a0000a99a00cccccccc55555555dddddddd111111110000000049a44444
00111100dcc55ccdb1ccdcbbbb1ccdbbb1ccdcbbcccccccc00000000004444000044440000444400cccccccc55555555dddddddd111111110000000049944444
00070000c1c66c1cb1ccdcbbbb1ccdbbb1ccdcbbdddddddd99999999777777777777777777777777ffffffcc77777755666666ddcccccc115555553344444444
00070000c1c55c1cb1ccdcbbbb1ccdbbb1ccdcbbdddddddd55555555555555555555555555555555ffffcccc777755556666ddddcccc1111555533334444fff4
00070000c1c55c1cb1ccdcbbbb1ccdbbb1ccdcbbdddddddd444444440dd6dd6dd6dd6dd6d6dd6d50ffcccccc7755555566ddddddcc111111553333334fff4494
77707770c1c55c1cb1ccdcbbbb1ccdbbb1ccdcbbddddddddffff4fff0dd6dd6dd6dd6dd6d6dd6d50cccccccc55555555dddddddd11111111533333334f444494
00070000d1cddc1db1dddcbbbb1dddbbb1dddcbbdddddddd44494944066666666666666666666650cccccccc55555555dddddddd11111111533333334f444494
00070000fe1111efbbff11bbbb2ff1bbbbff11bbdddddddd444949440d6dd6dd6dd6dd6ddd6dd650cccccccc55555555dddddddd11111111553333334f444494
00070000bf1111fbbbfe11bbbb2fe1bbbbfe11bbdddddddd444949440d6dd6dd6dd6dd6ddd6dd650cccccccc55555555dddddddd11111111555533334f444494
00000000bb1121bbbb2111bbbb2111bbbb2111bbdddddddd44494944066666666666666666666650cccccccc55555555dddddddd11111111555555334f444494
00cccc00bb1121bbbb1111bbbb2111bbbb2111bb55555555444949440dd6dd600000000056dd6d50ccffffff55777777dd66666611cccccc555555554f444494
00c11c00bb1121bbbb1111bbbb2111bbbb2111bb55555555444949440dd6dd650000000056dd6d50ccccffff55557777dddd66661111cccc333355554f444994
00c00c00bb1121bbbb1112bbbb2111bbbb21111b5555555544494944066666650000000056666650ccccccff55555577dddddd66111111cc333333554f499444
ccc00cccbb1121bbbb1112bbbb2111bbbb22111b55555555444949440d6dd6d5000000005d6dd650cccccccc55555555dddddddd11111111333333354f944444
1c1001c1bb1121bbb111122bbb2111bbb222111b55555555444949440d6dd6d5000000005d6dd650cccccccc55555555dddddddd111111113333333544444400
01c00c10bb1121bbc111222bbb2111bbb22211cc5555555544494944066666650000000056666650cccccccc55555555dddddddd111111113333335544440000
001cc100bbccccbb7ccc222bbbccccbbb222cc7755555555999949990dd6dd650000000056dd6d50cccccccc55555555dddddddd111111113333555544000000
00011000b776677bb7776666bb6777bbb66677bb55555555444444440dd6dd650000000056dd6d50cccccccc55555555dddddddd111111115555555500000000
000770000000007007000000000700000444449000070000777600007777777777777777bbbbbbbb000700000007000000070000000700000007000000070000
000880000000008778000000000700004440444900070000777600005555555555555555bbbbbbbb000700000007000000070000000700000007000000070000
000880000000088008800000000700004040000400070000777600004444444444444444bbbbbbbb000700000007000000070000000700000007000000070000
0008800000000880088000007770777004ffff007770777066665555444ffffffffff444b999449b777077707770777077707770777077707770777077707770
000880000000880000880000000700000f9ff9f00007000000007776444944444444944494444449000700000007000000070000000700000007000000070000
000880000000880000880000000700000f5ff5f000070000000077764449444aa444944494444444000700000007000000070000000700000007000000070000
000880000008800000088000000700004ffffff40007000000007776444944444444944444444444000700000007000000070000000700000007000000070000
000880000008800000088000000000000ff44ff00000000055556666444999999999944444444444000000000000000000000000000000000000000000000000
7777777777777777775555555555557706ffff60777777770007000044494444444494444444444000070000000700000007bbbb000700000007000000070000
7000000770000007707000000000070700655600700000070007000044494444444494440444444400070000000700000007bbbb000700000007000000070000
700000077000000770070000000070070006600070000007000700004449444444449444b044444b00070000000700000007bbbb000700000007000000070000
700000077000000770006000000600070000000070000007777077704449444444449444b044444b77707770777077707770777b777077707770777077707770
700000077000000770006000000600070000000070000007000700004449444444449444bb0000bb0007000000070000bbb7bbbb000700000007000000070000
700000077000000770006000000600070000000070000007000700004449444444449444bbbffbbb0007000000070000bbb7bbbb000700000007000000070000
700000077000000770006000000600070000000070000007000700004449999999999444bddddddb0007000000070000bbb7bbbb000700000007000000070000
777777777777777777776000000677770000000077777777000000004444444444444444dccccccd0000000000000000bbbbbbbb000000000000000000000000
700000677600000770066000000660070dc55cd0700000070007cccc0007000000070000c1cccc1c000700000007000000070000000700000007000000074444
70000607706000077060600000060607dcc55ccd700000070007cccc0007000000070000c1cccc1c000700000007000000070000000700000007000000074444
70000507705000077050600000060507c1c66c1c700000070007cccc0007000000070000c1cccc1c000700000007000000070000000700000007000000074444
70000007700000077000600000060007c1c55c1c700000077770777c7770777077707770c1cccc1c777077707770777077707770777077707770777077707774
70000007700000077005000000005007c1c55c1c70000007ccc7cccc0007000000070000d1cccc1d000700000007000000070000000700000007000044474444
70000007700000077050000000000507c1c55c1c70000007ccc7cccc0007000000070000fe1111ef000700000007000000070000000700000007000044474444
77777777777777777500000000000077d1cddc1d77777777ccc7cccc0007000000070000bf1111fb000700000007000000070000000700000007000044474444
55555555555555555555555555555555f0d66d0f55555555cccccccc0000000000000000bb1211bb000000000000000000000000000000000000000044444444
000700000007000000070000000700000011110000070000000700000007000000070000bb1211bb000700000007000000070000000700000007000000070000
000700000007000000070000000700000011210000070000000700000007000000070000bb1211bb000700000007000000070000000700000007000000070000
000700000007000000070000000700000011210000070000000700000007000000070000bb1211bb000700000007000000070000000700000007000000070000
777077707770777077707770777077700011210077707770777077707770777077707770bb1211bb777077707770777077707770777077707770777077707770
000700000007000000070000000700000011210000070000000700000007000000070000bb1211bb000700000007000000070000000700000007000000070000
000700000007000000070000000700000011210000070000000700000007000000070000bb1211bb000700000007000000070000000700000007000000070000
0007000000070000000700000007000000cccc0000070000000700000007000000070000bbccccbb000700000007000000070000000700000007000000070000
000000000000000000000000000000000776677000000000000000000000000000000000b776677b000000000000000000000000000000000000000000000000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
777077707770777077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777777770777077707770
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000000000000000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770000000000000000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
777077707770777077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777777770777077707770
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000000000000000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770000000000000000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
777077707770777077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777777770777077707770
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000000000000000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770000000000000000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
777077707770777077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777777770777077707770
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000700000007000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770007000000070000
000000000000000077777777777777777777777777777777cccccccccccccccccccccccccccccccc777777777777777777777777777777770000000000000000
000700000007000000070000000700000007000000070000000700000007000000070000eeeeeeeebbbbbbbb9999999900070000000700000007000000070000
000700000007000000070000000700000007000000070000000700000007000000070000eeeeeeeebbbbbbbb9999999900070000000700000007000000070000
000700000007000000070000000700000007000000070000000700000007000000070000eeeeeeeebbbbbbbb9999999900070000000700000007000000070000
777077707770777077707770777077707770777077707770777077707770777077707770eeeeeeeebbbbbbbb9999999977707770777077707770777077707770
000700000007000000070000000700000007000000070000000700000007000000070000eeeeeeeebbbbbbbb9999999900070000000700000007000000070000
000700000007000000070000000700000007000000070000000700000007000000070000eeeeeeeebbbbbbbb9999999900070000000700000007000000070000
000700000007000000070000000700000007000000070000000700000007000000070000eeeeeeeebbbbbbbb9999999900070000000700000007000000070000
000000000000000000000000000000000000000000000000000000000000000000000000eeeeeeeebbbbbbbb9999999900000000000000000000000000000000
00070000000700000007000000070000000700000007000000070000000700000007000000070000cccccccc8888888855555555000700000007000000070000
00070000000700000007000000070000000700000007000000070000000700000007000000070000cccccccc8888888855555555000700000007000000070000
00070000000700000007000000070000000700000007000000070000000700000007000000070000cccccccc8888888855555555000700000007000000070000
77707770777077707770777077707770777077707770777077707770777077707770777077707770cccccccc8888888855555555777077707770777077707770
00070000000700000007000000070000000700000007000000070000000700000007000000070000cccccccc8888888855555555000700000007000000070000
00070000000700000007000000070000000700000007000000070000000700000007000000070000cccccccc8888888855555555000700000007000000070000
00070000000700000007000000070000000700000007000000070000000700000007000000070000cccccccc8888888855555555000700000007000000070000
00000000000000000000000000000000000000000000000000000000000000000000000000000000cccccccc8888888855555555000000000000000000000000
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000000094
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000000944
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000009440
77707770777077707770777077707770777077707770777077707770777077707770777077707770777077707770777077707770777077707770777000094400
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000044000
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000400000
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000094000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000044000000
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000088888888
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000080000008
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000080800808
77707770777077707770777077707770777077707770777077707770777077707770777077707770777077707770777077707770777077707770777080088008
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000080088008
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000080800808
00070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000000070000000700000007000080000008
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000088888888

__gff__
0000000000010000000000000000000000000000000100000000010101010000000000000001000000000101010100000000000000010000000001010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0b0b0b070707070707070707070b0b0b0c0c0c0808080808080808080808080808080808080c0c0c060606060606060a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a
0b0b0b070000070707070707070b0b0b0c0c0c0808080808080850505051080808080808080c0c0c060606060606060a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a
0b000b070000070707070707070b000b0c090c4646464646464660656561464646464646460c090c060606060606060a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a
0b000b262626262728292626260b000b0c090c4748474847484748474847484748474847480c090c060606060606060a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a
0b000b363636363700393636360b000b0c090c5758575857585758575857585758575857580c090c060606060606060a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a
0b1b2b353535353535353535353b1b0b0c1c2c2525252525252525252525252525252525253c1c0c060606060606060a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a
2b3535352e0e0e0e0e0e0e3e3535353b2c252525252525252525252525252525252525252525253c060606060606061e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e
3535353535353535353535353535353525252525252525252525252525252525252525252525252506060606060606151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a0606060606060606060606060a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a
0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a
0a000a060606060606060606060a000a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a
0a000a262626272828292626260a000a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a
0a000a363636370000393636360a000a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a
0a1a2a151515151515151515153a1a0a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a
2a1515150d0d0d0d0d0d0d0d1515153a0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a
0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a
0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a
0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a
0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a
0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a
0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a
0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a0a0a0a060606060606060606060a0a0a
0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a0a040a060606060606060606060a240a
0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a0a140a262626272828292626260a340a
0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a0a140a363636370000393636360a340a
0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a0a070f151515151515151515151e080a
0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e0f15151517191919191919181515151e
1515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515151515
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344
00 41424344

