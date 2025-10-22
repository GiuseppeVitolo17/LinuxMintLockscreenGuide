#!/bin/bash

# Script per impostare automaticamente il lock screen su Linux Mint XFCE
# Trova le immagini nella stessa cartella e permette di scegliere

set -e

# Colori per l'output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Funzione per stampare messaggi colorati
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

# Funzione per verificare se siamo root
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        print_error "Non eseguire questo script come root!"
        print_message "Esegui: ./set-lockscreen.sh"
        exit 1
    fi
}

# Funzione per verificare le dipendenze
check_dependencies() {
    print_message "Verifico le dipendenze..."
    
    if ! command -v light-locker-command &> /dev/null; then
        print_warning "light-locker non trovato. Installo i pacchetti necessari..."
        sudo apt update
        sudo apt install light-locker light-locker-settings gnome-screensaver -y
    fi
    
    if ! command -v gsettings &> /dev/null; then
        print_error "gsettings non trovato. Installa gnome-settings-daemon"
        exit 1
    fi
}

# Funzione per trovare le immagini
find_images() {
    print_message "Cerco immagini nella cartella corrente..."
    
    # Estensioni supportate
    EXTENSIONS=("*.jpg" "*.jpeg" "*.png" "*.bmp" "*.gif" "*.tiff")
    
    # Array per memorizzare le immagini trovate
    IMAGES=()
    
    for ext in "${EXTENSIONS[@]}"; do
        while IFS= read -r -d '' file; do
            IMAGES+=("$file")
        done < <(find . -maxdepth 1 -name "$ext" -type f -print0 2>/dev/null)
    done
    
    if [ ${#IMAGES[@]} -eq 0 ]; then
        print_error "Nessuna immagine trovata nella cartella corrente!"
        print_message "Assicurati di avere almeno un'immagine (jpg, png, bmp, gif, tiff) nella stessa cartella dello script."
        exit 1
    fi
    
    print_message "Trovate ${#IMAGES[@]} immagini:"
    echo
}

# Funzione per mostrare il menu di selezione
show_image_menu() {
    echo -e "${BLUE}Seleziona un'immagine per il lock screen:${NC}"
    echo
    
    for i in "${!IMAGES[@]}"; do
        echo -e "${GREEN}$((i+1)).${NC} ${IMAGES[$i]}"
    done
    
    echo
    echo -e "${YELLOW}0.${NC} Esci"
    echo
}

# Funzione per ottenere la selezione dell'utente
get_user_choice() {
    while true; do
        read -p "Inserisci il numero dell'immagine (0-${#IMAGES[@]}): " choice
        
        if [[ "$choice" =~ ^[0-9]+$ ]]; then
            if [ "$choice" -eq 0 ]; then
                print_message "Operazione annullata."
                exit 0
            elif [ "$choice" -ge 1 ] && [ "$choice" -le ${#IMAGES[@]} ]; then
                SELECTED_IMAGE="${IMAGES[$((choice-1))]}"
                break
            else
                print_error "Scelta non valida. Inserisci un numero tra 0 e ${#IMAGES[@]}"
            fi
        else
            print_error "Inserisci un numero valido."
        fi
    done
}

# Funzione per copiare l'immagine nel sistema
copy_image_to_system() {
    print_message "Copio l'immagine nel sistema..."
    
    # Crea la directory se non esiste
    sudo mkdir -p /usr/share/backgrounds/
    
    # Copia l'immagine
    sudo cp "$SELECTED_IMAGE" /usr/share/backgrounds/lockscreen.jpg
    
    # Imposta i permessi corretti
    sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg
    
    print_message "Immagine copiata in /usr/share/backgrounds/lockscreen.jpg"
}

# Funzione per configurare XFCE
configure_xfce() {
    print_message "Configuro XFCE per usare light-locker..."
    
    # Crea la directory se non esiste
    mkdir -p ~/.config/xfce4/xfconf/xfce-perchannel-xml/
    
    # Crea la configurazione XFCE
    cat > ~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<channel name="xfce4-session" version="1.0">
  <property name="general" type="empty">
    <property name="LockCommand" type="string" value="light-locker-command -l"/>
    <property name="SaveOnExit" type="bool" value="true"/>
  </property>
</channel>
EOF
    
    print_message "Configurazione XFCE creata"
}

# Funzione per configurare gsettings
configure_gsettings() {
    print_message "Configuro gsettings per usare la tua immagine..."
    
    # Imposta l'immagine come sfondo del lock screen
    gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
    gsettings set org.gnome.desktop.screensaver picture-options "scaled"
    
    print_message "gsettings configurato"
}

# Funzione per testare il lock screen
test_lockscreen() {
    print_message "Testo il lock screen..."
    
    if light-locker-command -l &> /dev/null; then
        print_message "Lock screen testato con successo!"
        print_warning "Sblocca lo schermo per continuare..."
    else
        print_error "Errore nel test del lock screen"
        return 1
    fi
}

# Funzione per mostrare le informazioni finali
show_final_info() {
    echo
    print_message "Configurazione completata con successo!"
    echo
    echo -e "${BLUE}Informazioni:${NC}"
    echo -e "• Immagine selezionata: ${GREEN}$SELECTED_IMAGE${NC}"
    echo -e "• Posizione sistema: ${GREEN}/usr/share/backgrounds/lockscreen.jpg${NC}"
    echo -e "• Configurazione XFCE: ${GREEN}~/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-session.xml${NC}"
    echo
    echo -e "${BLUE}Comandi utili:${NC}"
    echo -e "• Blocca schermo: ${YELLOW}light-locker-command -l${NC}"
    echo -e "• Cambia immagine: ${YELLOW}sudo cp nuova_immagine.jpg /usr/share/backgrounds/lockscreen.jpg${NC}"
    echo -e "• Aggiorna gsettings: ${YELLOW}gsettings set org.gnome.desktop.screensaver picture-uri \"file:///usr/share/backgrounds/lockscreen.jpg\"${NC}"
    echo
    print_message "Riavvia il sistema per applicare tutte le modifiche!"
}

# Funzione principale
main() {
    print_header
    
    # Verifiche preliminari
    check_sudo
    check_dependencies
    
    # Trova le immagini
    find_images
    
    # Mostra il menu e ottieni la selezione
    show_image_menu
    get_user_choice
    
    print_message "Hai selezionato: $SELECTED_IMAGE"
    echo
    
    # Configura il sistema
    copy_image_to_system
    configure_xfce
    configure_gsettings
    
    # Testa il lock screen
    if test_lockscreen; then
        show_final_info
    else
        print_error "Configurazione completata ma il test del lock screen è fallito."
        print_message "Prova a riavviare il sistema."
    fi
}

# Esegui lo script
main "$@"
