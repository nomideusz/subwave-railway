# Deploy and Host SUB/WAVE on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/subwave?utm_medium=integration&utm_source=button&utm_campaign=subwave)

[SUB/WAVE](https://github.com/perminder-klair/subwave) is a personal internet radio station with an AI DJ. There is one Icecast stream and every listener hears the same thing at the same time. The DJ picks tracks from your own music library, talks between them (station idents, time checks, weather, intros), and takes song requests in plain language. It is radio, not a playlist: no skip button, no per-listener shuffle.

## About Hosting SUB/WAVE

Two services, each with its own volume, talking over Railway's private network:

- **SUBWAVE** runs the official all-in-one image: Icecast, Liquidsoap, the DJ controller, the Next.js player and admin, and Caddy in front, on one domain. Settings, the library database, jingles and archives live on the volume at `/var/sub-wave`.
- **Navidrome** is the music library the DJ plays from, with a drag-and-drop upload panel (Filebrowser) on a second domain. Upload music there and Navidrome imports it within seconds.

The station is already wired to Navidrome when it boots: the Navidrome admin user and its password are generated at deploy and handed to SUBWAVE, so there are no credentials to copy. The admin password for the station is generated too.

## Common Use Cases

- A private or public internet radio station for your own music collection, with a DJ that talks
- A background station for a shop, studio, stream or Discord community, with scheduled shows and personas
- A listening room for friends, where people request songs by describing them

## Dependencies for SUB/WAVE Hosting

- An LLM for the DJ's picks and chatter: a key for Anthropic, OpenAI, Google, DeepSeek, OpenRouter or any OpenAI-compatible server, or a reachable Ollama. Without one the music still plays and the station picks tracks on its own, but the DJ stays silent.
- Your music, uploaded through the Navidrome upload panel.

### Deployment Dependencies

- [SUB/WAVE on GitHub](https://github.com/perminder-klair/subwave) and the [operator manual](https://www.getsubwave.com/manual)
- [Navidrome documentation](https://www.navidrome.org/docs/)
- [Template source on GitHub](https://github.com/nomideusz/subwave-railway)

### Implementation Details

**After deploying:**

1. **Upload music.** Open the Navidrome service's upload-panel domain (the one on port 8080). Log in as `admin` with `FILEBROWSER_PASSWORD` from the Navidrome service's Variables tab, and drop in folders of tagged MP3/FLAC files.
2. **Finish setup.** Open the SUBWAVE domain at `/onboarding` and sign in as `admin` with `ADMIN_PASS` from the SUBWAVE service's Variables tab. The wizard asks for your LLM provider and key, the DJ persona and voice, and your location for weather. The Navidrome connection is already filled in.
3. **Listen.** The player is at `/`, the stream at `/stream.mp3` (paste it into VLC, a hardware radio or Sonos), and the operator console at `/admin`.

**Voices.** Piper is the default voice and costs almost nothing. Kokoro is built in too and sounds better, but its model takes about 700 MB of RAM once it is used. Cloud voices (OpenAI, ElevenLabs) need only a key.

**Memory.** The station idles at about 350 MB and Navidrome at about 40 MB, so the Trial plan runs it with Piper. Switch to Kokoro only on a plan with at least 2 GB.

**Changes from the upstream image, all in the [wrapper](https://github.com/nomideusz/subwave-railway):**

- Railway's `PORT` goes to Caddy only. The controller reads `PORT` for its own internal port and would otherwise fight Caddy for it.
- Caddy trusts `X-Forwarded-For` from Railway's edge, so request cooldowns and the admin lockout see each listener's real IP instead of treating everyone as one visitor.
- Navidrome listens on IPv4 and IPv6 (`ND_ADDRESS=[::]`) so the station can reach it on the private network.

**Keep in mind:**

- Hourly archives are off by default. If you turn them on, they grow by about 1.4 GB a day at 128 kbps, so watch the volume size.
- **Admin → Settings → Backup → Export** saves settings, schedule and the library database (API keys are left out). Take one before updating.
- To update SUB/WAVE, bump the image tag in the wrapper's `Dockerfile` and redeploy.
- Streaming music to the public may need a performance licence where you live. A station password (Admin → Settings) keeps it private.

## Why Deploy SUB/WAVE on Railway?

Railway is a singular platform to deploy your infrastructure stack. Railway will host your infrastructure so you don't have to deal with configuration, while allowing you to vertically and horizontally scale it.

By deploying SUB/WAVE on Railway, you are one step closer to supporting a complete full-stack application with minimal burden. Host your servers, databases, AI agents, and more on Railway.
