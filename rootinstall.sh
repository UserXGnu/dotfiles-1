#!/bin/bash

######################################################
## installs all system wide dotfiles for instantOS  ##
######################################################

if ! [ $(whoami) = "root" ]; then
    echo "please run this as root"
    exit 1
fi

# enable arch pacman easter egg
if command -v pacman && [ -e /etc/pacman.conf ] &&
    ! grep -q 'ILoveCandy' </etc/pacman.conf; then
    echo "pacmanifiying your pacman manager"
    sed -i '/VerbosePkgLists/a ILoveCandy' /etc/pacman.conf
fi

# change greeter appearance
[ -e /etc/lightdm ] || mkdir -p /etc/lightdm
cat /usr/share/instantdotfiles/lightdm-gtk-greeter.conf >/etc/lightdm/lightdm-gtk-greeter.conf

# fix/improve grub settings on nvidia
# also fixes tty resolution
if ! grep -i 'pb-grub' </etc/default/grub && command -v nvidia-smi; then
    RESOLUTION=$(xrandr | grep -oP '[0-9]{3,4}x[0-9]{3,4}' | head -1)

    if [ -n "$RESOLUTION" ]; then
        if grep -i "$RESOLUTION" </etc/default/grub; then
            echo "grub resolution already fixed"
        else
            sed -i 's~GRUB_GFXMODE=.*~GRUB_GFXMODE='"$RESOLUTION"'~g' /etc/default/grub
        fi
    fi

    if command -v update-grub; then
        update-grub
    else
        grub-mkconfig -o /boot/grub/grub.cfg
    fi

fi
