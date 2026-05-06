# Plex_toolscripts
Useful set of scripts for Plex ecosystem

---
## Audio_delay 

Very simple script to set an audio delay

---
## SubASS_Restyler

Smol script to restyle ass subs without degrading space positionning

I recommend (re)installing your preferred font renamed as "SubASS" (or any custom name) in windows

Requires ffmep installed and in PATH
```
winget install ffmpeg
```
To add in PATH (change XXX with your User name)
```
set Path "%Path%;C:\Users\XXX\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-6.0-full_build\bin"
```
```
setx Path "%Path%;C:\Users\XXX\AppData\Local\Microsoft\WinGet\Packages\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\ffmpeg-6.0-full_build\bin"
```
---
## SonarrNoGap
Script used to prevent spoiling from Plex when episodes are missing.

Plex will not hide episodes if gaps are detected (eg: S02E01 S02E02 S2E04 S2E05 are available, until S2E03 is available S2E04 and S2E05 will stay hidden in Plex )

Load the lua file with Sonarr connections - custom scripts - On Episode file Added, Renamed and Deleted.
I recommend also using the Plex connection to trigger plex local scans.

---

## Auto_Shaders
Script used to load proper set of shaders depending on the video (Animes, HD or SD)

Copy them in /shaders folder
| Shader | Note |
|---|---|
| [Ani4Kv2 / AniSD](https://github.com/Sirosky/Upscale-Hub) | For Animation - Ani4Kv2_ArtCNN_C4F32_i2 and AniSD_ArtCNN_C4F32_i4 |
| [KrigBilateral](https://gist.github.com/igv) | For Films |
| [SSimDownscaler](https://gist.github.com/igv) | For Films |
| [SSimSuperRes](https://gist.github.com/igv) | For HD Films |
| [RAVU](https://github.com/bjin/mpv-prescalers) | For SD Films - ravu-zoom-ar-r3 |
| [FSRCNNX](https://github.com/igv/FSRCNN-TensorFlow/releases) | FSRCNNX_x2_8-0-4-1 and FSRCNNX_x1_16-0-4-1_distort |
