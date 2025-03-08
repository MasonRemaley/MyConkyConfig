require 'cairo'

nproc = io.popen("nproc")
cores = tonumber(nproc:read())
nproc:close()

function rgbFromHsv(hsv)
    local hue = hsv.h
    local chroma = hsv.s * hsv.v
    local value = hsv.v
    local min = value - chroma
    if hsv.h <= 1.0 / 6.0 then
        return { r = value, g = chroma * 6.0 * hue + min, b = min }
    elseif hue <= 2.0 / 6.0 then
        return { r = chroma * (2.0 - 6.0 * hue) + min, g = value, b = min }
    elseif hue <= 3.0 / 6.0 then
        return { r = min, g = value, b = chroma * (6.0 * hue - 2.0) + min }
    elseif hue <= 4.0 / 6.0 then
        return { r = min, g = chroma * (4.0 - 6.0 * hue) + min, b = value }
    elseif hue <= 5.0 / 6.0 then
        return { r = chroma * (6.0 * hue - 4.0) + min, g = min, b = value }
    elseif hue <= 6.0 / 6.0 then
        return { r = value, g = min, b = chroma * (6.0 - 6.0 * hue) + min }
    end
    return { r = 0, g = 0, b = 0 }
end

function lerp(a, b, t)
    return (1.0 - t) * a + b * t
end

function min(a, b)
    if (a < b) then
        return a
    else
        return b
    end
end

function conky_render()
    -- This happens the first frame
    if conky_window == nil then
        return
    end

    -- Create the surface
    local cr = cairo_create(cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height
    ))

    local padding_top = 4
    local padding_bottom = 6
    local bar_width = 6
    local y = conky_window.height
    local x = bar_width / 2
    local font_size = 18

    -- CPU usage
    cairo_set_line_width (cr, bar_width)
    cairo_set_antialias(cr, CAIRO_ANTIALIAS_NONE)
    for i = 1, cores do
        local color = rgbFromHsv({
            h = (0.55 + (i - 1) / (cores - 1)) % 1.0,
            s = 0.8,
            v = 1,
        })
        cairo_set_source_rgba(cr, color.r, color.g, color.b, 1)
        local usage = conky_parse('${cpu cpu' .. i .. '}') / 100
        local min_y = conky_window.height - padding_bottom
        local max_y = padding_top
        local end_y = lerp(min_y, max_y, usage)
        if math.ceil(end_y) >= math.ceil(min_y) then
            end_y = min_y - 1
        end
        cairo_move_to(cr, x, min_y)
        cairo_line_to (cr, x, end_y)
        cairo_stroke (cr)
        x = x + bar_width + 2
    end
    x = x + 40

    -- RAM & SSD usage
    cairo_set_antialias(cr, ANTIALIAS_DEFAULT)
    cairo_set_font_size(cr, font_size)
    cairo_move_to(cr, x, padding_top + font_size)
    cairo_set_source_rgba(cr, 1, 1, 1, 1)
    cairo_show_text(cr, string.format(
        "RAM: %.0f%%",
        conky_parse('$memperc'))
    )

    cairo_move_to(cr, x, conky_window.height - padding_bottom)
    cairo_set_source_rgba(cr, 1, 1, 1, 1)
    cairo_show_text(cr, string.format(
        "SSD: %.0f%%",
        conky_parse('$fs_used_perc'))
    )
    x = x + 100

    -- CPU & GPU temperatures (may be hardware dependent, see `/sys/class/hwmon`)
    cairo_move_to(cr, x, padding_top + font_size)
    cairo_set_source_rgba(cr, 1, 1, 1, 1)
    cairo_show_text(cr, string.format(
        "CPU: %.0f°C",
        conky_parse('${hwmon 2 temp 1}'))
    )

    cairo_move_to(cr, x, conky_window.height - padding_bottom)
    cairo_set_source_rgba(cr, 1, 1, 1, 1)
    cairo_show_text(cr, string.format(
        "GPU: %.0f-%.0f°C",
        conky_parse('${hwmon 4 temp 1}'),
        conky_parse('${hwmon 5 temp 1}')
    ))

    -- Clean up
    cairo_destroy(cr)
end
