-- ==========================================
-- CONFIGURATION: Adjustment Step Sizes
-- ==========================================
local STEP_NATIVE = {
    brightness = 0.1,
    contrast   = 0.5,
    gamma      = 0.1
}

local STEP_RGB = {
    brightness = 0.1,
    contrast   = 0.005,
    gamma      = 0.01
}
-- ==========================================

-- Current Mode: "all", "red", "green", or "blue"
local mode = "all"

-- Channel Values: Brightness (b), Contrast (c), Gamma (g)
local r = { b = 0.0, c = 1.0, g = 1.0 }
local g = { b = 0.0, c = 1.0, g = 1.0 }
local b = { b = 0.0, c = 1.0, g = 1.0 }


local initialized_from_vf = false

local function load_settings_from_vf()
    if initialized_from_vf then return end
    
    local vf = mp.get_property("vf")
    if not vf or vf == "" then return end

    -- 1. Adjusted structural check matching the actual output format
    local check_pat = "lavfi=graph=%%?%d+%%?lutrgb=r='.-':g='.-':b='.-'"
    if not vf:match(check_pat) then return end

    -- 2. Full parsing pattern using the correct wrapper structure
    local ch_pat = "%(%(pow%(val/maxval,1/([%d%.]+)%)%-0%.5%)%*([%d%.]+)%)%*maxval%+128([%+%-%d%.]+)"
    local full_pat = "lavfi=graph=%%?%d+%%?lutrgb=r='" .. ch_pat .. "':g='" .. ch_pat .. "':b='" .. ch_pat .. "'"

    local rg, rc, rb, 
          gg, gc, gb, 
          bg, bc, bb = vf:match(full_pat)

    if rg and rc and rb and gg and gc and gb and bg and bc and bb then
        r = { g = tonumber(rg), c = tonumber(rc), b = tonumber(rb) }
        g = { g = tonumber(gg), c = tonumber(gc), b = tonumber(gb) }
        b = { g = tonumber(bg), c = tonumber(bc), b = tonumber(bb) }
        initialized_from_vf = true
        
        mp.msg.info("Successfully parsed and loaded all R/G/B settings from active vf property!")
        mp.msg.info(string.format("Loaded Structs -> Red: [B:%.1f, C:%.1f, G:%.1f] | Green: [B:%.1f, C:%.1f, G:%.1f] | Blue: [B:%.1f, C:%.1f, G:%.1f]",
            r.b, r.c, r.g, 
            g.b, g.c, g.g, 
            b.b, b.c, b.g))
        
        -- Unobserve once successfully loaded so it doesn't run again
        mp.unobserve_property(load_settings_from_vf)
    end
end

-- Try loading immediately on script startup
load_settings_from_vf()

-- If it wasn't available yet, observe the "vf" property until it populates
if not initialized_from_vf then
    mp.observe_property("vf", "string", load_settings_from_vf)
end


-- Generate simple, valid lutrgb expressions with proper sign handling for brightness
local function build_channel_expr(ch)
    local b_str = string.format("%.1f", ch.b)
    if ch.b >= 0 then
        b_str = "+" .. b_str
    end
    -- Formula: ((val/maxval)^(1/gamma) - 0.5) * contrast * maxval + 128 [signed brightness]
    return string.format("((pow(val/maxval,1/%.2f)-0.5)*%.2f)*maxval+128%s", ch.g, ch.c, b_str)
end

local function apply_filter()
    if mode == "all" then
        mp.msg.info("Mode: ALL CHANNELS (Native Controls)")
        return
    end

    local expr_r = build_channel_expr(r)
    local expr_g = build_channel_expr(g)
    local expr_b = build_channel_expr(b)

    -- Pass via lavfi wrapper to safely handle complex expressions
    local filter_str = string.format("lavfi=[lutrgb=r='%s':g='%s':b='%s']", expr_r, expr_g, expr_b)

    mp.commandv("set", "vf", filter_str)

    -- Print the generated filter string to the console
    mp.msg.info("Active Filter String: " .. filter_str)

    -- Log channel status in B, C, G order
    mp.msg.info(string.format("[%s MODE] | Red -> B:%.1f C:%.1f G:%.1f | Green -> B:%.1f C:%.1f G:%.1f | Blue -> B:%.1f C:%.1f G:%.1f",
        mode:upper(),
        r.b, r.c, r.g,
        g.b, g.c, g.g,
        b.b, b.c, b.g))
end

-- Mode Selectors
mp.register_script_message("set_mode_all", function()
    mode = "all"
    apply_filter()
end)
mp.register_script_message("set_mode_red", function()
    mode = "red"
    mp.msg.info("Switched to RED MODE")
    apply_filter()
end)
mp.register_script_message("set_mode_green", function()
    mode = "green"
    mp.msg.info("Switched to GREEN MODE")
    apply_filter()
end)
mp.register_script_message("set_mode_blue", function()
    mode = "blue"
    mp.msg.info("Switched to BLUE MODE")
    apply_filter()
end)

