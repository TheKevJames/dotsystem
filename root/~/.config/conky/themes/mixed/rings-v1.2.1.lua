--[[
    arg=conky_parse("${if_up wlan0}wlan0${else}eth0${endif}"),
    fg_colour=0xf0651f,
    fg_colour=conky_parse("${if_up wlan0}wlan0${else}eth0${endif}"),
    conky_parse("${cpu}")
    name=conky_parse("${acpitemp}"),
]]

-- A TESTER
--set alarm value, this is the value at which bar color will change
--alarm_value=80
----set alarm bar color, 1,0,0,1 = red fully opaque
--ar,ag,ab,aa=1,0,0,1

-- couleurs 1
-- AAF334
-- f0651f
-- f01f42
-- couleurs 2 + flashy
-- 008cff
-- ff7200
-- ff000d

--normal_temp="0xAAF334"
--warn_temp="0xf0651f"
--crit_temp="0xf01f42"
-- Un mélange des deux
normal="0xAAF334"
warn="0xff7200"
crit="0xff000d"

-- seulement quand fond nécessaire
corner_r=35
bg_colour=0x333333
bg_alpha=0.2


settings_table = {
    {
        name='acpitemp',
        arg='',
        max=110,
        bg_colour=0xdddddd,
        bg_alpha=0.8,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=200, y=120,
        radius=97,
        thickness=4,
        start_angle=0,
        end_angle=240
    },
    {
        name='cpu',
        arg='cpu0',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.8,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=200, y=120,
        radius=86,
        thickness=13,
        start_angle=0,
        end_angle=240
    },
    {
        name='cpu',
        arg='cpu1',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.7,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=200, y=120,
        radius=71,
        thickness=12,
        start_angle=0,
        end_angle=240
    },
    {
        name='cpu',
        arg='cpu2',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.6,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=200, y=120,
        radius=57,
        thickness=11,
        start_angle=0,
        end_angle=240
    },
    {
        name='cpu',
        arg='cpu3',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.5,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=200, y=120,
        radius=44,
        thickness=10,
        start_angle=0,
        end_angle=240
    },
    {
        name='memperc',
        arg='',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.8,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=340, y=234,
        radius=60,
        thickness=15,
        start_angle=180,
        end_angle=420
    },
    {
        name='swapperc',
        arg='',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.4,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=340, y=234,
        radius=45,
        thickness=10,
        start_angle=180,
        end_angle=420
    },
    {
        name='fs_used_perc',
        arg='/',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.8,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=220, y=280,
        radius=40,
        thickness=10,
        start_angle=0,
        end_angle=240
    },
    {
        name='fs_used_perc',
        arg='/home',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.6,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=220, y=280,
        radius=28,
        thickness=10,
        start_angle=0,
        end_angle=240
    },
    {
        name='fs_used_perc',
        arg='/usr',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.4,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=220, y=280,
        radius=16,
        thickness=10,
        start_angle=0,
        end_angle=240
    },
    {
        name='downspeedf',
        arg='eth0',
        max=10000,
        bg_colour=0xdddddd,
        bg_alpha=0.8,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=290, y=346,
        radius=30,
        thickness=12,
        start_angle=180,
        end_angle=420
    },
    {
        name='upspeedf',
        arg='eth0',
        max=1000,
        bg_colour=0xdddddd,
        bg_alpha=0.6,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=290, y=346,
        radius=18,
        thickness=8,
        start_angle=180,
        end_angle=420
    },
    {
        name='time',
        arg='%S',
        max=60,
        bg_colour=0xdddddd,
        bg_alpha=0.8,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=230, y=410,
        radius=30,
        thickness=12,
        start_angle=0,
        end_angle=240
    },
    {
        name='time',
        arg='%M',
        max=60,
        bg_colour=0xdddddd,
        bg_alpha=0.6,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=230, y=410,
        radius=18,
        thickness=8,
        start_angle=0,
        end_angle=240
    },
    {
        name='time',
        arg='%H',
        max=24,
        bg_colour=0xdddddd,
        bg_alpha=0.4,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=230, y=410,
        radius=10,
        thickness=4,
        start_angle=0,
        end_angle=240
    },
    {
        name='battery_percent',
        arg='',
        max=100,
        bg_colour=0xdddddd,
        bg_alpha=0.6,
        fg_colour=0xAAF334,
        fg_alpha=0.8,
        x=274, y=464,
        radius=18,
        thickness=10,
        start_angle=180,
        end_angle=420
    },
    {
        name='battery_percent',
        arg='',
        max=150,
        bg_colour=0xdddddd,
        bg_alpha=0.6,
        fg_colour=0xAAF334,
        fg_alpha=0.6,
        x=274, y=464,
        radius=3,
        thickness=13,
        start_angle=180,
        end_angle=540
    }
}

