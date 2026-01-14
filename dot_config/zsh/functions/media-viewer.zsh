# ===============================
# Media Viewer Function
# ===============================

media-viewer() {
    cd "/Volumes/ExtremeSSD/00_Memories/Selected_Media/media-viewer"
    node server.js &
    local server_pid=$!

    # Trap Ctrl+C to properly kill server
    trap "kill $server_pid 2>/dev/null; return" INT TERM

    sleep 2
    open http://localhost:9000
    wait $server_pid
}
