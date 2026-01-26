#!/usr/bin/env bash
set -euo pipefail

# ELF Interactive Control Script
# Manage Dashboard, IVI, and Watcher components

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ELF_DIR="${ELF_BASE_PATH:-$HOME/.opencode/emergent-learning}"
OPENCODE_DIR="${OPENCODE_DIR:-$HOME/.opencode}"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to check if a process is running
is_running() {
    pgrep -f "$1" > /dev/null 2>&1
}

# Function to start dashboard
start_dashboard() {
    echo -e "${BLUE}Starting ELF Dashboard...${NC}"

    if is_running "run-dashboard.sh"; then
        echo -e "${YELLOW}Dashboard is already running${NC}"
        return 0
    fi

    nohup bash -lc "$ELF_DIR/dashboard-app/run-dashboard.sh" > /tmp/elf-dashboard.log 2>&1 &

    # Wait a bit for it to start
    sleep 3

    if is_running "uvicorn.*port 8888"; then
        echo -e "${GREEN}✅ Dashboard started successfully${NC}"
        echo -e "${BLUE}Dashboard URL: http://localhost:3001${NC}"
        echo -e "${BLUE}API URL: http://localhost:8888${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to start dashboard${NC}"
        echo -e "${YELLOW}Check logs: tail -f /tmp/elf-dashboard.log${NC}"
        return 1
    fi
}

# Function to stop dashboard
stop_dashboard() {
    echo -e "${BLUE}Stopping ELF Dashboard...${NC}"

    if ! is_running "run-dashboard.sh" && ! is_running "uvicorn.*port 8888"; then
        echo -e "${YELLOW}Dashboard is not running${NC}"
        return 0
    fi

    # Stop backend
    pkill -f "uvicorn.*port 8888" || true
    pkill -f "run-dashboard.sh" || true

    # Wait a bit for it to stop
    sleep 2

    if ! is_running "uvicorn.*port 8888" && ! is_running "run-dashboard.sh"; then
        echo -e "${GREEN}✅ Dashboard stopped successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to stop dashboard completely${NC}"
        echo -e "${YELLOW}Try: pkill -9 -f uvicorn${NC}"
        return 1
    fi
}

# Function to start Talking Head IVI
start_ivi() {
    echo -e "${BLUE}Starting Talking Head IVI...${NC}"

    if is_running "TalkinHead.*main.py"; then
        echo -e "${YELLOW}Talking Head IVI is already running${NC}"
        return 0
    fi

    nohup bash -lc "$ELF_DIR/dashboard-app/TalkinHead/run-talkinhead.sh" > /tmp/elf-ivi.log 2>&1 &

    # Wait a bit for it to start
    sleep 3

    if is_running "TalkinHead.*main.py"; then
        echo -e "${GREEN}✅ Talking Head IVI started successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to start Talking Head IVI${NC}"
        echo -e "${YELLOW}Check logs: tail -f /tmp/elf-ivi.log${NC}"
        return 1
    fi
}

# Function to stop Talking Head IVI
stop_ivi() {
    echo -e "${BLUE}Stopping Talking Head IVI...${NC}"

    if ! is_running "TalkinHead.*main.py"; then
        echo -e "${YELLOW}Talking Head IVI is not running${NC}"
        return 0
    fi

    pkill -f "TalkinHead.*main.py" || true
    pkill -f "run-talkinhead.sh" || true

    # Wait a bit for it to stop
    sleep 2

    if ! is_running "TalkinHead.*main.py"; then
        echo -e "${GREEN}✅ Talking Head IVI stopped successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to stop Talking Head IVI completely${NC}"
        echo -e "${YELLOW}Try: pkill -9 -f 'TalkinHead.*main.py'${NC}"
        return 1
    fi
}

