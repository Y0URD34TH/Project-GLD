--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md

local VERSION = "1.0"
local TORRENTIO_BASE = "https://torrentio.strem.fun"

client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5Btorrentio%5D%20Movies.lua", VERSION)

-- ============================================================================
-- HELPERS
-- ============================================================================

local function torrentio_parse_title(title)
    if type(title) ~= "string" or title == "" then
        return nil, nil, nil
    end
    local season, episode = title:match("[Ss](%d+)[Ee](%d+)")
    if not season then
        return title, nil, nil
    end
    local name = title:gsub("%s*%-?%s*[Ss]%d+[Ee]%d+.*$", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return name, tonumber(season), tonumber(episode)
end

local function torrentio_build_url(imdb_id, season, episode)
    if not imdb_id or imdb_id == "" then
        return nil
    end

    return TORRENTIO_BASE .. "/stream/movie/" .. imdb_id .. ".json"
end

local function torrentio_fetch(imdb_id, season, episode)
    local url = torrentio_build_url(imdb_id, season, episode)
    if not url then return nil end

    local response = http.get(url, {
        ["User-Agent"] = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) " ..
            "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 ProjectGLD/2.15"
    })
    if type(response) ~= "string" or response == "" then
        return nil
    end

    local parsed = JsonWrapper.parse(response)
    if not parsed or not parsed["streams"] then
        return nil
    end
    return parsed["streams"]
end

local function torrentio_deemoji_stats(line)
    if type(line) ~= "string" or line == "" then return "" end

    -- Replace the three markers with labeled fields
    line = line:gsub("👤%s*",  "Seeders: ")
    line = line:gsub("💾%s*",  "Size: ")
    line = line:gsub("⚙️%s*",  "Source: ")

    -- Strip any remaining emoji characters (flag emoji like 🇬🇧, misc symbols)
    -- Flag emoji are two regional indicator code points; misc symbols vary.
    -- We do a best-effort strip of the ranges that commonly appear.
    line = line:gsub("[\240-\244][\128-\191][\128-\191][\128-\191]", "") -- 4-byte UTF-8 (most emoji)
    line = line:gsub("[\226][\128-\191][\128-\191]", "")                 -- 3-byte UTF-8 (✔ ⚙ etc. if any survived)
    line = line:gsub("[\239][\184][\128-\143]", "")                      -- variation selectors

    -- Cleanup: collapse multiple spaces, trim
    line = line:gsub("%s+", " ")
    line = line:gsub("^%s+", ""):gsub("%s+$", "")

    -- If the line ended with a dangling separator like " /", trim it
    line = line:gsub("%s*[/|%-]+%s*$", "")

    return line
end

-- Split the title into clean text (visible name) vs. stats line (tooltip).
-- Returns: clean_text, stats_text (both emoji-free)
local function torrentio_split_title(title)
    if type(title) ~= "string" then
        return "", ""
    end

    local clean_parts = {}
    local stats_parts = {}

    for line in title:gmatch("[^\n]+") do
        line = line:gsub("^%s+", ""):gsub("%s+$", "")
        if line ~= "" then
            if line:find("👤", 1, true) or
               line:find("💾", 1, true) or
               line:find("⚙️", 1, true) then
                -- Stats line: convert emoji to labels, strip the rest
                local cleaned = torrentio_deemoji_stats(line)
                if cleaned ~= "" then
                    table.insert(stats_parts, cleaned)
                end
            else
                -- Plain line (release name, language info, etc.)
                -- Still strip any stray emoji so flags don't bleed into the name
                local cleaned = line:gsub("[\240-\244][\128-\191][\128-\191][\128-\191]", "")
                cleaned = cleaned:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
                if cleaned ~= "" then
                    table.insert(clean_parts, cleaned)
                end
            end
        end
    end

    return table.concat(clean_parts, " "), table.concat(stats_parts, " | ")
end

