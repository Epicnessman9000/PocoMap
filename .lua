if not _Output or not CopDamage then return end -- external dependancy and ingame check
if true then
	managers.hud._hud_mission_briefing._backdrop._panel:child( "base_layer" ):set_alpha(0.5)
	managers.hud._hud_mission_briefing._backdrop._black_bg_ws:panel():hide()--:set_alpha(0)
--	managers.hud._hud_mission_briefing._backdrop._blackborder_workspace:hide() --hide()
end
---- Common simplefunctions
local ignore = function()end
local _ = _Output.Console
local __ = _Output.Debug
local pen = Draw:pen( "no_z", "red" )
local now = function () return managers.player:player_timer():time() --[[TimerManager:game():time()]] end
local ff = function(f) return f and (type(f)=='number' and f >= 99.5 and tostring(math.floor(f)) or string.format("%.2g", f)) or (f or '0') end
local mcos,msin = math.cos,math.sin
local theta = function(p,a,o)
	return {x = mcos(a) * (p.x - o.x) - msin(a) * (p.y - o.y) + o.x, y = msin(a) * (p.x - o.x) + mcos(a) * (p.y - o.y) + o.y}
end
---------------------
local Config = {
	showClock = true,	-- true/false
	clockIncludeBag = true,
	clockSize = 28,

	dotSize = 180,	-- default Dotsize as centimeter, default 180
	equipMul = 1.5, -- Equipment icon scale, default 1.5
	farMul = 0.7,   -- Far icon scale, default 0.7
	farDiv = 50,			-- maximum number of 'far' icons grouped as, default 50
	normalMul = 0.65,	-- normal mobs' scale, default 0.65
	arrowRatio = 1.4,	-- mob/player arrows' height ratio, default 1.4
	dotDecay = 5,			-- dead mobs decay as seconds default 5
	dotBorder = 3,		-- dots' border as pixels, default 3
	mapSize = 300,		-- map's width as pixels, default 300. decrease this number if the radar bleeds out of the screen
	mapRotate = true,	-- true: rotate map as camera moves
	ignoreNormal = false, -- true: ignore normal mobs and display specials/eqipments
	polyLimit = 50,				-- limit max numbers of obstacles displayed, has DIRECT hit on performance, default 50
	smartRange = true,		-- true: ADS to far areas will zoom out, false: rangeMax becomes obsolete
	rangeMax = 3000,			-- radius in centimeter, default 3000
	rangeMin = 1800,			-- radius in centimeter, default 1800

	left = 0.1,		-- percent of screen 0 ~ 1
	top = 0.26,		-- percent of screen 0 ~ 1
	optScan = 5,  -- FPS cap for fetching far objects. 0 = disable optimization
	optDraw = 40,	-- FPS cap for drawing far objects.  0 = disable optimization
	optMap = 3,		-- FPS cap for fetching obstacles.   0 = disable optimization
	EndOf = 'Config, Please do not edit below'
}

