#!/bin/bash

# Bash script for subdomain enumeration and Telegram notifications

# Function to send notification to Telegram
send_telegram_notification() {
    echo "Sending Telegram notification..."

    # Set Telegram bot token and chat ID
    TELEGRAM_BOT_TOKEN="your_bot_token"  # Replace with your bot token
    TELEGRAM_CHAT_ID="your_chat_id"      # Replace with your chat ID

    # Compose message
    MESSAGE="Subdomain Enumeration Complete for $DOMAIN\nResults are saved in $DOMAIN directory."

    # Send message using Telegram Bot API
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$MESSAGE" > /dev/null

    if [ $? -eq 0 ]; then
        echo "Telegram notification sent successfully."
    else
        echo "Failed to send Telegram notification."
    fi
}

# Function to perform subdomain enumeration
perform_subdomain_enumeration() {
    DOMAIN="$1"
    OUTPUT_DIR="$DOMAIN"
    mkdir "$OUTPUT_DIR"
    
    # Subdomain enumeration using sublist3r
    echo "Running sublist3r..."
    sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/sublist3r.txt" > /dev/null 2 >&1

    # Subdomain enumeration using subfinder
    echo "Running subfinder..."
    subfinder -d "$DOMAIN" -silent -o "$OUTPUT_DIR/subfinder.txt" 

    # Subdomain enumeration using assetfinder
    echo "Running assetfinder..."
    assetfinder "$DOMAIN" > "$OUTPUT_DIR/assetfinder.txt" > /dev/null 2 >&1

    # Subdomain enumeration using chaos
    echo "Running chaos..."
    chaos -d facebook.com -key 0f64667b-741d-4073-953d-4171116dc42d -silent > "$OUTPUT_DIR/chaos.txt" 
    
    echo "Subdomain enumeration completed. Results saved in $OUTPUT_DIR directory."
    
    # Send Telegram notification if requested
    if [[ "$SEND_NOTIFICATION" == "yes" ]]; then
        send_telegram_notification
    fi
}

# Main script
echo "Welcome to Subdomain Enumeration Script! By Tahir Mujawar"

# Ask user if they want to receive notification
read -p "Do you want to receive notification upon completion of subdomain enumeration? (yes/no): " SEND_NOTIFICATION

# Ask user for the domain name for subdomain enumeration
read -p "Enter the domain name for subdomain enumeration: " DOMAIN

# Perform subdomain enumeration
perform_subdomain_enumeration "$DOMAIN"
