#!/bin/bash
# Setup Orbit in your microservice project
# Usage: ./setup-orbit.sh

set -e

echo "================================================"
echo "       Orbit Framework Setup Script"
echo "================================================"
echo ""

# Check if we're in a git repo
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository"
    echo "Run this script from your microservice project root"
    exit 1
fi

echo "✅ Git repository detected"
echo ""

# Check if Orbit template folder exists
if [ ! -d "orbit-template" ]; then
    echo "📥 Cloning Orbit template repository..."
    git clone https://github.com/nowWin09/Orbit-Microservice-test.git orbit-template
else
    echo "📥 Updating Orbit template repository..."
    cd orbit-template
    git pull origin main
    cd ..
fi

echo "✅ Template cloned"
echo ""

# Check if .cursor already exists
if [ -d ".cursor" ]; then
    echo "⚠️  .cursor folder already exists"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping .cursor copy"
    else
        rm -rf .cursor
        cp -r orbit-template/.cursor .
        echo "✅ .cursor copied"
    fi
else
    cp -r orbit-template/.cursor .
    echo "✅ .cursor copied"
fi

echo ""

# Check if docs already exists
if [ -d "docs" ]; then
    echo "⚠️  docs folder already exists"
    read -p "Overwrite? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Skipping docs copy"
    else
        rm -rf docs
        cp -r orbit-template/docs .
        echo "✅ docs copied"
    fi
else
    cp -r orbit-template/docs .
    echo "✅ docs copied"
fi

echo ""

# Cleanup template folder
echo "🧹 Cleaning up template..."
rm -rf orbit-template
echo "✅ Template removed"

echo ""
echo "================================================"
echo "       Setup Complete!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Run: /init"
echo "  2. Read: docs/ORBIT_QUICK_START.md"
echo "  3. Start: /start implement <feature> for <TICKET>"
echo ""
echo "Commit to git:"
echo "  git add .cursor/ docs/"
echo "  git commit -m 'Add: Project Orbit framework'"
echo "  git push"
echo ""
echo "For help: See docs/README.md"
echo ""
