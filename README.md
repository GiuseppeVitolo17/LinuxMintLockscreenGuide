# Guida Completa: Personalizzare lo Sfondo del Lock Screen su Linux Mint XFCE

*Come risolvere i conflitti tra lock screen e impostare la tua immagine personalizzata*

---

## Indice

1. [Il Problema](#il-problema)
2. [Soluzione Step-by-Step](#soluzione-step-by-step)
3. [Configurazione Finale](#configurazione-finale)
4. [Troubleshooting](#troubleshooting)
5. [Script Automatico](#script-automatico)
6. [Conclusioni](#conclusioni)

---

## Il Problema

Su Linux Mint XFCE, è comune avere **conflitti tra multiple lock screen** che causano:
- Sfondi neri
- Lock screen duplicati
- Impossibilità di personalizzare lo sfondo
- Errori di servizio

**Sintomi tipici:**
```
GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: 
The name org.freedesktop.ScreenSaver was not provided by any .service files
```

---

## Soluzione Step-by-Step

### Passo 1: Pulizia Completa del Sistema

Prima di tutto, rimuoviamo tutti i lock screen esistenti e i loro file di configurazione:

```bash
# Rimuovi tutti i pacchetti lock screen
sudo apt remove --purge light-locker light-locker-settings xfce4-screensaver xscreensaver cinnamon-screensaver mate-screensaver -y

# Rimuovi file di configurazione residui
sudo find /etc -name "*screensaver*" -o -name "*light-locker*" 2>/dev/null | xargs sudo rm -f
sudo find /usr -name "*screensaver*" -o -name "*light-locker*" 2>/dev/null | xargs sudo rm -f
rm -rf ~/.config/autostart/*screensaver* ~/.config/autostart/*light-locker*
```

### Passo 2: Reinstallazione Pulita

Reinstalliamo solo i componenti necessari:

```bash
# Aggiorna i repository
sudo apt update

# Installa light-locker e gnome-screensaver (necessario per il servizio)
sudo apt install light-locker light-locker-settings gnome-screensaver -y
```

### Passo 3: Preparazione dell'Immagine

Copia la tua immagine preferita in una posizione accessibile al sistema:

```bash
# Trova la tua immagine
find /home/$USER -name "*wallpaper*" -o -name "*pxfuel*" 2>/dev/null

# Copia l'immagine nel sistema (sostituisci con il percorso della tua immagine)
sudo cp "/home/$USER/Pictures/wallpaperflare.com_wallpaper (1).jpg" /usr/share/backgrounds/lockscreen.jpg
sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg
```

### Passo 4: Configurazione XFCE

Configura XFCE per usare light-locker:

```bash
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
```

### Passo 5: Configurazione dello Sfondo

Imposta la tua immagine come sfondo del lock screen:

```bash
# Configura gsettings per usare la tua immagine
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
gsettings set org.gnome.desktop.screensaver picture-options "scaled"
```

### Passo 6: Test

Testa il sistema:

```bash
# Testa il lock screen
light-locker-command -l
```

---

## Configurazione Finale

### Struttura File

```
/usr/share/backgrounds/
├── lockscreen.jpg          # La tua immagine principale
└── lockscreen-alt.jpg      # Immagine alternativa (opzionale)

~/.config/xfce4/xfconf/xfce-perchannel-xml/
└── xfce4-session.xml       # Configurazione XFCE
```

### Comandi Utili

```bash
# Blocca lo schermo manualmente
light-locker-command -l

# Cambia immagine (sostituisci con il percorso della nuova immagine)
sudo cp "/percorso/nuova/immagine.jpg" /usr/share/backgrounds/lockscreen.jpg
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"

# Verifica lo stato del lock screen
ps aux | grep light-locker
```

---

## Script Automatico

Per automatizzare il processo, usa lo script `set-lockscreen.sh` incluso in questa repository:

```bash
# Rendi eseguibile lo script
chmod +x set-lockscreen.sh

# Esegui lo script
./set-lockscreen.sh
```

Lo script:
- Trova automaticamente le immagini nella stessa cartella
- Ti permette di scegliere tra le immagini disponibili
- Configura automaticamente il lock screen
- Gestisce i permessi e le configurazioni

---

## Troubleshooting

### Problema: "ServiceUnknown" Error

**Causa:** Manca il servizio gnome-screensaver

**Soluzione:**
```bash
sudo apt install gnome-screensaver -y
```

### Problema: Sfondo Nero

**Causa:** Immagine non accessibile o permessi sbagliati

**Soluzione:**
```bash
# Verifica che l'immagine esista
ls -la /usr/share/backgrounds/lockscreen.jpg

# Correggi i permessi
sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg

# Reimposta gsettings
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
```

### Problema: Lock Screen Duplicati

**Causa:** File di configurazione residui

**Soluzione:**
```bash
# Rimuovi tutti gli autostart
rm -f ~/.config/autostart/*lock* ~/.config/autostart/*screensaver*

# Riavvia la sessione
sudo reboot
```

---

## Conclusioni

Con questa guida hai:

- **Risolto** i conflitti tra lock screen
- **Configurato** light-locker come sistema principale
- **Impostato** la tua immagine personalizzata
- **Creato** un sistema stabile e funzionante

### Vantaggi della Soluzione

- **Sistema pulito:** Nessun conflitto tra lock screen
- **Personalizzabile:** Facile cambiare l'immagine
- **Stabile:** Configurazione standard XFCE
- **Manutenibile:** Facile da aggiornare e modificare

### Prossimi Passi

1. **Personalizza ulteriormente:** Usa "Light Locker Settings" per altre opzioni
2. **Backup:** Salva la configurazione per futuri aggiornamenti
3. **Esplora:** Prova altre immagini per il lock screen

---

## Risorse Aggiuntive

- [Documentazione ufficiale XFCE](https://docs.xfce.org/)
- [Linux Mint Community](https://forums.linuxmint.com/)
- [Light Locker GitHub](https://github.com/the-cavalry/light-locker)

---

*Guida creata per risolvere i problemi di lock screen su Linux Mint XFCE. Testata e funzionante!*

**Buon lock screen personalizzato!**
