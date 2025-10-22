# 🔒 Guide Complet : Personnaliser l'Arrière-plan de l'Écran de Verrouillage sur Linux Mint XFCE

*Comment résoudre les conflits d'écran de verrouillage et définir votre image personnalisée*

---

## Table des Matières

1. [Le Problème](#le-problème)
2. [Solution Étape par Étape](#solution-étape-par-étape)
3. [Configuration Finale](#configuration-finale)
4. [Dépannage](#dépannage)
5. [Script Automatique](#script-automatique)
6. [Conclusions](#conclusions)

---

## Le Problème

Sur Linux Mint XFCE, il est courant d'avoir **des conflits entre plusieurs écrans de verrouillage** qui causent :
- Arrière-plans noirs
- Écrans de verrouillage dupliqués
- Impossibilité de personnaliser l'arrière-plan
- Erreurs de service

**Symptômes typiques :**
```
GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: 
The name org.freedesktop.ScreenSaver was not provided by any .service files
```

---

## Solution Étape par Étape

### Étape 1 : Nettoyage Complet du Système

D'abord, supprimons tous les écrans de verrouillage existants et leurs fichiers de configuration :

```bash
# Supprimer tous les paquets d'écran de verrouillage
sudo apt remove --purge light-locker light-locker-settings xfce4-screensaver xscreensaver cinnamon-screensaver mate-screensaver -y

# Supprimer les fichiers de configuration résiduels
sudo find /etc -name "*screensaver*" -o -name "*light-locker*" 2>/dev/null | xargs sudo rm -f
sudo find /usr -name "*screensaver*" -o -name "*light-locker*" 2>/dev/null | xargs sudo rm -f
rm -rf ~/.config/autostart/*screensaver* ~/.config/autostart/*light-locker*
```

### Étape 2 : Réinstallation Propre

Réinstallons seulement les composants nécessaires :

```bash
# Mettre à jour les dépôts
sudo apt update

# Installer light-locker et gnome-screensaver (requis pour le service)
sudo apt install light-locker light-locker-settings gnome-screensaver -y
```

### Étape 3 : Préparation de l'Image

Copiez votre image préférée dans un emplacement accessible au système :

```bash
# Trouver votre image
find /home/$USER -name "*wallpaper*" -o -name "*pxfuel*" 2>/dev/null

# Copier l'image dans le système (remplacer par le chemin de votre image)
sudo cp "/home/$USER/Pictures/wallpaperflare.com_wallpaper (1).jpg" /usr/share/backgrounds/lockscreen.jpg
sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg
```

### Étape 4 : Configuration XFCE

Configurez XFCE pour utiliser light-locker :

```bash
# Créer la configuration XFCE
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

### Étape 5 : Configuration de l'Arrière-plan

Définissez votre image comme arrière-plan de l'écran de verrouillage :

```bash
# Configurer gsettings pour utiliser votre image
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
gsettings set org.gnome.desktop.screensaver picture-options "scaled"
```

### Étape 6 : Test

Testez le système :

```bash
# Tester l'écran de verrouillage
light-locker-command -l
```

---

## Configuration Finale

### Structure des Fichiers

```
/usr/share/backgrounds/
├── lockscreen.jpg          # Votre image principale
└── lockscreen-alt.jpg      # Image alternative (optionnelle)

~/.config/xfce4/xfconf/xfce-perchannel-xml/
└── xfce4-session.xml       # Configuration XFCE
```

### Commandes Utiles

```bash
# Verrouiller l'écran manuellement
light-locker-command -l

# Changer d'image (remplacer par le chemin de la nouvelle image)
sudo cp "/chemin/vers/nouvelle/image.jpg" /usr/share/backgrounds/lockscreen.jpg
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"

# Vérifier le statut de l'écran de verrouillage
ps aux | grep light-locker
```

---

## Script Automatique

Pour automatiser le processus, utilisez le script `set-lockscreen-fr.sh` inclus :

```bash
# Rendre le script exécutable
chmod +x set-lockscreen-fr.sh

# Exécuter le script
./set-lockscreen-fr.sh
```

Le script :
- Trouve automatiquement les images dans le même dossier
- Vous permet de choisir entre les images disponibles
- Configure automatiquement l'écran de verrouillage
- Gère les permissions et configurations

---

## Dépannage

### Problème : Erreur "ServiceUnknown"

**Cause :** Service gnome-screensaver manquant

**Solution :**
```bash
sudo apt install gnome-screensaver -y
```

### Problème : Arrière-plan Noir

**Cause :** Image non accessible ou mauvaises permissions

**Solution :**
```bash
# Vérifier que l'image existe
ls -la /usr/share/backgrounds/lockscreen.jpg

# Corriger les permissions
sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg

# Réinitialiser gsettings
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
```

### Problème : Écrans de Verrouillage Dupliqués

**Cause :** Fichiers de configuration résiduels

**Solution :**
```bash
# Supprimer tous les fichiers d'autostart
rm -f ~/.config/autostart/*lock* ~/.config/autostart/*screensaver*

# Redémarrer la session
sudo reboot
```

---

## Conclusions

Avec ce guide vous avez :

- **Résolu** les conflits d'écran de verrouillage
- **Configuré** light-locker comme système principal
- **Défini** votre image personnalisée
- **Créé** un système stable et fonctionnel

### Avantages de la Solution

- **Système propre :** Aucun conflit entre écrans de verrouillage
- **Personnalisable :** Facile de changer d'image
- **Stable :** Configuration XFCE standard
- **Maintenable :** Facile à mettre à jour et modifier

### Prochaines Étapes

1. **Personnalisation supplémentaire :** Utilisez "Light Locker Settings" pour d'autres options
2. **Sauvegarde :** Sauvegardez la configuration pour de futures mises à jour
3. **Explorer :** Essayez d'autres images pour l'écran de verrouillage

---

## Ressources Supplémentaires

- [Documentation Officielle XFCE](https://docs.xfce.org/)
- [Communauté Linux Mint](https://forums.linuxmint.com/)
- [Light Locker GitHub](https://github.com/the-cavalry/light-locker)

---

*Guide créé pour résoudre les problèmes d'écran de verrouillage sur Linux Mint XFCE. Testé et fonctionnel !*

**Profitez de votre écran de verrouillage personnalisé ! 🔒✨**