# Function to start watcher
start_watcher() {
    echo -e "${BLUE}Starting ELF Watcher...${NC}"

    # Set default values if not provided
    local base_url="${OPENCODE_WATCHER_BASE_URL:-http://localhost:12134/v1}"
    local model="${OPENCODE_WATCHER_MODEL:-nemotron-v3-coder}"
    local elf_path="${ELF_BASE_PATH:-$HOME/.opencode/emergent-learning}"

    if is_running "launcher.py"; then
        echo -e "${YELLOW}Watcher is already running${NC}"
        echo -e "${BLUE}PID: $(pgrep -f launcher.py)${NC}"
        return 0
    fi

    echo -e "${BLUE}Configuration:${NC}"
    echo -e "  Base URL: $base_url"
    echo -e "  Model: $model"
    echo -e "  ELF Path: $elf_path"

    OPENCODE_WATCHER_BASE_URL="$base_url" \
    OPENCODE_WATCHER_MODEL="$model" \
    ELF_BASE_PATH="$elf_path" \
    nohup "$elf_path/scripts/start-watcher.sh" --daemon > /tmp/elf-watcher.log 2>&1 &

    # Wait a bit for it to start
    sleep 3

    if is_running "launcher.py"; then
        echo -e "${GREEN}✅ Watcher started successfully${NC}"
        echo -e "${BLUE}Watcher PID: $(pgrep -f launcher.py)${NC}"
        echo -e "${BLUE}Logs: tail -f /tmp/elf-watcher.log${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to start watcher${NC}"
        echo -e "${YELLOW}Check logs: tail -f /tmp/elf-watcher.log${NC}"
        return 1
    fi
}

# Function to stop watcher
stop_watcher() {
    echo -e "${BLUE}Stopping ELF Watcher...${NC}"

    if ! is_running "launcher.py"; then
        echo -e "${YELLOW}Watcher is not running${NC}"
        return 0
    fi

    # Find and kill the watcher process
    local pid=$(pgrep -f "launcher.py")
    if [ -n "$pid" ]; then
        kill "$pid" || true
        echo -e "${BLUE}Sent termination signal to watcher (PID: $pid)${NC}"
    fi

    # Wait a bit for it to stop
    sleep 2

    if ! is_running "launcher.py"; then
        echo -e "${GREEN}✅ Watcher stopped successfully${NC}"
        return 0
    else
        echo -e "${RED}❌ Failed to stop watcher${NC}"
        echo -e "${YELLOW}Try: kill -9 $(pgrep -f launcher.py)${NC}"
        return 1
    fi
}

# Function to show status with interactive menu
show_status() {
    clear
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}          ELF System Status & Control Panel${NC}"
    echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}\n"

    local dashboard_running=0
    local ivi_running=0
    local watcher_running=0

    # Dashboard status
    if is_running "uvicorn.*port 8888"; then
        echo -e "1️⃣  ${GREEN}● Dashboard: RUNNING${NC}"
        echo -e "    └─ API: http://localhost:8888"
        dashboard_running=1
    else
        echo -e "1️⃣  ${RED}○ Dashboard: STOPPED${NC}"
    fi

    # IVI status
    if is_running "TalkinHead.*main.py"; then
        echo -e "2️⃣  ${GREEN}● Talking Head IVI: RUNNING${NC}"
        ivi_running=1
    else
        echo -e "2️⃣  ${RED}○ Talking Head IVI: STOPPED${NC}"
    fi

    # Watcher status
    if is_running "launcher.py"; then
        echo -e "3️⃣  ${GREEN}● Watcher: RUNNING${NC}"
        echo -e "    └─ Logs: tail -f /tmp/elf-watcher.log"
        watcher_running=1
    else
        echo -e "3️⃣  ${RED}○ Watcher: STOPPED${NC}"
    fi

    # Interactive menu
    echo -e "\n${BLUE}───────────────────────────────────────────────────────────${NC}"
    echo -e "${BLUE}Quick Actions:${NC}"
    [ $dashboard_running -eq 0 ] && echo -e "  ${GREEN}[1]${NC} Start Dashboard" || echo -e "  ${GREEN}[1]${NC} Stop Dashboard"
    [ $ivi_running -eq 0 ] && echo -e "  ${GREEN}[2]${NC} Start IVI" || echo -e "  ${GREEN}[2]${NC} Stop IVI"
    [ $watcher_running -eq 0 ] && echo -e "  ${GREEN}[3]${NC} Start Watcher" || echo -e "  ${GREEN}[3]${NC} Stop Watcher"
    echo -e "  ${GREEN}[4]${NC} Start All"
    echo -e "  ${GREEN}[5]${NC} Stop All"
    echo -e "  ${GREEN}[6]${NC} Restart All"
    echo -e "  ${GREEN}[0]${NC} Exit\n"
}

