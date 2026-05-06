--Auto_shaders
--Detect resolution and language to apply revelent shaders

--Shaders for films
local film_hd = {"~~/shaders/FSRCNNX_x2_8-0-4-1.glsl","~~/shaders/KrigBilateral.glsl","~~/shaders/SSimSuperRes.glsl","~~/shaders/SSimDownscaler.glsl"}
local film_sd = {"~~/shaders/FSRCNNX_x1_16-0-4-1_distort.glsl","~~/shaders/KrigBilateral.glsl","~~/shaders/ravu-zoom-ar-r3.glsl","~~/shaders/SSimDownscaler.glsl"}

--Shaders for Animes
local anime_hd = {"~~/shaders/Ani4Kv2_ArtCNN_C4F32_i2.glsl"}
local anime_sd = {"~~/shaders/AniSD_ArtCNN_C4F32_i4.glsl"}

local function set_shaders(list, label)
    mp.set_property_native("glsl-shaders", {}) 
    if #list > 0 then
        mp.set_property_native("glsl-shaders", list)
        mp.osd_message("Shaders applied ("..label..")", 3)
        mp.msg.info("Shaders applied ("..label..")")
    else
        mp.osd_message("No shader applied ("..label..")", 3)
        mp.msg.info("No shader applied ("..label..")")
    end
end

--Dumb, japanese films will count as animes
local function is_anime_by_audio()
    local tracks = mp.get_property_native("track-list")
    if not tracks then return false end
    for _, track in ipairs(tracks) do
        if track.type == "audio" and track.lang then
            local lang = track.lang:lower()
            if string.find(lang, "jpn") or string.find(lang, "ja") then
                return true
            end
        end
    end
    return false
end

mp.register_event("file-loaded", function()
    local width = mp.get_property_number("width", 0)
    local anime = is_anime_by_audio()

    if anime then
        if width >= 1920 then
            set_shaders(anime_hd, "Anime 1080p+")
        else
            set_shaders(anime_sd, "Anime <1080p")
        end
    else
        if width >= 1920 then
            set_shaders(film_hd, "Film 1080p+")
        else
            set_shaders(film_sd, "Film <1080p")
        end
    end
end)
