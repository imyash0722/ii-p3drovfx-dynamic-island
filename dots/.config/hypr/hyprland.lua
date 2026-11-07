-- This file sources other files in `hyprland` and `custom` folders
-- You wanna add your stuff in files in `custom`

-- Internal stuff --
require("hyprland.lib")
require("hyprland.services")

local function safe_require(module_name)
    local ok, err = pcall(require, module_name)
    if not ok then
        hl.exec_cmd("notify-send 'Hyprland Lua Error' 'Failed to load " .. module_name .. ": " .. tostring(err):gsub("'", "\\'") .. "' -u critical -a 'Hyprland'")
    end
    return ok
end

-- Environment variables --
safe_require("hyprland.env")
if is_file_exists(HOME .. "/.config/hypr/custom/env.lua") then
    safe_require("custom.env")
end

-- Default configurations --
safe_require("hyprland.execs")
safe_require("hyprland.general")
safe_require("hyprland.rules")
safe_require("hyprland.colors")
safe_require("hyprland.keybinds")
-- zscroll (lua:zscroll): before custom/ so general:layout can name it and custom binds win
safe_require("hyprland.layouts.zscroll")

-- Custom configurations --
if is_file_exists(HOME .. "/.config/hypr/custom/input.lua") then
    safe_require("custom.input")
end
if is_file_exists(HOME .. "/.config/hypr/custom/execs.lua") then
    safe_require("custom.execs")
end
if is_file_exists(HOME .. "/.config/hypr/custom/general.lua") then
    safe_require("custom.general")
end
if is_file_exists(HOME .. "/.config/hypr/custom/rules.lua") then
    safe_require("custom.rules")
end
if is_file_exists(HOME .. "/.config/hypr/custom/keybinds.lua") then
    safe_require("custom.keybinds")
end

-- Ensure internal display (eDP-1) is always enabled on startup with 1.25 scaling
do
    local runtime_dir = os.getenv("XDG_RUNTIME_DIR") or "/tmp"
    local boot_flag = runtime_dir .. "/hypr_session_active"
    local is_boot = not is_file_exists(boot_flag)

    if is_boot then
        local fb = io.open(boot_flag, "w")
        if fb then
            fb:write("active\n")
            fb:close()
        end

        local hyprmon_file = HOME .. "/.config/hypr/hyprmon.lua"
        if is_file_exists(hyprmon_file) then
            local f = io.open(hyprmon_file, "r")
            if f then
                local content = f:read("*all")
                f:close()
                local pattern = 'hl%.monitor%(%{%s*output%s*=%s*["\']eDP%-1["\'].-disabled%s*=%s*true.-%}%);?'
                if content:find('output%s*=%s*["\']eDP%-1["\'].-disabled%s*=%s*true') then
                    content = content:gsub(pattern, 'hl.monitor({ output = "eDP-1", mode = "1920x1200@60.00Hz", position = "-1x-1", scale = 1.25 })')
                    local fw = io.open(hyprmon_file, "w")
                    if fw then
                        fw:write(content)
                        fw:close()
                    end
                elseif not content:find('["\']eDP%-1["\']') then
                    content = 'hl.monitor({ output = "eDP-1", mode = "1920x1200@60.00Hz", position = "-1x-1", scale = 1.25 })\n' .. content
                    local fw = io.open(hyprmon_file, "w")
                    if fw then
                        fw:write(content)
                        fw:close()
                    end
                end
            end
        end

        local conf_file = HOME .. "/.config/hypr/monitors.conf"
        if is_file_exists(conf_file) then
            local fc = io.open(conf_file, "r")
            if fc then
                local conf_content = fc:read("*all")
                fc:close()
                if conf_content:find("monitor=eDP%-1,disable") then
                    conf_content = conf_content:gsub("monitor=eDP%-1,disable", "monitor=eDP-1,1920x1200@60.00Hz,-1x-1,1.25")
                    local fcw = io.open(conf_file, "w")
                    if fcw then
                        fcw:write(conf_content)
                        fcw:close()
                    end
                elseif not conf_content:find("eDP%-1") then
                    conf_content = "monitor=eDP-1,1920x1200@60.00Hz,-1x-1,1.25\n" .. conf_content
                    local fcw = io.open(conf_file, "w")
                    if fcw then
                        fcw:write(conf_content)
                        fcw:close()
                    end
                end
            end
        end
    end
end

if is_file_exists(HOME .. "/.config/hypr/hyprmon.lua") then
    require("hyprmon")
else
    hl.monitor({ output = "eDP-1", mode = "1920x1200@60.00Hz", position = "-1x-1", scale = 1.25 })
end

-- Shell overrides --
safe_require("hyprland.shellOverrides.main")