local optScan = 1/(Config.optScan>0 and Config.optScan or 60)
local optDraw = 1/(Config.optDraw>0 and Config.optDraw or 60)
local optMap = 1/(Config.optMap>0 and Config.optMap or 60)
local _ICONS = {
	access_camera = '',
	activate_camera = '',
	ammo_bag = 'equipment_ammo_bag',
	apply_thermite_paste = 'equipment_thermite',
	atm_interaction = 'pd2_generic_interact',
	bag_zipline = 'pd2_generic_interact',
	barricade_fence = '',
	barrier_numpad = '',
	bodybags_bag = 'cleaner',
	burning_money = '',
	c4_special = '',
	carry_drop = 'wp_bag',
	cash_register = 'interaction_money_wrap',
	caustic_soda = 'equipment_caustic_soda',
	circuit_breaker = 'pd2_power',
	corpse_dispose =  'risk_swat',
	crate_loot = 'equipment_crowbar',
	crate_loot_close = 'equipment_crowbar',
	crate_loot_crowbar = 'equipment_crowbar',
	cut_fence = 'pd2_wirecutter',
	diamond_pickup = 'interaction_diamond',
	disassemble_turret = 'pd2_loot',
	doctor_bag = 'icon_addon',
	drill = 'equipment_drill',
	drill_jammed = 'equipment_drill',
	ecm_jammer = 'equipment_ecm_jammer',
	fork_lift_sound = 'pd2_generic_interact',
	gage_assignment = 'wp_target',
	gasoline = 'equipment_thermite',
	gen_pku_cocaine = 'pd2_loot',
	gen_pku_cocaine = 'pd2_loot',
	gen_pku_crowbar = 'icon_repair',
	gen_pku_fusion_reactor = 'pd2_loot',
	gen_pku_jewelry = 'pd2_loot',
	gen_pku_thermite_paste = 'equipment_thermite',
	gold_pile = 'pd2_loot',
	grenade_briefcase = 'frag_grenade',
	grenade_crate = 'frag_grenade',
	hack_suburbia = 'wp_hack',
	hack_suburbia_jammed = 'wp_hack',
	hold_pickup_lance = 'wp_bag',
	hold_place_gps_tracker = '',
	hold_take_gas_can = 'wp_can',
	hold_take_painting = 'pd2_loot',
	hold_take_server = 'pd2_loot',
	hold_use_computer = 'wp_hack',
	hostage_convert = 'mugshot_cuffed',
	hostage_move = 'wp_arrow',
	hostage_stay = '',
	hostage_trade = 'wp_trade',
	hydrogen_chloride = 'equipment_hydrogen_chloride',
	intimidate = '',
	invisible_interaction_open = 'equipment_crowbar',
	key = 'equipment_generic_key',
	lance = 'equipment_drill',
	lance_jammed = 'equipment_drill',
	lance_upgrade = 'equipment_drill',
	methlab_bubbling = '',
	methlab_caustic_cooler = '',
	methlab_gas_to_salt = '',
	money_briefcase = 'pd2_loot',
	money_small = 'pd2_loot',
	money_wrap = 'pd2_loot',
	money_wrap_single_bundle = 'interaction_money_wrap',
	muriatic_acid = 'equipment_muriatic_acid',
	need_boards = '',
	numpad_keycard = 'wp_hack',
	open_door = '',
	open_from_inside = '',
	open_slash_close = 'equipment_crowbar',
	open_slash_close_act = 'equipment_crowbar',
	open_slash_close_sec_box = 'equipment_crowbar',
	painting_carry_drop = 'wp_bag',
	pick_lock_deposit_transport = string.find(managers.job:current_level_id(),"bank") and '' or 'equipment_generic_key',
	pick_lock_easy = 'equipment_crowbar',
	pick_lock_easy = 'equipment_crowbar',
	pick_lock_easy_no_skill = 'equipment_crowbar',
	pick_lock_hard = 'equipment_generic_key',
	pick_lock_hard_no_skill = string.gsub(managers.job:current_level_id(),"(bank)*(roberts)*(firestarter_3)*") and '' or 'equipment_crowbar',
	pickup_boards = 'wp_planks',
	pickup_keycard = 'equipment_bank_manager_key',
	pickup_phone = '',
	pickup_tablet = '',
	player_zipline = '',
	requires_ecm_jammer = 'equipment_ecm_jammer',
	requires_ecm_jammer_atm = 'equipment_ecm_jammer',
	revive = '',
	safe_loot_pickup = 'interaction_money_wrap',
	samurai_armor = 'wp_scrubs',
	sc_tape_loop = 'good_luck_charm',
	security_station_keyboard = 'wp_hack', -- Electionday3
	sentry_gun_refill = 'equipment_sentry',
	set_off_alarm = 'wp_detected',
	sewer_manhole = 'pd2_goto',
	shaped_sharge = '',
	shelf_sliding_suburbia = 'icon_repair',
	stash_planks = '',
	stash_planks_pickup = 'wp_planks',
	stash_server_pickup = 'wp_hack',
	steal_methbag = '',
	stn_int_place_camera = '',
	take_ammo = 'pd2_loot',
	take_confidential_folder = '',
	take_weapons = 'pd2_loot',
	taking_meth = '',
	timelock_panel = '',
	trip_mine = 'equipment_trip_mine',
	uload_database = 'wp_hack',
	uload_database_jammed = 'wp_hack',
	use_computer = 'wp_hack',
	use_server_device = 'wp_hack',
	votingmachine2 = 'wp_hack',
	votingmachine2_jammed = 'wp_hack',
	weapon_case = 'pd2_loot',
	money_bag = 'wp_bag',
	exit_to_crimenet = 'wp_hack',
	button_infopad = 'pd2_generic_interact'
}
TPocoMap = class()

