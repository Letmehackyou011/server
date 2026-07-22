#!/bin/bash

# VMware Ubuntu Development Environment Setup
# Installs: Node.js, React, TypeScript, Python, Streamlit
# Run with: bash setup_dev_environment.sh

set -e  # Exit on error

echo "=========================================="
echo "VMware Ubuntu Dev Environment Setup"
echo "=========================================="
echo ""

# Color codes for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[*]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# ==========================================
# 1. Update System Packages
# ==========================================
print_status "Updating system packages..."
sudo apt-get update
sudo apt-get upgrade -y
print_success "System packages updated"
echo ""

# ==========================================
# 2. Install Node.js and npm
# ==========================================
print_status "Installing Node.js and npm..."

if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_warning "Node.js already installed: $NODE_VERSION"
else
    # Install Node.js LTS using NodeSource repository
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js and npm installed"
    node --version
    npm --version
fi
echo ""

# ==========================================
# 3. Install Python 3 and pip
# ==========================================
print_status "Installing Python 3 and pip..."

if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version)
    print_warning "Python 3 already installed: $PYTHON_VERSION"
else
    sudo apt-get install -y python3 python3-pip python3-venv
    print_success "Python 3 and pip installed"
    python3 --version
    pip3 --version
fi
echo ""

# ==========================================
# 4. Install Build Tools
# ==========================================
print_status "Installing build tools..."
sudo apt-get install -y build-essential git curl wget
print_success "Build tools installed"
echo ""

# ==========================================
# 5. Install Streamlit
# ==========================================
print_status "Installing Streamlit..."
pip3 install --upgrade pip
pip3 install streamlit
print_success "Streamlit installed"
streamlit --version
echo ""

# ==========================================
# 6. Create Project Directory Structure
# ==========================================
PROJECT_DIR="$HOME/dev_projects"
REACT_PROJECT="$PROJECT_DIR/react-app"
STREAMLIT_PROJECT="$PROJECT_DIR/streamlit-app"

print_status "Creating project directories..."
mkdir -p "$REACT_PROJECT"
mkdir -p "$STREAMLIT_PROJECT"
print_success "Projects directory created at: $PROJECT_DIR"
echo ""

# ==========================================
# 7. Create React + TypeScript Project
# ==========================================
print_status "Setting up React + TypeScript project..."
cd "$REACT_PROJECT"

if [ ! -f "package.json" ]; then
    # Using Create React App with TypeScript template
    npx -y create-react-app . --template typescript
    print_success "React + TypeScript project created"
else
    print_warning "React project already exists"
fi
echo ""

# ==========================================
# 8. Create Streamlit Project Structure
# ==========================================
print_status "Setting up Streamlit project..."
cd "$STREAMLIT_PROJECT"

# Create Python virtual environment
if [ ! -d "venv" ]; then
    python3 -m venv venv
    source venv/bin/activate
    print_success "Virtual environment created"
else
    print_warning "Virtual environment already exists"
    source venv/bin/activate
fi

# Create requirements.txt
cat > requirements.txt << 'EOF'
streamlit>=1.28.0
pandas>=2.0.0
numpy>=1.24.0
plotly>=5.0.0
EOF

pip install -r requirements.txt
print_success "Streamlit dependencies installed"

# Create sample Streamlit app
cat > app.py << 'EOF'
import streamlit as st
import pandas as pd
import numpy as np

st.set_page_config(page_title="Streamlit App", layout="wide")

st.title("Welcome to Streamlit! 👋")

st.write("""
This is a sample Streamlit application running on Ubuntu.
""")

# Sample data
data = {
    'Month': ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun'],
    'Sales': [100, 150, 200, 180, 220, 250],
    'Expenses': [80, 90, 110, 100, 120, 130]
}
df = pd.DataFrame(data)

col1, col2 = st.columns(2)

with col1:
    st.subheader("Sample Data")
    st.dataframe(df)

with col2:
    st.subheader("Sales Chart")
    st.line_chart(df.set_index('Month'))

st.divider()

st.subheader("Interactive Elements")
name = st.text_input("Enter your name:")
if name:
    st.write(f"Hello, {name}! 🎉")

slider_value = st.slider("Select a value:", 0, 100, 50)
st.write(f"You selected: {slider_value}")
EOF

print_success "Sample Streamlit app created at: $STREAMLIT_PROJECT/app.py"
echo ""

# ==========================================
# 9. Create Shell Scripts for Easy Running
# ==========================================
print_status "Creating convenience scripts..."

# React startup script
cat > "$PROJECT_DIR/run_react.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/react-app"
echo "Starting React development server..."
echo "App will be available at: http://localhost:3000"
npm start
EOF

chmod +x "$PROJECT_DIR/run_react.sh"

# Streamlit startup script
cat > "$PROJECT_DIR/run_streamlit.sh" << 'EOF'
#!/bin/bash
cd "$(dirname "$0")/streamlit-app"
source venv/bin/activate
echo "Starting Streamlit app..."
echo "App will be available at: http://localhost:8501"
streamlit run app.py
EOF

chmod +x "$PROJECT_DIR/run_streamlit.sh"

print_success "Startup scripts created"
echo ""

# ==========================================
# 10. Display Summary
# ==========================================
echo ""
echo "=========================================="
echo "✓ Setup Complete!"
echo "=========================================="
echo ""
echo -e "${GREEN}Project Directories:${NC}"
echo "  React + TypeScript: $REACT_PROJECT"
echo "  Streamlit:          $STREAMLIT_PROJECT"
echo ""
echo -e "${GREEN}Quick Start Commands:${NC}"
echo ""
echo "React Development Server:"
echo "  cd $REACT_PROJECT"
echo "  npm start"
echo "  (Available at http://localhost:3000)"
echo ""
echo "Streamlit Application:"
echo "  cd $STREAMLIT_PROJECT"
echo "  source venv/bin/activate"
echo "  streamlit run app.py"
echo "  (Available at http://localhost:8501)"
echo ""
echo -e "${GREEN}Or use the convenience scripts:${NC}"
echo "  $PROJECT_DIR/run_react.sh"
echo "  $PROJECT_DIR/run_streamlit.sh"
echo ""
echo -e "${GREEN}Installed Versions:${NC}"
echo "  Node.js: $(node --version)"
echo "  npm: $(npm --version)"
echo "  Python: $(python3 --version)"
echo "  Streamlit: $(streamlit --version)"
echo ""
echo "=========================================="
