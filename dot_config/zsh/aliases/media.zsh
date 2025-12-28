# ===============================
# Media Viewer Aliases
# ===============================

# Start media viewer server and open browser
media-viewer() {
    cd "/Volumes/Extreme SSD/00_Memories/Selected_Media/media-viewer"
    node server.js &
    local server_pid=$!
    sleep 2
    open http://localhost:9000
    wait $server_pid
}