-- Extract just the stats portion from a raw title, emoji-free.
local function torrentio_extract_stats(text)
    if type(text) ~= "string" then return "" end

    -- Grab everything from the first emoji marker to end-of-line
    local chunk = text:match("👤.-(\n|$)") or text:match("💾.-(\n|$)") or text:match("⚙️.-(\n|$)")
    if chunk then
        chunk = chunk:gsub("\n", "")
        chunk = torrentio_deemoji_stats(chunk)
    end

    -- Also pick up the line right after the stats line (language / audio info)
    local after = text:match("⚙️[^\n]*\n([^\n]+)")
    if after and after ~= "" then
        after = after:gsub("[\240-\244][\128-\191][\128-\191][\128-\191]", "")
        after = after:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    end

    -- Combine
    local parts = {}
    if chunk and chunk ~= "" then table.insert(parts, chunk) end
    if after and after ~= "" then table.insert(parts, after) end
    return table.concat(parts, " | ")
end

-- Strip the stats portion from a single-line string (no newlines).
local function torrentio_strip_stats_line(text)
    if type(text) ~= "string" then return "" end
    text = text:gsub("%s*👤.*$", "")
    text = text:gsub("%s*💾.*$", "")
    text = text:gsub("%s*⚙️.*$", "")
    -- Also strip trailing emoji if any
    text = text:gsub("[\240-\244][\128-\191][\128-\191][\128-\191]", "")
    return text:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
end
-- ============================================================================
-- FILTERS
-- ============================================================================

local function torrentio_norm_quality(s)
    if type(s) ~= "string" then return "" end
    return s:lower():gsub("[%s%-_%.]", "")
end

local function torrentio_quality_matches(stream_text, want_quality)
    if not want_quality or want_quality == "" then return true end
    local q = torrentio_norm_quality(want_quality)
    local aliases = {
        ["2160p"] = { "2160p", "4k", "uhd" },
        ["4k"]    = { "2160p", "4k", "uhd" },
        ["1080p"] = { "1080p", "1080" },
        ["1080"]  = { "1080p", "1080" },
        ["720p"]  = { "720p", "720" },
        ["720"]   = { "720p", "720" },
        ["480p"]  = { "480p", "480" },
        ["360p"]  = { "360p", "360" },
    }
    local needles = aliases[q]
    if not needles then
        return stream_text:find(q, 1, true) ~= nil
    end
    for _, needle in ipairs(needles) do
        if stream_text:find(needle, 1, true) then
            return true
        end
    end
    return false
end

local function torrentio_codec_matches(stream_text, want_codec)
    if not want_codec or want_codec == "" then return true end
    local c = torrentio_norm_quality(want_codec)
    local groups = {
        { "x264", "h264", "avc" },
        { "x265", "h265", "hevc" },
        { "av1" },
        { "xvid" },
        { "divx" },
        { "mpeg2", "mpeg-2" },
        { "vp9" },
    }
    local target_group = nil
    for _, group in ipairs(groups) do
        for _, name in ipairs(group) do
            if c == name then
                target_group = group
                break
            end
        end
        if target_group then break end
    end
    if target_group then
        for _, name in ipairs(target_group) do
            if stream_text:find(name, 1, true) then
                return true
            end
        end
        return false
    end
    return stream_text:find(c, 1, true) ~= nil
end

local function torrentio_year_matches(stream_text, want_year)
    if not want_year or want_year == "" then return true end
    if type(want_year) == "number" then
        want_year = tostring(want_year)
    end
    local y = tostring(want_year):match("(%d%d%d%d)")
    if not y then return true end
    for token in stream_text:gmatch("%f[%d]%d%d%d%d%f[%D]") do
        if token == y then return true end
    end
    return false
end

local function torrentio_passes_filters(stream_text, want_quality, want_codec, want_year)
    if not torrentio_quality_matches(stream_text, want_quality) then return false end
    if not torrentio_codec_matches(stream_text, want_codec) then return false end
    if not torrentio_year_matches(stream_text, want_year) then return false end
    return true
end

-- ============================================================================
-- MAGNET BUILDER
-- ============================================================================

