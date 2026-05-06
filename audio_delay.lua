--Audio_delay
--Sets a custom audio delay
function setAudioDelay()
    local delay = 0.24 -- Adjust this value as needed
    mp.set_property("audio-delay", delay)
    mp.msg.info("Audio delay set to " .. delay .. " seconds")
end

mp.register_event("file-loaded", setAudioDelay)
