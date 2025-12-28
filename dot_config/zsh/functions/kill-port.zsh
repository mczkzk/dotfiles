# ===============================
# Kill Process by Port Function
# ===============================

kill-port() {
    if [ -z "$1" ]; then
        echo "Usage: kill-port <port>"
        return 1
    fi
    lsof -ti :$1 | xargs kill -9
    if [ $? -eq 0 ]; then
        echo "✓ Killed process on port $1"
    else
        echo "✗ No process found on port $1"
    fi
}