function TPocoMap:init()
	_('PocoMap INIT')
	local hook = function(Obj,key,newFunc)
		local realKey = key:gsub('*','')
		if not self.hooks[key] then
			self.hooks[key] = {Obj,Obj[realKey]}
			Obj[realKey] = newFunc
		end
	end
	local Run = function(key,...)
		return self.hooks[key][2](...)
	end
	self.res = safeGet('RenderSettings.resolution',{x=800,y=600})
	self._cx = self.res.x * Config.left
	self._cy = self.res.y * Config.top
	self._ws = safeGet('Overlay:newgui():create_screen_workspace()')
	if not self._ws then return false end
	self.pnl = 	self._ws:panel():panel({ name = "map_sheet" ,x = 0, y = 0,layer=20})
	self.items = {}
	self.hooks = {}
	if Config.showClock then
		self.clockLbl = self.pnl:text{
			text= 'Clock',
			font= tweak_data.hud_present.title_font,
			font_size= Config.clockSize,
			color= Color.red,
			x= self._cx - Config.mapSize / 2,
			y= self._cy + Config.mapSize / 2,
			w= Config.mapSize,
			h= Config.clockSize,
			align = "center",
			layer= 6
		}
		self.ClockBG = HUDBGBox_create(self.pnl, {
			x= self._cx - Config.mapSize / 2,
			y= self._cy + Config.mapSize / 2,
			w= Config.mapSize,
			h= Config.clockSize
		})
		if Config.clockIncludeBag then
			hook( HUDTemp, 'show_carry_bag', function( self, ... )
				local carry_id, value = unpack({...})
				local carry_data = tweak_data.carry[carry_id]
				local carry_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
				PocoMap._carry_text = {managers.localization:text( "hud_carrying" )..' '..carry_text}
				PocoMap.ClockBG:animate(callback(PocoMap, PocoMap, "_animate_show_bag_panel"), 1, Config.mapSize, ignore, {attention_color = Color.red, attention_forever=true})
			end)
			hook( HUDTemp, 'hide_carry_bag', function( self )
				PocoMap._carry_text = nil
				PocoMap.ClockBG:animate(callback(PocoMap, PocoMap, "_animate_show_bag_panel"), 0, Config.mapSize, ignore)
			end)
		end

	end
	hook( HUDManager, 'show_endscreen_hud', function( self )
		Run('show_endscreen_hud', self )
		PocoMap:free()
	end)

	self._resolution_changed_callback_id = managers.viewport:add_resolution_changed_func( callback( self, self, "resolutionChanged" ) )
	--[[	local zz = ''
	for k,v in pairsByKeys(tweak_data.hud_icons) do
		_(k..':'..type(v))
	end

	self._rasteroverlay = self.pnl:bitmap( {
    name= "overlay",
    texture= "guis/textures/crimenet_map_rasteroverlay",
    texture_rect= {
        0, 0, 32, 256
    },
    wrap_mode= "wrap",
    blend_mode= "mul",
    layer= 3,
    color= Color(1.0, 1, 1, 1),
		x= self._cx-Config.mapSize/2,
		y= self._cy-Config.mapSize/2,
    w= Config.mapSize,
    h= Config.mapSize
} )]]

	self.pnl:bitmap( { -- Black BG
		name= "bg",
		texture= 'guis/textures/pd2/hud_tabs',
		texture_rect=  { 105, 34, 19, 19 },
		layer= 0,
		color= Color.black:with_alpha(0.5),
		blend_mode= "multiply",
		x= self._cx-Config.mapSize/2 +3,
		y= self._cy-Config.mapSize/2 +3,
		w= Config.mapSize-6,
		h= Config.mapSize-6
	} )

	self.pnl:bitmap( {
			name= "radar",
		texture= 'guis/textures/pd2/hud_tabs',
--		texture= 'guis/textures/headershadow',
		texture= 'guis/textures/pd2/hud_progress_active',
		--texture_rect= { 105, 34, 19, 19 },
		layer= 0,
		color= Color.black:with_alpha(1),
		blend_mode= "normal",
		x= self._cx-Config.mapSize/2,
		y= self._cy-Config.mapSize/2,
		w= Config.mapSize,
		h= Config.mapSize
	} )
	self.areaBg = self.pnl:bitmap( {
		name= "area",
		texture= 'guis/textures/pd2/hud_tabs',
--		texture= 'guis/textures/headershadow',
		texture= 'guis/textures/pd2/hud_radial_rim',
		--texture_rect= { 105, 34, 19, 19 },
		layer= 0,
		color= Color.white:with_alpha(0.3),
		blend_mode= "normal",
		x= self._cx-Config.mapSize/2,
		y= self._cy-Config.mapSize/2,
		w= Config.mapSize,
		h= Config.mapSize
	} )
	--[[self.originArrow = self.pnl:bitmap( {
    name= "center",
		texture= 'guis/textures/pd2/scrollbar_arrows',
		--texture= 'guis/textures/pd2/hud_tabs',
    --texture_rect= { 105, 34, 19, 19 },
		--texture_rect= {84, 34, 19, 19},
    layer= 2,
    color= Color.white,
    blend_mode= "normal",
    x= self._cx-10,
    y= self._cy-15,
    w= 20,
    h= 30
	} )]]


	if managers.hud then
		managers.hud:add_updator('drawPocoMap',self.update)
	end
	self.pnl:hide()
