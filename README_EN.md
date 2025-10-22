# 🔒 Complete Guide: Customize Lock Screen Background on Linux Mint XFCE

*How to resolve lock screen conflicts and set your custom image*

---

## Table of Contents

1. [The Problem](#the-problem)
2. [Step-by-Step Solution](#step-by-step-solution)
3. [Final Configuration](#final-configuration)
4. [Troubleshooting](#troubleshooting)
5. [Automatic Script](#automatic-script)
6. [Conclusions](#conclusions)

---

## The Problem

On Linux Mint XFCE, it's common to have **conflicts between multiple lock screens** that cause:
- Black backgrounds
- Duplicate lock screens
- Inability to customize the background
- Service errors

**Typical symptoms:**
```
GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: 
The name org.freedesktop.ScreenSaver was not provided by any .service files
```

---

## Step-by-Step Solution

### Step 1: Complete System Cleanup

First, let's remove all existing lock screens and their configuration files:

```bash
# Remove all lock screen packages
sudo apt remove --purge light-locker light-locker-settings xfce4-screensaver xscreensaver cinnamon-screensaver mate-screensaver -y

# Remove residual configuration files
sudo find /etc -name "*screensaver*" -o -name "*light-locker*" 2>/dev/null | xargs sudo rm -f
sudo find /usr -name "*screensaver*" -o -name "*light-locker*" 2>/dev/null | xargs sudo rm -f
rm -rf ~/.config/autostart/*screensaver* ~/.config/autostart/*light-locker*
```

### Step 2: Clean Reinstallation

Reinstall only the necessary components:

```bash
# Update repositories
sudo apt update

# Install light-locker and gnome-screensaver (required for the service)
sudo apt install light-locker light-locker-settings gnome-screensaver -y
```

### Step 3: Image Preparation

Copy your preferred image to a system-accessible location:

```bash
# Find your image
find /home/$USER -name "*wallpaper*" -o -name "*pxfuel*" 2>/dev/null

# Copy image to system (replace with your image path)
sudo cp "/home/$USER/Pictures/wallpaperflare.com_wallpaper (1).jpg" /usr/share/backgrounds/lockscreen.jpg
sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg
```

### Step 4: XFCE Configuration

Configure XFCE to use light-locker:

```bash
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
```

### Step 5: Background Configuration

Set your image as the lock screen background:

```bash
# Configure gsettings to use your image
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
gsettings set org.gnome.desktop.screensaver picture-options "scaled"
```

### Step 6: Test

Test the system:

```bash
# Test the lock screen
light-locker-command -l
```

---

## Final Configuration

### File Structure

```
/usr/share/backgrounds/
├── lockscreen.jpg          # Your main image
└── lockscreen-alt.jpg      # Alternative image (optional)

~/.config/xfce4/xfconf/xfce-perchannel-xml/
└── xfce4-session.xml       # XFCE configuration
```

### Useful Commands

```bash
# Lock screen manually
light-locker-command -l

# Change image (replace with path to new image)
sudo cp "/path/to/new/image.jpg" /usr/share/backgrounds/lockscreen.jpg
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"

# Check lock screen status
ps aux | grep light-locker
```

---

## Automatic Script

To automate the process, use the included `set-lockscreen.sh` script:

```bash
# Make script executable
chmod +x set-lockscreen.sh

# Run the script
./set-lockscreen.sh
```

The script:
- Automatically finds images in the same folder
- Lets you choose between available images
- Automatically configures the lock screen
- Handles permissions and configurations

---

## Troubleshooting

### Problem: "ServiceUnknown" Error

**Cause:** Missing gnome-screensaver service

**Solution:**
```bash
sudo apt install gnome-screensaver -y
```

### Problem: Black Background

**Cause:** Image not accessible or wrong permissions

**Solution:**
```bash
# Verify image exists
ls -la /usr/share/backgrounds/lockscreen.jpg

# Fix permissions
sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg

# Reset gsettings
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
```

### Problem: Duplicate Lock Screens

**Cause:** Residual configuration files

**Solution:**
```bash
# Remove all autostart files
rm -f ~/.config/autostart/*lock* ~/.config/autostart/*screensaver*

# Restart session
sudo reboot
```

---

## Conclusions

With this guide you have:

- **Resolved** lock screen conflicts
- **Configured** light-locker as main system
- **Set** your custom image
- **Created** a stable and functional system

### Solution Benefits

- **Clean system:** No conflicts between lock screens
- **Customizable:** Easy to change image
- **Stable:** Standard XFCE configuration
- **Maintainable:** Easy to update and modify

### Next Steps

1. **Further customization:** Use "Light Locker Settings" for other options
2. **Backup:** Save configuration for future updates
3. **Explore:** Try other images for the lock screen

---

## Additional Resources

- [Official XFCE Documentation](https://docs.xfce.org/)
- [Linux Mint Community](https://forums.linuxmint.com/)
- [Light Locker GitHub](https://github.com/the-cavalry/light-locker)

---

*Guide created to solve lock screen issues on Linux Mint XFCE. Tested and working!*

**Enjoy your personalized lock screen! 🔒✨**
