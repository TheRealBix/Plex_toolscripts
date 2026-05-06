--SubASS restyler
--Overrides ass style while preventing misplaced subtitles on video.
--Required : ffmpeg in windows PATH

local mp = require 'mp'
local msg = mp.msg

local TARGET_PLAYRESY = 360

--Set your style preferences here. An HDR preset is available to set darker subtitles if needed.
--I recommend naming and installing your preffered font as "SubASS" instead of using its default name.

local STYLE_SDR = {
    FontName = "SubASS",
    FontSize = 18,
    PrimaryColour = "&H00CCCCCC",
    SecondaryColour = "&H000000FF",
    OutlineColour = "&H00000000",
    BackColour = "&H00000000",
    Bold = 0,
    Outline = 0.6,
    Shadow = 0.5,
}
local STYLE_HDR = {
    FontName = "SubASS",
    FontSize = 18,
    PrimaryColour = "&H00B4B4B4",
    SecondaryColour = "&H000000FF",
    OutlineColour = "&H00000000",
    BackColour = "&H00000000",
    Bold = 0,
    Outline = 0.6,
    Shadow = 0.5,
}

local FALLBACK_NAMES = {
    "Default", "Main", "Dialogue", "Dialogue**", "Alt", "Italics", "Top",
    "Flashback", "Secondary", "Italique", "TiretsDefault", "TiretsItalique"
}

local current_playresy = nil
local current_overrides_hash = ""

local function is_hdr()
    local primaries = mp.get_property("video-params/primaries") or ""
    local gamma = mp.get_property("video-params/gamma") or ""
    return primaries == "bt.2020" and (gamma == "pq" or gamma == "hlg")
end

local function active_style()
    return is_hdr() and STYLE_HDR or STYLE_SDR
end

local function compute_scale()
    if current_playresy and current_playresy > 0 then
        return current_playresy / TARGET_PLAYRESY
    end
    local video_h = mp.get_property_number("height", 1080)
    if not video_h or video_h <= 0 then return 1 end
    return video_h / TARGET_PLAYRESY
end

local function apply(names)
    local style = active_style()
    local scale = compute_scale()
    local list = {}

    for _, name in ipairs(names) do
        local ov = {
            name .. ".FontName=" .. style.FontName,
            name .. ".FontSize=" .. string.format("%.2f", style.FontSize * scale),
            name .. ".PrimaryColour=" .. style.PrimaryColour,
            name .. ".SecondaryColour=" .. style.SecondaryColour,
            name .. ".OutlineColour=" .. style.OutlineColour,
            name .. ".BackColour=" .. style.BackColour,
            name .. ".Bold=" .. style.Bold,
            name .. ".Outline=" .. string.format("%.2f", style.Outline * scale),
            name .. ".Shadow=" .. string.format("%.2f", style.Shadow * scale),
            name .. ".MarginL=" .. math.floor(25 * scale),
            name .. ".MarginR=" .. math.floor(25 * scale),
        }
        for _, v in ipairs(ov) do
            table.insert(list, v)
        end
    end

    local new_hash = table.concat(list, "|")
    if new_hash == current_overrides_hash then return end

    current_overrides_hash = new_hash
    mp.set_property_native("sub-ass-style-overrides", list)
    mp.set_property("sub-ass-override", current_playresy and "yes" or "force")

    msg.info(string.format(
        "[sub_style] mode=%s | PlayResY=%s | scale=%.2f | FontSize=%.1f | Outline=%.2f | Shadow=%.2f",
        current_playresy and "yes" or "force",
        current_playresy or "fallback",
        scale,
        style.FontSize * scale,
        style.Outline * scale,
        style.Shadow * scale
    ))
end

local function update()
    local sid = mp.get_property_native("sid")
    if not sid or sid == "no" then
        mp.set_property_native("sub-ass-style-overrides", {})
        current_overrides_hash = ""
        return
    end
    apply(FALLBACK_NAMES)
end

local function get_ffprobe_sub_index()
    local sid = mp.get_property_native("sid")
    if not sid or sid == "no" then return nil end
    local tracks = mp.get_property_native("track-list") or {}
    local sub_count = 0
    for _, t in ipairs(tracks) do
        if t.type == "sub" and not t.external then
            if t.id == sid then
                return sub_count
            end
            sub_count = sub_count + 1
        end
    end
    return nil
end

local function extract_playresy_async()
    local path = mp.get_property("path")
    if not path then return end

    local sub_index = get_ffprobe_sub_index()
    if sub_index == nil then
        msg.warn("[sub_style] Piste sub introuvable")
        current_playresy = nil
        update()
        return
    end

    local args = {
        "ffmpeg", "-hide_banner", "-loglevel", "error",
        "-i", path,
        "-map", "0:s:" .. sub_index,
        "-frames:s", "0",
        "-f", "ass", "pipe:1"
    }

    mp.command_native_async({
        name = "subprocess",
        args = args,
        capture_stdout = true,
        capture_stderr = false,
        playback_only = false,
    }, function(success, result, err)
        if not success or not result or not result.stdout then
            msg.warn("[sub_style] ffmpeg a échoué : " .. tostring(err))
            current_playresy = nil
            update()
            return
        end

        local playresy = result.stdout:match("[Pp]lay[Rr]es[Yy]%s*:%s*(%d+)")

        if playresy then
            current_playresy = tonumber(playresy)
            msg.info("[sub_style] PlayResY : " .. current_playresy)
        else
            msg.warn("[sub_style] PlayResY introuvable")
            current_playresy = nil
        end

        current_overrides_hash = ""
        update()
    end)
end

mp.observe_property("video-params/primaries", "string", update)
mp.observe_property("height", "native", update)

mp.observe_property("sid", "native", function()
    current_playresy = nil
    current_overrides_hash = ""
    extract_playresy_async()
end)

mp.register_event("file-loaded", function()
    current_playresy = nil
    current_overrides_hash = ""
    extract_playresy_async()
end)
