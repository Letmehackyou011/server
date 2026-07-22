#!/bin/bash

# Development Environment Manager
# Easily start/stop React and Streamlit servers
# Usage: bash manage_dev.sh [command]

PROJECT_DIR="$HOME/dev_projects"
REACT_PROJECT="$PROJECT_DIR/react-app"
STREAMLIT_PROJECT="$PROJECT_DIR/streamlit-app"

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_menu() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Development Environment Manager${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo "Available commands:"
    echo "  1. start-react        - Start React development server"
    echo "  2. start-streamlit    - Start Streamlit server"
    echo "  3. start-both         - Start both servers"
    echo "  4. install-deps       - Install/update dependencies"
    echo "  5. status             - Show project status"
    echo "  6. open-ports         - Show open ports"
    echo "  7. help               - Show this menu"
    echo ""
}

start_react() {
    if [ ! -d "$REACT_PROJECT" ]; then
        echo -e "${RED}Error: React project not found at $REACT_PROJECT${NC}"
        return 1
    fi
    echo -e "${GREEN}Starting React development server...${NC}"
    cd "$REACT_PROJECT"
    npm start
}

start_streamlit() {
    if [ ! -d "$STREAMLIT_PROJECT" ]; then
        echo -e "${RED}Error: Streamlit project not found at $STREAMLIT_PROJECT${NC}"
        return 1
    fi
    echo -e "${GREEN}Starting Streamlit server...${NC}"
    cd "$STREAMLIT_PROJECT"
    
    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}Virtual environment not found. Creating...${NC}"
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    streamlit run app.py
}

start_both() {
    echo -e "${YELLOW}Starting both servers in new terminal windows...${NC}"
    
    # Start React in new gnome-terminal
    gnome-terminal -- bash -c "cd $REACT_PROJECT && npm start; exec bash" &
    sleep 2
    
    # Start Streamlit in new gnome-terminal
    gnome-terminal -- bash -c "cd $STREAMLIT_PROJECT && source venv/bin/activate && streamlit run app.py; exec bash" &
    
    echo -e "${GREEN}Both servers starting...${NC}"
    echo -e "React:     http://localhost:3000${NC}"
    echo -e "Streamlit: http://localhost:8501${NC}"
}

install_deps() {
    echo -e "${GREEN}Installing/updating dependencies...${NC}"
    
    echo -e "${BLUE}Updating npm packages...${NC}"
    cd "$REACT_PROJECT"
    npm install
    npm update
    
    echo -e "${BLUE}Updating Python packages...${NC}"
    cd "$STREAMLIT_PROJECT"
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt --upgrade
    
    echo -e "${GREEN}Dependencies updated!${NC}"
}

show_status() {
    echo ""
    echo -e "${BLUE}Project Status:${NC}"
    echo ""
    
    if [ -d "$REACT_PROJECT" ]; then
        echo -e "${GREEN}✓ React Project:${NC}"
        echo "  Location: $REACT_PROJECT"
        if [ -f "$REACT_PROJECT/package.json" ]; then
            echo "  Status: Configured"
            NODE_MODULES_SIZE=$(du -sh "$REACT_PROJECT/node_modules" 2>/dev/null | cut -f1)
            echo "  node_modules size: $NODE_MODULES_SIZE"
        else
            echo "  Status: Not configured"
        fi
    else
        echo -e "${RED}✗ React Project:${NC} Not found"
    fi
    
    echo ""
    
    if [ -d "$STREAMLIT_PROJECT" ]; then
        echo -e "${GREEN}✓ Streamlit Project:${NC}"
        echo "  Location: $STREAMLIT_PROJECT"
        if [ -d "$STREAMLIT_PROJECT/venv" ]; then
            echo "  Status: Virtual environment created"
            if [ -f "$STREAMLIT_PROJECT/requirements.txt" ]; then
                echo "  Dependencies: Configured"
            fi
        else
            echo "  Status: Virtual environment not created"
        fi
    else
        echo -e "${RED}✗ Streamlit Project:${NC} Not found"
    fi
    
    echo ""
    echo -e "${BLUE}Installed Versions:${NC}"
    echo "  Node.js: $(node --version)"
    echo "  npm: $(npm --version)"
    echo "  Python: $(python3 --version)"
    echo "  Streamlit: $(streamlit --version 2>/dev/null || echo 'Not installed')"
    echo ""
}

show_ports() {
    echo ""
    echo -e "${BLUE}Checking open ports...${NC}"
    echo ""
    
    # Check common development ports
    ports=(3000 3001 8501 8502 5000 8000)
    
    for port in "${ports[@]}"; do
        if netstat -tuln 2>/dev/null | grep -q ":$port "; then
            echo -e "${GREEN}Port $port: ACTIVE${NC}"
        else
            echo -e "${YELLOW}Port $port: available${NC}"
        fi
    done
    
    echo ""
}

# Main logic
case "${1:-help}" in
    start-react)
        start_react
        ;;
    start-streamlit)
        start_streamlit
        ;;
    start-both)
        start_both
        ;;
    install-deps)
        install_deps
        ;;
    status)
        show_status
        ;;
    open-ports)
        show_ports
        ;;
    help|"")
        print_menu
        ;;
    *)
        echo -e "${RED}Unknown command: $1${NC}"
        print_menu
        exit 1
        ;;
esac