end
function TPocoMap:resolutionChanged()
	self:free()
	PocoMap = TPocoMap:new()
end

function TPocoMap:_animate_show_bag_panel(  panel, wait_t, target_w, done_cb, config )
	-- Open box
	self._bagAnim = wait_t>0
	local scx,scy = self.res.x/2,self.res.y/3
	local ecx,ecy= self._cx - Config.mapSize / 2, self._cy + Config.mapSize / 2
	panel:stop()
	panel:set_center( scx,scy )
 	panel:animate( callback( nil, _G, "HUDBGBox_animate_open_center" ), nil, target_w, done_cb, config )
	self.clockLbl:set_center( scx,scy  )
	-- Sustain
	wait( wait_t )
	-- Scale and move to position
	local TOTAL_T = 0.5
	local t = TOTAL_T
	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		local r = math.pow(1 - t/TOTAL_T,5)
		panel:set_center( math.lerp( scx, ecx, r ) , math.lerp( scy, ecy, r )  )
		self.clockLbl:set_center( math.lerp( scx, ecx, r ) , math.lerp( scy, ecy, r )  )
	end
	self._bagAnim = false
	panel:set_position( ecx, ecy )
	self.clockLbl:set_position( ecx, ecy )
end

function TPocoMap:__fillLbl(lbl,txts)
	local result = ''
	if type(txts)=='table' then
	local pos = 0
		local posEnd = 0
		local ranges = {}
		for _,txtObj in ipairs(txts or {}) do
			if type(txtObj)=='table' then
				result = result..tostring(txtObj[1])
				local __, count = string.gsub(txtObj[1], "[^\128-\193]", "")
				posEnd = pos + count
				table.insert(ranges,{pos,posEnd,txtObj[2] or Color.blue})
				pos = posEnd
			end
		end
		lbl:set_text(result)
		for _,range in ipairs(ranges) do
			lbl:set_range_color( range[1], range[2], range[3] or Color.green)
		end
	elseif type(txts)=='string' then
		result = txts
		lbl:set_text(txts)
	end
	return result
end

function TPocoMap.update(t)
	local r,e = pcall(PocoMap._update,PocoMap,now())
	if not r then
		_('UpdErr:'..e)
	end
end

local clSpecial = { -- Dozer,shield,taser,cloaker,sniper
	f30 = Color('000000'),
	f31 = Color('ffffff'),
	f32 = Color('00ffff'),
	f33 = Color('66ff00'),
	f34 = Color('cccc33')
}
local clWaypoint = Color('ff00ff')
local clBag = Color('009090')
local clAICrew = Color('ee8800')
local clFreeCiv = Color('9900ff')
local clTied = Color('6633ff')
local clEquip = Color.white:with_alpha(0.7)
function TPocoMap:GetSkillIcon(skill_id)
	local skill = tweak_data.skilltree.skills[ skill_id ]
	if skill then
		local texture_rect_x = (skill.icon_xy and skill.icon_xy[1]) or 0
		local texture_rect_y = (skill.icon_xy and skill.icon_xy[2]) or 0
		return "guis/textures/pd2/skilltree/icons_atlas", { texture_rect_x*64, texture_rect_y*64, 64, 64 }
	else return false
	end
end
local _noict = {}
local _colorMap = {
	equipment_bank_manager_key = clBag,
	wp_bag = clBag
}
function TPocoMap:_isSpecial(unit)
	local utweak = alive(unit) and unit:base() and unit:base()._tweak_table or '-'
	return 	(tweak_data.character[ utweak ] or {}).priority_shout
