--to view examples and lua params go in this github page: https://github.com/Y0URD34TH/Project-GLD/blob/main/LuaParams.md

local VERSION = "1.0"
client.auto_script_update("https://raw.githubusercontent.com/Y0URD34TH/Project-GLD/refs/heads/main/Scripts/%5Bone%5D%20Movies.lua", VERSION)

local MOVIE_API_BASE = "https://st.111477.xyz/config/aHR0cHM6Ly9hLjExMTQ3Ny54eXovOjp0bWRiPWViMDIzOTEzYzEwNmE4YzRlZDY2YzgzYzI4ODY1Zjlh"

local function movie_build_url(tmdbid)
    return MOVIE_API_BASE .. "/stream/movie/tmdb:" .. tostring(tmdbid) .. ".json"
end

local function movie_parse_title(title)
    local season, episode = title:match("[Ss](%d+)[Ee](%d+)")
    if not season then
        return title, nil, nil
    end
    local name = title:gsub("%s*%-?%s*[Ss]%d+[Ee]%d+.*$", "")
    name = name:gsub("^%s+", ""):gsub("%s+$", "")
    return name, tonumber(season), tonumber(episode)
end

local function movie_fetch_streams(tmdbid)
    local url = movie_build_url(tmdbid)
    local response = http.get(url, {})
    if response == nil or response == "" then
        return nil, "HTTP request failed or returned an empty body"
    end

    local parsed = JsonWrapper.parse(response)
    if not parsed then
        return nil, "Failed to parse JSON response"
    end

    local streams = parsed["streams"]
    if not streams then
        return nil, "No 'streams' field in the response"
    end

    return streams
end

local function movie_push_results(streams)
    local results = {}

    for _, stream in ipairs(streams) do
        table.insert(results, {
            name = stream.title,
            links = {
                {
                    name = "Watch",
                    link = stream.url,
                    addtodownloadlist = false,
                    isMovie = true
                },
                {
                    name = "Download",
                    link = stream.url,
                    addtodownloadlist = true,
                    isMovie = true
                }
            },
            tooltip = "This is an DDL download. [not an torrent]",
            ScriptName = "StreamMovies"
        })
    end

    communication.receiveSearchResults(results)
end

local function movie_search_streams(tmdbid)
    local streams, err = movie_fetch_streams(tmdbid)

    if not streams then
        Notifications.push_error("StreamMovies", err or "Unknown error fetching streams")
        return
    end

    movie_push_results(streams)
end

local function movie_run()
    local tmdbid = movie.gettmdbid()

    if not tmdbid or tmdbid == "" then
        return
    end

    movie_search_streams(tmdbid)
end

client.add_callback("on_scriptselected", movie_run)