local function torrentio_build_magnet(infoHash, filename, sources)
    if not infoHash or infoHash == "" then return nil end
    local magnet = "magnet:?xt=urn:btih:" .. infoHash
    if filename and filename ~= "" then
        local encoded = filename:gsub("([^%w%-%._~])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        magnet = magnet .. "&dn=" .. encoded
    end
    if sources then
        for _, src in ipairs(sources) do
            if type(src) == "string" and src:sub(1, 8) == "tracker:" then
                local tracker = src:sub(9)
                local enc = tracker:gsub("([^%w%-%._~:/%?=])", function(c)
                    return string.format("%%%02X", string.byte(c))
                end)
                magnet = magnet .. "&tr=" .. enc
            end
        end
    end
    return magnet
end

-- ============================================================================
-- PUSH RESULTS
-- ============================================================================

local function torrentio_push_results(streams, want_quality, want_codec, want_year)
    local results = {}

    for _, stream in ipairs(streams) do
        local raw_name  = stream["name"]  or "Torrentio"
        local raw_title = stream["title"] or ""
        local infoHash  = stream["infoHash"]
        local filename  = ""
        if stream["behaviorHints"] and stream["behaviorHints"]["filename"] then
            filename = stream["behaviorHints"]["filename"]
        end

        -- Build a lowercase blob for filtering
        local blob = (raw_name .. " " .. raw_title .. " " .. filename):lower()

        if torrentio_passes_filters(blob, want_quality, want_codec, want_year) then
            local magnet = torrentio_build_magnet(infoHash, filename, stream["sources"])
            if magnet then
                -- Split the raw title into clean text + stats
                local clean_title, stats_from_split = torrentio_split_title(raw_title)
                local stats_extra = torrentio_extract_stats(raw_title)

                -- Fallback: if split didn't find a stats section, try stripping
                -- from the raw title and extracting
                if stats_from_split == "" then
                    clean_title = torrentio_strip_stats_line(raw_title)
                    stats_extra = torrentio_extract_stats(raw_title)
                end

                -- Name: name line + " | " + clean release title
                -- If the name itself still contains a stats line (single line),
                -- strip it too.
                local clean_name = torrentio_strip_stats_line(raw_name)
                if clean_name == "" then
                    clean_name = raw_name
                end

                local displayName = clean_name .. " | " .. clean_title

                -- Tooltip: stats (seeders/size/source) + any extra language line
                local tooltip = stats_from_split
                if stats_extra ~= "" and stats_extra ~= stats_from_split then
                    if tooltip ~= "" then
                        tooltip = tooltip .. " | " .. stats_extra
                    else
                        tooltip = stats_extra
                    end
                end
                if tooltip == "" then
                    tooltip = "Torrentio stream"
                end

                table.insert(results, {
                    name = displayName,
                    links = {
                        {
                            name = "Watch",
                            link = magnet,
                            addtodownloadlist = false,
                            isMovie = true
                        },
                        {
                            name = "Download",
                            link = magnet,
                            addtodownloadlist = true,
                            isMovie = true
                        }
                    },
                    tooltip = tooltip,
                    ScriptName = "Torrentio"
                })
            end
        end
    end

    if #results > 0 then
        communication.receiveSearchResults(results)
    end
end

-- ============================================================================
-- ENTRY POINT
-- ============================================================================

local function torrentio_run()
    local imdb_id = movie.getimdbid()
    if not imdb_id or imdb_id == "" then
        return
    end

    local want_quality = movie.getmoviequality() or ""
    local want_codec   = movie.getmoviecodec()   or ""
    local want_year    = movie.getmovieyear()    or ""

    local raw = movie.getmoviename()
    if not raw or raw == "" then
        local streams = torrentio_fetch(imdb_id, nil, nil)
        if streams then
            torrentio_push_results(streams, want_quality, want_codec, want_year)
        end
        return
    end

    local _, season, episode = torrentio_parse_title(raw)

    local streams = torrentio_fetch(imdb_id, season, episode)
    if streams then
        torrentio_push_results(streams, want_quality, want_codec, want_year)
    end
end

client.add_callback("on_scriptselected", torrentio_run)

