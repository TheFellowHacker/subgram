#!/bin/bash

# Define colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 11)
CYAN=$(tput setaf 6)
WHITE=$(tput setaf 15)
RESET=$(tput sgr0)  # Reset color

# Default output directory
DEFAULT_OUTPUT_DIR="subgram_output"

# Function to send notification to Telegram
send_telegram_notification() {
    echo -e "$WHITE Sending Telegram notification...$RESET"

    # Set Telegram bot token and chat ID
    TELEGRAM_BOT_TOKEN="your_bot_token"  # Replace with your bot token
    TELEGRAM_CHAT_ID="telegram_chat_id"      # Replace with your chat ID

    # Compose message
    MESSAGE="Subdomain Enumeration Complete for $DOMAIN. Results are saved in $OUTPUT_DIR directory."

    # Send message using Telegram Bot API
    curl -s -X POST "https://api.telegram.org/bot$TELEGRAM_BOT_TOKEN/sendMessage" -d "chat_id=$TELEGRAM_CHAT_ID" -d "text=$MESSAGE" > /dev/null

    if [ $? -eq 0 ]; then
        echo "Telegram notification sent successfully."
    else
        echo -e "$RED Failed to send Telegram notification.$RESET"
    fi
}

# Function to perform subdomain enumeration
perform_subdomain_enumeration() {
    # Check if figlet is installed
    if ! command -v figlet &> /dev/null; then
        echo "Figlet is not installed. Installing..."
        # Install figlet
        sudo apt-get update
        sudo apt-get install -y figlet
    else
        color_code="\033[31m" # Red color code
        reset_color="\033[0m" # Reset color code

        figlet_text=$(figlet "\$ubgr@m")
        colored_text="${color_code}${figlet_text}${reset_color}"
        echo -e "$colored_text"

        echo -e "${YELLOW}# Coded by Tahir Mujawar${RESET}"
        echo
    fi

    DOMAIN="$1"
    OUTPUT_DIR="$2"
    mkdir -p "$OUTPUT_DIR"

     #Subdomain enumeration using sublist3r
    echo -e "$WHITE Scanning $DOMAIN with sublist3r...$RESET"
    sublist3r -d "$DOMAIN" -o "$OUTPUT_DIR/${DOMAIN}_sublist3r.txt" > /dev/null 2>&1

    # Subdomain enumeration using subfinder
    echo -e "$WHITE Scanning $DOMAIN with subfinder...$RESET"
    subfinder -d "$DOMAIN" -o "$OUTPUT_DIR/${DOMAIN}_subfinder.txt" > /dev/null 2>&1

    # Subdomain enumeration using assetfinder
    echo -e "$WHITE Scanning $DOMAIN with assetfinder...$RESET"
    assetfinder -subs-only "$DOMAIN" > "$OUTPUT_DIR/${DOMAIN}_assetfinder.txt" 2> /dev/null
    
    cd $OUTPUT_DIR
    cat $DOMAIN_*.txt | sort -u > all-subdomains.txt
    
    echo -e "$YELLOW Scan completed for $DOMAIN. Results saved in $OUTPUT_DIR directory.$RESET"

    # Send Telegram notification if requested
    if [[ "$SEND_NOTIFICATION" == "yes" ]]; then
        send_telegram_notification
    fi
}

# Function to display usage
display_usage() {
    echo "Usage: $0 -d DOMAIN [-n] [-o OUTPUT_DIR]"
    echo "Options:"
    echo "  -d DOMAIN           Domain name for subdomain enumeration"
    echo "  -n                  Enable Telegram notification (default: no)"
    echo "  -o OUTPUT_DIR       Specify output directory (default: '$DEFAULT_OUTPUT_DIR')"
    echo "  -h                  Display this help message"
}

# Parse command-line options
while getopts ":d:no:h" opt; do
    case ${opt} in
        d )
            DOMAIN="$OPTARG"
            ;;
        n )
            SEND_NOTIFICATION="yes"
            ;;
        o )
            OUTPUT_DIR="$OPTARG"
            ;;
        h )
            display_usage
            exit 0
            ;;
        \? )
            echo "Invalid option: -$OPTARG" >&2
            display_usage
            exit 1
            ;;
        : )
            echo "Option -$OPTARG requires an argument." >&2
            display_usage
            exit 1
            ;;
    esac
done

# Check if DOMAIN argument is provided
if [ -z "$DOMAIN" ]; then
    echo -e "$RED Error: Domain argument missing $RESET"
    display_usage
    exit 1
fi

# Set default OUTPUT_DIR if not provided
if [ -z "$OUTPUT_DIR" ]; then
    OUTPUT_DIR="$DEFAULT_OUTPUT_DIR"
fi

# Perform subdomain enumeration
perform_subdomain_enumeration "$DOMAIN" "$OUTPUT_DIR"