-- Reset All Functionality (Shift+F9)
mp.register_script_message("reset_all", function()
    mode = "all"
    r = { b = 0.0, c = 1.0, g = 1.0 }
    g = { b = 0.0, c = 1.0, g = 1.0 }
    b = { b = 0.0, c = 1.0, g = 1.0 }
    mp.commandv("set", "vf", "")
    mp.commandv("set", "brightness", 0)
    mp.commandv("set", "contrast", 0)
    mp.commandv("set", "gamma", 0)
    mp.commandv("set", "saturation", 0)
    mp.msg.info("RESET ALL: All channels, filters, and native controls restored to default.")
end)

-- Individual Property Resets (Shift+F1, Shift+F3, Shift+F5)
mp.register_script_message("reset_brightness", function()
    local t = get_target()
    if t then
        t.b = 0.0
        apply_filter()
        mp.msg.info(string.format("[%s MODE] Brightness reset to 0", mode:upper()))
    else
        mp.commandv("set", "brightness", 0)
        mp.msg.info("Native Mode | Brightness reset to 0")
    end
end)

mp.register_script_message("reset_contrast", function()
    local t = get_target()
    if t then
        t.c = 1.0
        apply_filter()
        mp.msg.info(string.format("[%s MODE] Contrast reset to 1.0", mode:upper()))
    else
        mp.commandv("set", "contrast", 0)
        mp.msg.info("Native Mode | Contrast reset to 0")
    end
end)

mp.register_script_message("reset_gamma", function()
    local t = get_target()
    if t then
        t.g = 1.0
        apply_filter()
        mp.msg.info(string.format("[%s MODE] Gamma reset to 1.0", mode:upper()))
    else
        mp.commandv("set", "gamma", 0)
        mp.msg.info("Native Mode | Gamma reset to 0")
    end
end)

-- Get reference to active channel target table
function get_target()
    if mode == "red" then return r
    elseif mode == "green" then return g
    elseif mode == "blue" then return b
    end
    return nil
end

-- Adjustments (F1 - F6) using top-level configuration step sizes
mp.register_script_message("adjust_brightness_down", function()
    local t = get_target()
    if t then
        t.b = t.b - STEP_RGB.brightness; apply_filter()
    else
        mp.commandv("add", "brightness", -STEP_NATIVE.brightness)
        mp.msg.info(string.format("Native Mode | Brightness decreased (-%.1f)", STEP_NATIVE.brightness))
    end
end)

mp.register_script_message("adjust_brightness_up", function()
    local t = get_target()
    if t then
        t.b = t.b + STEP_RGB.brightness; apply_filter()
    else
        mp.commandv("add", "brightness", STEP_NATIVE.brightness)
        mp.msg.info(string.format("Native Mode | Brightness increased (+%.1f)", STEP_NATIVE.brightness))
    end
end)

mp.register_script_message("adjust_contrast_down", function()
    local t = get_target()
    if t then
        t.c = math.max(0.1, t.c - STEP_RGB.contrast); apply_filter()
    else
        mp.commandv("add", "contrast", -STEP_NATIVE.contrast)
        mp.msg.info(string.format("Native Mode | Contrast decreased (-%.1f)", STEP_NATIVE.contrast))
    end
end)

mp.register_script_message("adjust_contrast_up", function()
    local t = get_target()
    if t then
        t.c = math.min(10.0, t.c + STEP_RGB.contrast); apply_filter()
    else
        mp.commandv("add", "contrast", STEP_NATIVE.contrast)
        mp.msg.info(string.format("Native Mode | Contrast increased (+%.1f)", STEP_NATIVE.contrast))
    end
end)

mp.register_script_message("adjust_gamma_down", function()
    local t = get_target()
    if t then
        t.g = math.max(0.1, t.g - STEP_RGB.gamma); apply_filter()
    else
        mp.commandv("add", "gamma", -STEP_NATIVE.gamma)
        mp.msg.info(string.format("Native Mode | Gamma decreased (-%.1f)", STEP_NATIVE.gamma))
    end
end)

mp.register_script_message("adjust_gamma_up", function()
    local t = get_target()
    if t then
        t.g = math.min(10.0, t.g + STEP_RGB.gamma); apply_filter()
    else
        mp.commandv("add", "gamma", STEP_NATIVE.gamma)
        mp.msg.info(string.format("Native Mode | Gamma increased (+%.1f)", STEP_NATIVE.gamma))
    end
end)