# Function to show help
show_help() {
    echo -e "${BLUE}ELF Control Script - Usage:${NC}"
    echo -e "  ${GREEN}$0 start-dashboard${NC}      - Start ELF Dashboard"
    echo -e "  ${GREEN}$0 stop-dashboard${NC}       - Stop ELF Dashboard"
    echo -e "  ${GREEN}$0 start-ivi${NC}            - Start Talking Head IVI"
    echo -e "  ${GREEN}$0 stop-ivi${NC}             - Stop Talking Head IVI"
    echo -e "  ${GREEN}$0 start-watcher${NC}         - Start ELF Watcher"
    echo -e "  ${GREEN}$0 stop-watcher${NC}          - Stop ELF Watcher"
    echo -e "  ${GREEN}$0 restart-all${NC}           - Restart all components"
    echo -e "  ${GREEN}$0 stop-all${NC}              - Stop all components"
    echo -e "  ${GREEN}$0 status${NC}                - Show system status"
    echo -e "  ${GREEN}$0 help${NC}                  - Show this help message"
    echo -e "\n${BLUE}Environment Variables:${NC}"
    echo -e "  OPENCODE_WATCHER_BASE_URL  - Watcher API base URL (default: http://localhost:12134/v1)"
    echo -e "  OPENCODE_WATCHER_MODEL      - Watcher model name (default: nemotron-v3-coder)"
    echo -e "  ELF_BASE_PATH              - ELF installation path (default: ~/.opencode/emergent-learning)"
}

# Interactive menu loop
interactive_menu() {
    while true; do
        show_status
        read -p "Enter choice: " choice
        
        case "$choice" in
            1)
                if is_running "uvicorn.*port 8888"; then
                    stop_dashboard
                else
                    start_dashboard
                fi
                ;;
            2)
                if is_running "TalkinHead.*main.py"; then
                    stop_ivi
                else
                    start_ivi
                fi
                ;;
            3)
                if is_running "launcher.py"; then
                    stop_watcher
                else
                    start_watcher
                fi
                ;;
            4)
                echo -e "${BLUE}Starting all components...${NC}\n"
                start_dashboard && start_ivi && start_watcher
                ;;
            5)
                echo -e "${BLUE}Stopping all components...${NC}\n"
                stop_watcher && stop_ivi && stop_dashboard
                ;;
            6)
                echo -e "${BLUE}Restarting all components...${NC}\n"
                stop_watcher && stop_ivi && stop_dashboard
                sleep 2
                start_dashboard && start_ivi && start_watcher
                ;;
            0)
                echo -e "${GREEN}Goodbye!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Press Enter to continue...${NC}"
                read -p ""
                ;;
        esac
        
        echo -e "\n${BLUE}Press Enter to continue...${NC}"
        read -p ""
    done
}

# Main command handling
case "${1:-status}" in
    start-dashboard)
        start_dashboard
        ;;
    stop-dashboard)
        stop_dashboard
        ;;
    start-ivi)
        start_ivi
        ;;
    stop-ivi)
        stop_ivi
        ;;
    start-watcher)
        start_watcher
        ;;
    stop-watcher)
        stop_watcher
        ;;
    restart-all)
        stop_watcher
        stop_ivi
        stop_dashboard
        sleep 2
        start_dashboard
        start_ivi
        start_watcher
        ;;
    stop-all)
        stop_watcher
        stop_ivi
        stop_dashboard
        ;;
    status)
        interactive_menu
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        show_help
        exit 1
        ;;
esac