require 'cairo'

function rgb_to_r_g_b(colour,alpha)
	return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
	local w,h=conky_window.width,conky_window.height

	local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
	local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

	local angle_0=sa*(2*math.pi/360)-math.pi/2
	local angle_f=ea*(2*math.pi/360)-math.pi/2
	local t_arc=t*(angle_f-angle_0)

	-- Draw background ring

	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
	cairo_set_line_width(cr,ring_w)
	cairo_stroke(cr)

	-- Draw indicator ring

	cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
	cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
	cairo_stroke(cr)
end

function conky_ring_stats()
	local function setup_rings(cr,pt)
		local str=''
		local value=0

		str=string.format("${%s %s}", pt['name'], pt['arg'])
		str=conky_parse(str)

		value=tonumber(str)
		if value == nil then value = 0 end
		pct=value/pt['max']

		draw_ring(cr,pct,pt)
	end

	if conky_window==nil then return end
	local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

	local cr=cairo_create(cs)

	local updates=conky_parse("${updates}")
	update_num=tonumber(updates)

	if update_num>5 then
	    for i in pairs(settings_table) do
                display_temp=temp_watch()
		setup_rings(cr,settings_table[i])
	    end
	end
   cairo_surface_destroy(cs)
  cairo_destroy(cr)
end

-- Contrôle de l'espace disque
function disk_watch()

    warn_disk=90
    crit_disk=95

    -- poser une boucle plus tard... pas simple

    disk=tonumber(conky_parse("${fs_used_perc /}"))

    if disk<warn_disk then
        settings_table[8]['fg_colour']=normal
    elseif disk<crit_disk then
        settings_table[8]['fg_colour']=warn
    else
        settings_table[8]['fg_colour']=crit
    end

    disk=tonumber(conky_parse("${fs_used_perc /home}"))

    if disk<warn_disk then
        settings_table[9]['fg_colour']=normal
    elseif disk<crit_disk then
        settings_table[9]['fg_colour']=warn
    else
        settings_table[9]['fg_colour']=crit
    end

    disk=tonumber(conky_parse("${fs_used_perc /usr}"))

    if disk<warn_disk then
        settings_table[10]['fg_colour']=normal
    elseif disk<crit_disk then
        settings_table[10]['fg_colour']=warn
    else
        settings_table[10]['fg_colour']=crit
    end
end

-- Contrôle de la température
function temp_watch()

    warn_value=70
    crit_value=85

    temperature=tonumber(conky_parse("${acpitemp}"))

    if temperature<warn_value then
        settings_table[1]['fg_colour']=normal
    elseif temperature<crit_value then
        settings_table[1]['fg_colour']=warn
    else
        settings_table[1]['fg_colour']=crit
    end
end

-- Contrôle de l'interface active
function iface_watch()
    iface=conky_parse("${if_up wlan0}wlan0${else}eth0${endif}")

    settings_table[11]['arg']=iface
    settings_table[12]['arg']=iface
end

function conky_draw_bg()
    if conky_window==nil then return end
    local w=conky_window.width
    local h=conky_window.height
    local cs=cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, w, h)
    cr=cairo_create(cs)

    cairo_move_to(cr,corner_r,0)
    cairo_line_to(cr,w-corner_r,0)
    cairo_curve_to(cr,w,0,w,0,w,corner_r)
    cairo_line_to(cr,w,h-corner_r)
    cairo_curve_to(cr,w,h,w,h,w-corner_r,h)
    cairo_line_to(cr,corner_r,h)
    cairo_curve_to(cr,0,h,0,h,0,h-corner_r)
    cairo_line_to(cr,0,corner_r)
    cairo_curve_to(cr,0,0,0,0,corner_r,0)
    cairo_close_path(cr)

    cairo_set_source_rgba(cr,rgb_to_r_g_b(bg_colour,bg_alpha))
    cairo_fill(cr)
end


function conky_main()
    temp_watch()
    disk_watch()
    iface_watch()
    conky_ring_stats()
-- quand fond nécessaire
--    conky_draw_bg()
end