end
function TPocoMap:GetDot(unit,raw)
	if not (raw or unit and alive(unit))then return Color.green, Color.red end
	local uKey = unit and unit:key()
	local member = uKey and self.memberCache and self.memberCache[uKey]
	local icon, iconrect = 'guis/textures/pd2/scrollbar_arrows', {0,0,12,12}
	if raw and raw.iconText then
		return clWaypoint, Color.black, tweak_data.hud_icons:get_icon_data( raw.iconText, {0, 0, 32, 32} )
	elseif member then
		return self:PeerIDToColor(member), Color.white, icon,iconrect
	elseif unit then
		local itweak = unit:interaction() and unit:interaction().active and unit:interaction().tweak_data
		local isSpecial = self:_isSpecial(unit)
		if isSpecial then
			return clSpecial[isSpecial] or Color.red, Color.red, icon,iconrect
		elseif (unit:in_slot(24) or unit:in_slot(16)) then -- AI crew
				return clAICrew, Color.white,icon,iconrect
		else
			local clr
			if unit:in_slot(21) then -- free CIV
				return clFreeCiv, Color.white, icon, iconrect
			elseif unit:in_slot(22) then -- tied civ/cop
				if not managers.enemy:is_civilian( unit ) then
					icon, iconrect = tweak_data.hud_icons:get_icon_data( 'mugshot_cuffed' )
				end
				return clTied, Color.white, icon, iconrect
			else -- normal mob or some shit
				local ict = _ICONS[itweak]
				if ict == '' then
				-- no icon
					clr,icon,iconrect = false,nil,nil
				elseif ict then
					if type(ict) =='table' then
						icon, iconrect = unpack(ict)
					elseif self:GetSkillIcon(ict) then
						icon, iconrect = self:GetSkillIcon(ict)
					else
						icon, iconrect = tweak_data.hud_icons:get_icon_data( ict )
					end
				else
					if itweak and itweak ~= '' and not _noict[itweak] then
						_noict[itweak] = 1
						_('no icon for this:','"'..itweak..'"')
					end
					icon, iconrect = tweak_data.hud_icons:get_icon_data( 'wp_suspicious')
				end
				clr = _colorMap[ict] or clEquip
			end
			return  clr, Color.black, icon, iconrect
		end
	end
end
function TPocoMap:PeerIDToColor(pid,fallback)
	return (pid and tweak_data.chat_colors[pid] or fallback or Color.blue)
end

local _lastFarDraw = 0
function TPocoMap:_Draw(t)
	if not self.cam_rot then return end

	local mr = Config.mapRotate
	local yaw = self.cam_rot:yaw()
	local c = {x=self._cx,y= self._cy}
	local b = Config.dotBorder
	local zoom = self.range / Config.mapSize * 2
	local izoom
	local updateFar = false
	if t-_lastFarDraw > optDraw then
		updateFar = true
		_lastFarDraw = t
	end
	local angles = {}
	local _checkAngle = function(ang,type,itm)
		local angle = math.ceil(ang/360*Config.farDiv)
		local a = angles[angle]
		if not a then
			angles[angle] = {}
			angles[angle][type] = itm
			return false
		else
			if a[type] then
				return a[type]
			else
				a[type] = itm
				return false
			end
		end
	end

	for key,item in pairs(self.items) do
		local dotSize = Config.dotSize * ((item.type==2 or item.type==3) and Config.equipMul or 1)
		local scaled = false
--		item.pnl:set_visible(false)
		local pos = item.pos
		local rot = item.rot
		local vec = self.cam_pos - pos
		local dist = vec:length()
		if dist < Config.rangeMin or updateFar then
			local ang = math.atan2(vec.x,vec.y)
			local checkAngle = _checkAngle(ang, item._typ,item)
			if dist > self.range and checkAngle then
				item.pnl:set_visible(false)
			else
				local opa = dist/self.range
				local tvec = vec / zoom
				local hdiff = math.abs((pos - self.pos - math.UP*20).z)
				if hdiff > Config.rangeMin then -- ridiculously far
					item.pnl:set_alpha(0)
				elseif hdiff > 120 then
					item.pnl:set_alpha(0.3)
				else
					item.pnl:set_alpha(1)
				end
				if (math.sqrt(tvec.x*tvec.x+tvec.y*tvec.y) > Config.mapSize/2) then
					tvec = tvec * (Config.mapSize/2) / math.sqrt(tvec.x*tvec.x+tvec.y*tvec.y)
					scaled = true
				end
				izoom = math.min(zoom,15)
				if scaled then
					izoom = izoom/Config.farMul
				end
				if alive(item.unit) and not self:_isSpecial(item.unit) and (item.type == 1) and (item.unit:in_slot(12) or item.unit:in_slot(21) or item.unit:in_slot(22)) then
					izoom = izoom/Config.normalMul
				end

				local pxPos = {x=c.x+tvec.x,y=c.y-tvec.y}
				if mr then pxPos = theta(pxPos,yaw+180,c) end
				if pxPos then
					item.cx = pxPos.x
					item.cy = pxPos.y
					if item.bmp then
						item.bmp:set_size(dotSize/izoom,dotSize/izoom*item.ratio)
						item.bmp:set_position(b,b)
