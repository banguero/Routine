#!/bin/bash

# Routine Photo Analysis Setup Script
# This script helps you set up real AI-powered food recognition

set -e

echo "🍎 Routine - Photo Analysis Setup"
echo "=================================="
echo ""

# Check if Config.plist already exists
if [ -f "Routine/Config.plist" ]; then
    echo "⚠️  Config.plist already exists!"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

# Copy template
echo "📋 Creating Config.plist from template..."
cp Routine/Config.plist.template Routine/Config.plist
echo "✅ Config.plist created"
echo ""

# Prompt for API key
echo "🔑 OpenAI API Key Setup"
echo "------------------------"
echo "To enable real food recognition, you need an OpenAI API key."
echo ""
echo "Get your key at: https://platform.openai.com/api-keys"
echo ""
read -p "Enter your OpenAI API key (or press Enter to skip): " api_key

if [ -z "$api_key" ]; then
    echo ""
    echo "⚠️  No API key provided."
    echo "   The app will use mock data until you add a key to Routine/Config.plist"
    echo ""
    echo "   To add your key later, edit Routine/Config.plist and replace YOUR_API_KEY_HERE"
else
    # Update the plist file
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s/YOUR_API_KEY_HERE/$api_key/g" Routine/Config.plist
    else
        # Linux
        sed -i "s/YOUR_API_KEY_HERE/$api_key/g" Routine/Config.plist
    fi
    echo ""
    echo "✅ API key configured successfully!"
fi

echo ""
echo "📚 Next Steps"
echo "-------------"
echo "1. Open Routine.xcodeproj in Xcode"
echo "2. Build and run the app (⌘R)"
echo "3. Tap '+' → 'Scan Food' to test photo analysis"
echo ""
echo "📖 For more information, see PHOTO_ANALYSIS_SETUP.md"
echo ""
echo "🎉 Setup complete!"
