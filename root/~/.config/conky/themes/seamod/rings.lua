--==============================================================================
--                            seamod_rings.lua
--
--  Date    : 2016/08/14
--  Author  : SeaJey, modified by JPvRiel
--  Version : v0.2
--  License : Distributed under the terms of GNU GPL version 2 or later
--
--  This version is a modification of lunatico_rings.lua wich is modification of conky_orange.lua
--
--  conky_orange.lua:    http://gnome-look.org/content/show.php?content=137503&forumpage=0
--  lunatico_rings.lua:  http://gnome-look.org/content/show.php?content=142884
--==============================================================================

require 'cairo'


gauge = {

--====--
-- Data here is loaded only once when included and is therefore static
-- 'name' and 'arg' for simple conky objects with static arguments
-- 'conky_line' for complex, conditional and dynamic behaviour
-- 'conky_line' supercedes 'name' and 'arg' (in case both are present)
--====--

-- CPU rings
{
    name='cpu',                    arg='cpu1',                  max_value=100,
    x=70,                          y=85,
    graph_radius=60,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                  txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=0,        graduation_mark_thickness=1,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='CPU 1',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.6,
},
{
    name='cpu',                    arg='cpu2',                  max_value=100,
    x=70,                          y=85,
    graph_radius=53,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                  txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=0,        graduation_mark_thickness=1,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='CPU 2',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.6,
},
{
    name='cpu',                    arg='cpu3',                  max_value=100,
    x=70,                          y=85,
    graph_radius=46,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                  txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=0,        graduation_mark_thickness=1,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='CPU 3',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.6,
},
{
    name='cpu',                    arg='cpu4',                  max_value=100,
    x=70,                          y=85,
    graph_radius=39,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                  txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=28,
    graduation_thickness=0,        graduation_mark_thickness=1,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='CPU 4',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.6,
},
-- Memory rings
{
    name='memperc',                arg='',                      max_value=100,
    x=70,                          y=256,
    graph_radius=60,
    graph_thickness=10,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=54,
    graduation_thickness=0,        graduation_mark_thickness=2,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.5,
    caption='RAM',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    name='swapperc',               arg='',                      max_value=100,
    x=70,                          y=256,
    graph_radius=45,
    graph_thickness=10,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=23,
    graduation_thickness=0,        graduation_mark_thickness=2,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.5,
    caption='SWAP',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
-- Network rings
{
    --conky_line='${if_up eth0}${downspeedf eth0}${else}${if_up wlan0}{downspeedf wlan0}${endif}${endif}',
    conky_line='${if_match "${addr eth0}" != "No Address"}${downspeedf eth0}${else}${if_match "${addr wlan0}" != "No Address"}${downspeedf wlan0}${endif}${endif}',
    name='downspeedf',             arg='eth0',                  max_value=100,
    x=70,                          y=427,
    graph_radius=60,
    graph_thickness=8,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=68,
    graduation_thickness=0,        graduation_mark_thickness=2,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='Down',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    --conky_line='${if_up eth0}${upspeedf eth0}${else}${if_up wlan0}${upspeedf wlan0}${endif}${endif}',
    conky_line='${if_match "${addr eth0}" != "No Address"}${upspeedf eth0}${else}${if_match "${addr wlan0}" != "No Address"}${upspeedf wlan0}${endif}${endif}',
    name='upspeedf',               arg='eth0',                  max_value=100,
    x=70,                          y=427,
    graph_radius=48,
    graph_thickness=8,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=56,
    graduation_thickness=0,        graduation_mark_thickness=2,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='Up',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    conky_line='${if_match "${addr wlan0}" != "No Address"}${wireless_link_qual_perc wlan0}${else}0${endif}',
    name='wireless_link_qual_perc', arg='wlan0',                max_value=100,
    x=70,                          y=427,
    graph_radius=30,
    graph_thickness=8,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=38,
    graduation_thickness=3,        graduation_mark_thickness=2,
    graduation_unit_angle=14,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.6,
    caption='Signal',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
-- System info rings
{
    --conky_line='${if_up eth0}${downspeedf eth0}${else}${if_up wlan0}{downspeedf wlan0}${endif}${endif}',
    conky_line='${exec pactl list sinks | grep \'^[[:space:]]Volume:\' | head -n $(( $SINK + 1 )) | tail -n 1 | awk \'{printf $5}\' | awk -F\'[%|:]\' \'{print $1 $2 $3}\'}',
    name='1',             arg='',                  max_value=100,
    x=70,                          y=598,
    graph_radius=60,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=68,
    graduation_thickness=0,        graduation_mark_thickness=2,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='Volume',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    --conky_line='${if_up eth0}${upspeedf eth0}${else}${if_up wlan0}${upspeedf wlan0}${endif}${endif}',
    conky_line='${exec xbacklight}',
    name='Brightness',               arg='',                  max_value=100,
    x=70,                          y=598,
    graph_radius=53,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=56,
    graduation_thickness=0,        graduation_mark_thickness=2,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='Brightness',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    name='battery_percent',        arg='BAT0',               max_value=100,
    x=70,                          y=598,
    graph_radius=39,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=46,
    graduation_thickness=3,        graduation_mark_thickness=2,
    graduation_unit_angle=14,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.6,
    caption='Battery',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},
{
    name='fs_used_perc',           arg='/',                 max_value=100,
    x=70,                          y=598,
    graph_radius=31,
    graph_thickness=5,
    graph_start_angle=180,
    graph_unit_angle=2.7,          graph_unit_thickness=2.7,
    graph_bg_colour=0xffffff,      graph_bg_alpha=0.3,
    graph_fg_colour=0xFFFFFF,      graph_fg_alpha=0.8,
    hand_fg_colour=0xEF5A29,       hand_fg_alpha=1.0,
    txt_radius=0,
    txt_weight=0,                txt_size=8.0,
    txt_fg_colour=0xEF5A29,        txt_fg_alpha=1.0,
    graduation_radius=23,
    graduation_thickness=0,        graduation_mark_thickness=2,
    graduation_unit_angle=27,
    graduation_fg_colour=0xFFFFFF, graduation_fg_alpha=0.3,
    caption='Disk',
    caption_weight=0.8,            caption_size=9.0,
    caption_fg_colour=0xFFFFFF,    caption_fg_alpha=0.5,
},

}

-- converts color in hexa to decimal
function rgb_to_r_g_b(colour, alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

-- convert degree to rad and rotate (0 degree is top/north)
function angle_to_position(start_angle, current_angle)
    local pos = current_angle + start_angle
    return ( ( pos * (2 * math.pi / 360) ) - (math.pi / 2) )
end


-- displays gauges
function draw_gauge_ring(display, data, value, border)
    local max_value = data['max_value']
    local x, y = data['x'] + border, data['y'] + border
    local graph_radius = data['graph_radius']
    local graph_thickness, graph_unit_thickness = data['graph_thickness'], data['graph_unit_thickness']
    local graph_start_angle = data['graph_start_angle']
    local graph_unit_angle = data['graph_unit_angle']
    local graph_bg_colour, graph_bg_alpha = data['graph_bg_colour'], data['graph_bg_alpha']
    local graph_fg_colour, graph_fg_alpha = data['graph_fg_colour'], data['graph_fg_alpha']
    local hand_fg_colour, hand_fg_alpha = data['hand_fg_colour'], data['hand_fg_alpha']
    local graph_end_angle = (max_value * graph_unit_angle) % 360

    -- background ring
    cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, 0), angle_to_position(graph_start_angle, graph_end_angle))
    cairo_set_source_rgba(display, rgb_to_r_g_b(graph_bg_colour, graph_bg_alpha))
    cairo_set_line_width(display, graph_thickness)
    cairo_stroke(display)

    -- arc of value
    local val = value % (max_value + 1)
    local start_arc = 0
    local stop_arc = 0
    local i = 1
    while i <= val do
        start_arc = (graph_unit_angle * i) - graph_unit_thickness
        stop_arc = (graph_unit_angle * i)
        cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
        cairo_set_source_rgba(display, rgb_to_r_g_b(graph_fg_colour, graph_fg_alpha))
        cairo_stroke(display)
        i = i + 1
    end
    local angle = start_arc

    -- hand
    start_arc = (graph_unit_angle * val) - (graph_unit_thickness)
    stop_arc = (graph_unit_angle * val)
    cairo_arc(display, x, y, graph_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
    cairo_set_source_rgba(display, rgb_to_r_g_b(hand_fg_colour, hand_fg_alpha))
    cairo_stroke(display)

    -- graduations marks
    local graduation_radius = data['graduation_radius']
    local graduation_thickness, graduation_mark_thickness = data['graduation_thickness'], data['graduation_mark_thickness']
    local graduation_unit_angle = data['graduation_unit_angle']
    local graduation_fg_colour, graduation_fg_alpha = data['graduation_fg_colour'], data['graduation_fg_alpha']
    if graduation_radius > 0 and graduation_thickness > 0 and graduation_unit_angle > 0 then
        local nb_graduation = graph_end_angle / graduation_unit_angle
        local i = 0
        while i < nb_graduation do
            cairo_set_line_width(display, graduation_thickness)
            start_arc = (graduation_unit_angle * i) - (graduation_mark_thickness / 2)
            stop_arc = (graduation_unit_angle * i) + (graduation_mark_thickness / 2)
            cairo_arc(display, x, y, graduation_radius, angle_to_position(graph_start_angle, start_arc), angle_to_position(graph_start_angle, stop_arc))
            cairo_set_source_rgba(display,rgb_to_r_g_b(graduation_fg_colour,graduation_fg_alpha))
            cairo_stroke(display)
            cairo_set_line_width(display, graph_thickness)
            i = i + 1
        end
    end

    -- text
    local txt_radius = data['txt_radius']
    local txt_weight, txt_size = data['txt_weight'], data['txt_size']
    local txt_fg_colour, txt_fg_alpha = data['txt_fg_colour'], data['txt_fg_alpha']
    local movex = txt_radius * math.cos(angle_to_position(graph_start_angle, angle))
    local movey = txt_radius * math.sin(angle_to_position(graph_start_angle, angle))
    cairo_select_font_face (display, "ubuntu", CAIRO_FONT_SLANT_NORMAL, txt_weight)
    cairo_set_source_rgba (display, rgb_to_r_g_b(txt_fg_colour, txt_fg_alpha))
    cairo_set_font_size (display, txt_size)
    if txt_radius > 0 then
        cairo_move_to (display, x + movex - (txt_size / 2), y + movey + 3)
        cairo_show_text (display, value)
        cairo_stroke (display)
    end

    -- caption
    local caption = data['caption']
    local caption_weight, caption_size = data['caption_weight'], data['caption_size']
    local caption_fg_colour, caption_fg_alpha = data['caption_fg_colour'], data['caption_fg_alpha']
    local tox = graph_radius * (math.cos((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
    local toy = graph_radius * (math.sin((graph_start_angle * 2 * math.pi / 360)-(math.pi/2)))
    cairo_select_font_face (display, "ubuntu", CAIRO_FONT_SLANT_NORMAL, caption_weight);
    cairo_set_font_size (display, caption_size)
    cairo_set_source_rgba (display, rgb_to_r_g_b(caption_fg_colour, caption_fg_alpha))
    cairo_move_to (display, x + tox + 5, y + toy + 5)
    -- bad hack but not enough time !
    if graph_start_angle < 105 then
        cairo_move_to (display, x + tox - 30, y + toy + 1)
    end
    cairo_show_text (display, caption)
    cairo_stroke (display)
end


-- loads data and displays gauges
function go_gauge_rings(display, border)
    local function load_gauge_rings(display, data)
        local str, value = '', 0
        if data['conky_line'] == nil then
            str = string.format('${%s %s}',data['name'], data['arg'])
        else
            str = data['conky_line']
        end
        str = conky_parse(str)
        value = tonumber(str)
        if (value == nil) then
            value = 0
        else
            value = math.floor(value + 0.5)
        end

        draw_gauge_ring(display, data, value, border)
    end

    for i in pairs(gauge) do
        load_gauge_rings(display, gauge[i])
    end

end


function disk_watch()
    local disk = 0
    warn_disk=90
    crit_disk=96

    disk=tonumber(conky_parse("${fs_used_perc /}"))

    if disk<warn_disk then
        gauge[13]['graph_fg_colour']=0xFFFFFF
    elseif disk<crit_disk then
        gauge[13]['graph_fg_colour']=0xff7200
    else
        gauge[13]['graph_fg_colour']=0xff000d
    end
end

function battery_watch()
    local disk, batt_status = 0, ''
    warn_batt=20
    crit_batt=10

    batt=tonumber(conky_parse("${battery_percent}"))

    if batt>warn_batt then
        gauge[12]['graph_fg_colour']=0xFFFFFF
    elseif batt>crit_batt then
        gauge[12]['graph_fg_colour']=0xff7200
    else
        gauge[12]['graph_fg_colour']=0xff000d
    end

    batt_status=(string.find(conky_parse("${battery_short}"), "D"))
    if batt_status==nil then
        gauge[12]['hand_fg_colour']=0x77B753
        gauge[12]['graph_fg_alpha']=0.4
        gauge[12]['caption_fg_colour']=0x77B753
        gauge[12]['caption_fg_alpha']=1
    else
        gauge[12]['hand_fg_colour']=0xEF5A29
        gauge[12]['graph_fg_alpha']=0.8
        gauge[12]['caption_fg_colour']=0xFFFFFF
        gauge[12]['caption_fg_alpha']=0.5
    end

end

function mute_watch()

    mute=tonumber(conky_parse("${exec amixer -D pulse sget 'Master' | grep off | cut -c 25 | head -1}"))
    if mute==nil then
        gauge[10]['graph_fg_colour']=0xFFFFFF
    else
        gauge[10]['graph_fg_colour']=0x4B1B0C
    end

end

-------------------------------------------------------------------------------
--                                                                         MAIN
function conky_main()
    if conky_window == nil then
        return
    end

    local cs = cairo_xlib_surface_create(conky_window.display, conky_window.drawable, conky_window.visual, conky_window.width, conky_window.height)
    local display = cairo_create(cs)

    disk_watch()
    battery_watch()
    mute_watch()
    go_gauge_rings(display, conky_window.border_outer_margin)

    cairo_surface_destroy(cs)
    cairo_destroy(display)
end