--						item.bmp:set_center(b+dotSize/izoom/2,b+dotSize/izoom*item.ratio/2)
						if rot then
							item.bmp:set_rotation(-rot+(mr and yaw or 180))
						else
							if item.type == 1 then
								item.bmp:set_rotation((mr and 0 or 180-yaw))
							end
						end
					end
					if item.decaying and alive(item.decaying) then
						item.decaying:set_center(b+dotSize/izoom/2,b+dotSize/izoom/2)
						item.decaying:set_size(dotSize/izoom,dotSize/izoom)
					end
					if item.bg then

						item.bg:set_size(dotSize/izoom+2*b,dotSize/izoom*item.ratio+2*b)
						if rot then
							item.bg:set_rotation(-rot+(mr and yaw or 180))
						else
							if item.type == 1 then
								item.bg:set_rotation((mr and 0 or 180-yaw))
							end
						end
						item.bg:set_center(dotSize/izoom/2+b,dotSize/izoom/2*item.ratio+b)
					end
					if item.lastSize ~= dotSize/izoom+2*b then
						item.lastSize = dotSize/izoom+2*b
						item.pnl:set_size(dotSize/izoom+2*b,dotSize/izoom*item.ratio+2*b)
					end
					if item.type == 4 then -- Polygon
						local rect = clone(item.rect)
						for k,point in pairs(rect) do
							local ppos = Vector3(point.x,point.y,self.pos.z)
		--					Application:draw_sphere( ppos, 10, 0,1,1 )
							local pvec = (self.cam_pos - ppos) / zoom
							local p = {x=c.x+pvec.x,y=c.y-pvec.y}
							if mr then p = theta({x=c.x+pvec.x,y=c.y-pvec.y},yaw+180,c) end
							rect[k] = Vector3(p.x,p.y)
						end
						item.poly:set_points(rect)
					else
						--item.pnl:set_alpha(1-opa*opa*opa)
						item.pnl:set_center(item.cx,item.cy)
					end
					item.pnl:set_visible(true)
				end
			end
		end
	end
end
local _lastFarScan = 0
function TPocoMap:_Scan(t)
	-- 1. Scan Units
	local updateFar = false
	if t-_lastFarScan > optScan then
		updateFar = true
		_lastFarScan = t
	end

	local units = World:find_units_quick( "all", managers.slot:get_mask('persons')--[[+20+23 = pickups]] )
	local objs = managers.interaction._interactive_objects or {}
	for id, obj in pairs( objs ) do
		if alive( obj ) and not (obj:character_damage() and obj:character_damage():dead() ) then
			table.insert(units,obj)
			--__('id is ',obj:id())
		end
	end
	--[[local units = clone(managers.enemy:all_enemies())
	for id, data in pairs( managers.criminals._characters ) do
		if data.taken and alive( data.unit ) then
			table.insert(units,data.unit)
		end
	end]]
	-- 2. Add Items

	for k,unit in pairs(units) do
		if not unit.id then
			unit = unit.unit
		end
--		local dist = (self.pos - unit:position()):length()
		local key = unit:id()
		local itm
		local tweak = unit:interaction() and unit:interaction().active and unit:interaction().tweak_data or false
		if unit:in_slot( managers.slot:get_mask( "players" ) ) and unit:base().is_husk_player then
			itm = {
				type = 1,
				unit = unit
			}
		elseif (tweak and not unit:movement()) or unit:in_slot( 20 ) or unit:in_slot( 23 ) then -- pickup
			itm = {
				type = 2,
				unit = unit
			}
		else
			local utweak = unit:base() and unit:base()._tweak_table or 'none'
			local isSpecial = (tweak_data.character[ utweak ] or {}).priority_shout
			if isSpecial or not Config.ignoreNormal then
				itm = {
					type = 1,
					decay = 1,
					unit = unit
				}
			end
		end
		if itm then
			self:AddItem(key,itm,t)
		end
	end
	-- 2-1. Add waypoints
	objs = managers.hud._hud.waypoints or {}
	for id, wp in pairs( objs ) do
		local itm = {
			type = 3,
			unit = wp.unit,
			pos = wp.position,
			iconText = wp.init_data.icon or 'wp_standard'
		}
		self:AddItem('wp'..id,itm,t)
	end
	-- 3. scanOOBBs
	if true then
		local rects, poss = self:_check_area2(self.pos)
		for k,v in pairs( rects ) do
			self:AddItem('obb'..k,{
				type = 4,
				pos = poss[k],
				rect = v
			},t)
		end
	end
	-- 3. Decay Items
	for key,item in pairs(self.items) do
		if item.t < t then
			if item.decay and item.t > t-Config.dotDecay then
				if item.pnl then
					if item.type == 1 and not item.decaying then
						local texture, rect = tweak_data.hud_icons:get_icon_data( 'icon_addon' )--'guis/textures/pd2/hitconfirm'
						item.decaying=item.pnl:bitmap( { name = 'decay', texture = texture, texture_rect = rect, rotation = 45, x = 0, y = 0, color = item.fg, layer=2 , w = Config.dotSize,h = Config.dotSize} )
						if item.bmp then
							item.bmp:set_alpha(0)
						end
						if item.bg then
							item.bg:set_alpha(0)
						end
					else
						item.decaying:set_alpha(1-(t-item.t)/Config.dotDecay)
					end
				end
			else
				if item.created then
					self.pnl:remove(item.pnl)
				end
				self.items[key] = nil
			end
		end
	end
