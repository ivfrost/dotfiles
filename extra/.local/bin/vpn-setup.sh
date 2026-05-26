#!/bin/bash
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE=${1:-install}

export_setup() {
    BACKUP=$HOME/setup-backup
    mkdir -p $BACKUP/etc/sudoers.d
    mkdir -p $BACKUP/etc/NetworkManager/dispatcher.d
    mkdir -p $BACKUP/desktop
    mkdir -p $BACKUP/scripts
    mkdir -p $BACKUP/autostart

    sudo cp /etc/sockd.conf $BACKUP/etc/
    sudo cp /etc/sudoers.d/toruser-launch $BACKUP/etc/sudoers.d/
    sudo cp /etc/NetworkManager/dispatcher.d/99-toruser-route $BACKUP/etc/NetworkManager/dispatcher.d/

    cp ~/.local/bin/tor-launch $BACKUP/scripts/
    cp ~/.local/bin/prolific-novpn.sh $BACKUP/scripts/ 2>/dev/null || true
    cp ~/.local/share/applications/org.torproject.torbrowser-launcher.desktop $BACKUP/desktop/
    cp ~/.config/autostart/xhost-toruser.desktop $BACKUP/autostart/
    grep -l "proxy-server" ~/.local/share/applications/*.desktop 2>/dev/null | xargs -I{} cp {} $BACKUP/desktop/ || true
    ls ~/.local/share/applications/*ungoogled_chromium*Profile_2* 2>/dev/null | xargs -I{} cp {} $BACKUP/desktop/ || true

    tar czf $HOME/setup-backup.tar.gz -C $HOME setup-backup
    echo "Exported to $HOME/setup-backup.tar.gz"
}

install_setup() {
    BACKUP=$HOME/setup-backup

    if [ ! -d $BACKUP ] && [ -f $HOME/setup-backup.tar.gz ]; then
        tar xzf $HOME/setup-backup.tar.gz -C $HOME
    fi

    # toruser
    id toruser &>/dev/null || sudo useradd -m -s /bin/bash toruser

    # dante
    rpm -q dante &>/dev/null || sudo dnf install -y dante

    # torbrowser-launcher
    rpm -q torbrowser-launcher &>/dev/null || sudo dnf install -y torbrowser-launcher

    # ungoogled chromium flatpak
    flatpak list | grep -q ungoogled_chromium || \
        flatpak install -y flathub io.github.ungoogled_software.ungoogled_chromium

    # sockd.conf
    diff -q $BACKUP/etc/sockd.conf /etc/sockd.conf &>/dev/null || sudo cp $BACKUP/etc/sockd.conf /etc/sockd.conf

    # ensure sockd runs as toruser so its traffic uses the uidrange 50 rule
    # toruser UID is routed via table 200 (bypasses WireGuard, exits physical interface)
    if ! grep -q "user.unprivileged" /etc/sockd.conf; then
        echo -e "\nuser.privileged: root\nuser.unprivileged: toruser" | sudo tee -a /etc/sockd.conf
    fi

    # sudoers
    [ -f /etc/sudoers.d/toruser-launch ] || {
        sudo cp $BACKUP/etc/sudoers.d/toruser-launch /etc/sudoers.d/
        sudo chmod 440 /etc/sudoers.d/toruser-launch
    }

    # NM dispatcher
    [ -f /etc/NetworkManager/dispatcher.d/99-toruser-route ] || {
        sudo cp $BACKUP/etc/NetworkManager/dispatcher.d/99-toruser-route /etc/NetworkManager/dispatcher.d/
        sudo chmod +x /etc/NetworkManager/dispatcher.d/99-toruser-route
    }

    # scripts and desktop files
    mkdir -p ~/.local/bin ~/.local/share/applications ~/.config/autostart
    cp $BACKUP/scripts/tor-launch ~/.local/bin/
    chmod +x ~/.local/bin/tor-launch
    [ -f $BACKUP/scripts/prolific-novpn.sh ] && {
        cp $BACKUP/scripts/prolific-novpn.sh ~/.local/bin/
        chmod +x ~/.local/bin/prolific-novpn.sh
    }
    cp $BACKUP/desktop/*.desktop ~/.local/share/applications/
    cp $BACKUP/autostart/*.desktop ~/.config/autostart/

    # start dante and restart so user.unprivileged takes effect
    sudo systemctl enable --now sockd
    sudo systemctl restart sockd

    # ip rule for toruser (table 200 = bypass WireGuard, direct via physical interface)
    TORUSER_UID=$(id -u toruser)
    ip rule show | grep -q "uidrange ${TORUSER_UID}-${TORUSER_UID}" || \
        sudo ip rule add uidrange ${TORUSER_UID}-${TORUSER_UID} lookup 200 priority 50

    # table 200 default route (restored on every install/reboot via this script)
    PHYSICAL_IFACE=enp5s0f4u1
    GATEWAY=192.168.1.1
    ip route show table 200 | grep -q "default" || \
        sudo ip route add default via $GATEWAY dev $PHYSICAL_IFACE table 200

    echo "Done."
}

case $MODE in
    export)  export_setup ;;
    install) install_setup ;;
    *)       echo "Usage: $0 [export|install]" ;;
esac
