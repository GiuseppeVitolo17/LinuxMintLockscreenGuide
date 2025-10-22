#!/bin/bash

# Script to automatically set lock screen on Linux Mint XFCE
# Finds images in the same folder and allows you to choose

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored messages
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  Linux Mint Lock Screen Setup  ${NC}"
    echo -e "${BLUE}================================${NC}"
    echo
}

# Function to check if we are root
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Don't run this script as root!"
        print_message "Run: ./set-lockscreen-en.sh"
        exit 1
    fi
}

# Function to check dependencies
check_dependencies() {
    print_message "Checking dependencies..."
    
    if ! command -v light-locker-command &> /dev/null; then
        print_warning "light-locker not found. Installing necessary packages..."
        sudo apt update
        sudo apt install light-locker light-locker-settings gnome-screensaver -y
    fi
    
    if ! command -v gsettings &> /dev/null; then
        print_error "gsettings not found. Install gnome-settings-daemon"
        exit 1
    fi
}

# Function to find images
find_images() {
    print_message "Looking for images in current folder..."
    
    # Supported extensions
    EXTENSIONS=("*.jpg" "*.jpeg" "*.png" "*.bmp" "*.gif" "*.tiff")
    
    # Array to store found images
    IMAGES=()
    
    for ext in "${EXTENSIONS[@]}"; do
        while IFS= read -r -d '' file; do
            IMAGES+=("$file")
        done < <(find . -maxdepth 1 -name "$ext" -type f -print0 2>/dev/null)
    done
    
    if [ ${#IMAGES[@]} -eq 0 ]; then
        print_error "No images found in current folder!"
        print_message "Make sure you have at least one image (jpg, png, bmp, gif, tiff) in the same folder as the script."
        exit 1
    fi
    
    print_message "Found ${#IMAGES[@]} images:"
    echo
}

# Function to show selection menu
show_image_menu() {
    echo -e "${BLUE}Select an image for the lock screen:${NC}"
    echo
    
    for i in "${!IMAGES[@]}"; do
        echo -e "${GREEN}$((i+1)).${NC} ${IMAGES[$i]}"
    done
    
    echo
    echo -e "${YELLOW}0.${NC} Exit"
    echo
}

# Function to get user selection
get_user_choice() {
    while true; do
        read -p "Enter image number (0-${#IMAGES[@]}): " choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -eq 0 ]; then
                print_message "Operation cancelled."
                exit 0
            elif [ "$choice" -ge 1 ] && [ "$choice" -le ${#IMAGES[@]} ]; then
                SELECTED_IMAGE="${IMAGES[$((choice-1))]}"
                break
            else
                print_error "Invalid choice. Enter a number between 0 and ${#IMAGES[@]}"
            fi
        else
            print_error "Enter a valid number."
        fi
    done
}

# Function to copy image to system
copy_image_to_system() {
    print_message "Copying image to system..."
    
    # Create directory if it doesn't exist
    sudo mkdir -p /usr/share/backgrounds/
    
    # Copy image
    sudo cp "$SELECTED_IMAGE" /usr/share/backgrounds/lockscreen.jpg
    
    # Set correct permissions
    sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg
    
    print_message "Image copied to /usr/share/backgrounds/lockscreen.jpg"
}

# Function to configure XFCE
configure_xfce() {
    print_message "Configuring XFCE to use light-locker..."
    
    # Create directory if it doesn't exist
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    
    # Create XFCE configuration
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="LockCommand" type="string" value="light-locker-command -l"/>
    <property name="SaveOnExit" type="bool" value="true"/>
  </property>
</channel>
EOF
    
    print_message "XFCE configuration created"
}

# Function to configure gsettings
configure_gsettings() {
    print_message "Configuring gsettings to use your image..."
    
    # Set image as lock screen background
    gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
    gsettings set org.gnome.desktop.screensaver picture-options "scaled"
    
    print_message "gsettings configured"
}

# Function to test lock screen
test_lockscreen() {
    print_message "Testing lock screen..."
    
    if light-locker-command -l &> /dev/null; then
        print_message "Lock screen tested successfully!"
        print_warning "Unlock screen to continue..."
    else
        print_error "Lock screen test failed"
        return 1
    fi
}

# Function to show final information
show_final_info() {
    echo
    print_message "Configuration completed successfully!"
    echo
    echo -e "${BLUE}Information:${NC}"
    echo -e "• Selected image: ${GREEN}$SELECTED_IMAGE${NC}"
    echo -e "• System location: ${GREEN}/usr/share/backgrounds/lockscreen.jpg${NC}"
    echo -e "• XFCE configuration: ${GREEN}~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml${NC}"
    echo
    echo -e "${BLUE}Useful commands:${NC}"
    echo -e "• Lock screen: ${YELLOW}light-locker-command -l${NC}"
    echo -e "• Change image: ${YELLOW}sudo cp new_image.jpg /usr/share/backgrounds/lockscreen.jpg${NC}"
    echo -e "• Update gsettings: ${YELLOW}gsettings set org.gnome.desktop.screensaver picture-uri \"file:///usr/share/backgrounds/lockscreen.jpg\"${NC}"
    echo
    print_message "Restart the system to apply all changes!"
}

# Main function
main() {
    print_header
    
    # Preliminary checks
    check_sudo
    check_dependencies
    
    # Find images
    find_images
    
    # Show menu and get selection
    show_image_menu
    get_user_choice
    
    print_message "You selected: $SELECTED_IMAGE"
    echo
    
    # Configure system
    copy_image_to_system
    configure_xfce
    configure_gsettings
    
    # Test lock screen
    if test_lockscreen; then
        show_final_info
    else
        print_error "Configuration completed but lock screen test failed."
        print_message "Try restarting the system."
    fi
}

# Run script
main "$@"