end
function TPocoMap:AddItem(key,data,t)
	local itm = self.items[key] or {}
	local b = Config.dotBorder
	self.items[key] = itm
	for k,v in pairs(data) do
		itm[k] = v
	end
	itm.pos = data.pos or itm.unit and itm.unit:position()
	itm.rot = data.rot or itm.unit and itm.unit:movement() and itm.unit:movement().m_rot and itm.unit:movement():m_rot():yaw()
	itm.t = t
	itm.ratio = itm.ratio or 1
	if itm.fg and itm.fg ~= self:GetDot(itm.unit,itm) then
		itm.bmp = nil
		itm.bg = nil
		itm.lastSize = 0
		self.pnl:remove(itm.pnl)
		itm.created = false
	end
	if not itm.created then
		local clFg,clBg,icon,iconrect = self:GetDot(itm.unit,itm)
		itm.fg = clFg
		itm._typ = itm.type..tostring(clFg)..tostring(icon or '')..(iconrect and iconrect[1] or '')
		itm.created = true
		itm.pnl = self.pnl:panel({name = 'pnl'..tostring(math.random()), layer = #self.items, x = 0,y=0 ,w=50,h=50})
		if itm.type == 1 then -- Mob
			itm.ratio = Config.arrowRatio
			itm.bmp = itm.pnl:bitmap( {
				name= "icon",
				texture= icon or 'guis/textures/pd2/scrollbar_arrows',
				texture_rect= iconrect,
				layer= 3,
				color= clFg,
				blend_mode= "normal",
				x= 0,
				y= 0,
				w= 1,
				h= 1
			} )
			--itm.pnl:text{text='1', font=tweak_data.hud_present.title_font, font_size = 10, color = Color.red, x=0,y=0, layer=5}
			itm.bg = itm.pnl:bitmap( {
				name= "icon",
				texture= icon or 'guis/textures/pd2/scrollbar_arrows',
				texture_rect= iconrect,
				layer= 2,
				color= clBg,
				blend_mode= "normal",
				x= 0,
				y= 0,
				w= 1,
				h= 1
			} )
		elseif itm.type == 2 then -- Interactive
			if icon then
				itm.bmp = itm.pnl:bitmap( {
					name= "icon",
					texture= icon,
					texture_rect= iconrect or {84, 34, 19, 19},
					layer= icon and 2 or 1,
					color= clFg,
					blend_mode= "normal",
					x= 0,
					y= 0,
					w= 1,
					h= 1
				} )
			else
				itm.pnl:set_size(0,0)
			end
		elseif itm.type == 3 then -- wp
		--[[
			local pen = Draw:pen()
			pen:set("screen")
			pen:set(Color("ff0000"))
			pen:circle(screen_position, 10)]]
			itm.bmp = itm.pnl:bitmap( {
				name= "icon",
				texture= icon,
				texture_rect= iconrect,
				layer= 3,
				color= clFg,
				blend_mode= "normal",
				x= 0,
				y= 0,
				w= 1,
				h= 1
			} )
			itm.bg = itm.pnl:bitmap( {
				name= "icon",
				texture= icon,
				texture_rect= iconrect,
				layer= 2,
				color= clBg,
				blend_mode= "normal",
				x= 0,
				y= 0,
				w= 1,
				h= 1
			} )
		elseif itm.type == 4 then -- obstacle Rect
			itm.poly = itm.pnl:polyline( {
--				visible= false,
				name= "map",
				color= Color.white:with_alpha(0.2),
				layer= 1,
				line_width= 1,
				closed= true
			} )
		end
	end
end
local _slotmask = managers.slot:get_mask( "statics_layer" )
local _bodies, _lastArea = {},0
function TPocoMap:_check_area2(pos)
	local h = 70
	local limit = Config.polyLimit
	local t = now()
	if t-_lastArea > optMap then
		_lastArea = t
		local posA = pos - math.UP*h/2
		local posB = pos + math.UP*h/2
		_bodies = World:find_bodies( "intersect", "cylinder", posA, posB, Config.rangeMin/2, _slotmask )
	end
	local bodies = _bodies
	local rects, poss = {}, {}
	for i,body in ipairs(bodies) do
		if #poss > limit then break end
		if alive(body) then
			local oobb = body:oobb()
			local s = oobb:size()/2
			if s.z < 50 or oobb:area() < 10000000 then
				local rot = body:rotation():yaw()
				local m = oobb:center()
	--			oobb:debug_draw()
				if math.max(s.x,s.y) < 300 then
		--			Application:draw_sphere(Vector3(m.x+s.x,m.y+s.y,m.z),20,1,0,1)
					rects[i] = {
						theta({x=m.x+s.x,y=m.y+s.y},rot,m),
						theta({x=m.x-s.x,y=m.y+s.y},rot,m),
						theta({x=m.x-s.x,y=m.y-s.y},rot,m),
						theta({x=m.x+s.x,y=m.y-s.y},rot,m)
					}
					poss[i] = m
				end
			end
		end
	end
	return rects, poss
end
local _lastClock,_lastCarry = 0,nil
function TPocoMap:_update(t)
	if self.dead then return end
	if not self.shown and game_state_machine:current_state_name() ~= "ingame_waiting_for_players" then
		self.pnl:show()
	end
	self.cam_pos = managers.viewport:get_current_camera_position()
	self.pos = safeGet('managers.player:player_unit():position()',self.cam_pos)
	self.cam_rot = managers.viewport:get_current_camera_rotation()
	if not (self.pos and self.cam_rot)  then
		self:free()
	end
	local speed = safeGet('managers.player:player_unit():movement():current_state()._last_velocity_xy:length()',0)
	local isADS = safeGet('managers.player:player_unit():movement():current_state()._state_data.in_steelsight')

	self.range_t = math.lerp(Config.rangeMin,Config.rangeMax, speed/600)
	if managers.network:game() and (self.memberCache_t or 0) < t - 1 then
		self.memberCache_t = t
		self.memberCache = {}
		for k,m in pairs(managers.network:game()._members) do
			if m:unit() then
				self.memberCache[m:unit():key()] = m:peer():id()
			end
		end
	end
	local ray
	if Config.smartRange and self.cam_rot then
		local from = self.cam_pos
		if not from then return end
		local to = from + self.cam_rot:y() * 300000
		ray = World:raycast( "ray", from, to, "slot_mask", managers.slot:get_mask( "explosion_targets" ))
	end
	if isADS and ray then
		self.range_t = math.max(math.ceil((ray.distance+200)/1000)*1000,self.range_t)
	else
		self.range_t = Config.rangeMin
	end

	local range_mul = managers.player:upgrade_value( "player", "intimidate_range_mul", 1 ) * managers.player:upgrade_value( "player", "passive_intimidate_range_mul", 1 )
	local intimidate_range_civ = tweak_data.player.long_dis_interaction.intimidate_range_civilians * range_mul

	local r = self.range or self.range_t
	self.range = r+(self.range_t-r)/10
	self.rangeRate = intimidate_range_civ / self.range
	local ms = Config.mapSize*self.rangeRate
	self.areaBg:set_size(ms,ms)
	self.areaBg:set_alpha(1-self.rangeRate*self.rangeRate)
	self.areaBg:set_center(self._cx,self._cy)
	self:_Scan(t)
	self:_Draw(t)
	if t-_lastClock > 1 or _lastCarry ~= self._carry_text then
		_lastCarry = self._carry_text
		local carry = _lastCarry
		local txts = {}
		if carry then
			table.insert(txts,{carry[1],Color.yellow})
		end
		if not self._bagAnim then
			table.insert(txts,{os.date(' %X '),Color.white})
		end
		self:__fillLbl(self.clockLbl,txts)
		_lastClock = t
	end
end



function TPocoMap:_vectorToScreen(v3pos)
	if not self._ws then return end
	local cam = managers.viewport:get_current_camera()
	return (cam and v3pos) and self._ws:world_to_screen( cam, v3pos )
end

function TPocoMap:free()
	self.dead = true
	for key,hook in pairs(self.hooks or {}) do
		local realKey = key:gsub('*','')
		local Obj,func = hook[1],hook[2]
		Obj[realKey] = func
		self.hooks[key] = nil
	end
	if managers.hud then
		managers.hud:remove_updator('drawPocoMap')
	end
	if self._resolution_changed_callback_id then
		managers.viewport:remove_resolution_changed_func( self._resolution_changed_callback_id  )
	end

	Overlay:gui():destroy_workspace(self._ws)
end

if PocoMap and not PocoMap.dead then
	PocoMap:free()
else
	PocoMap = TPocoMap:new()
end
