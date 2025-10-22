# 🔒 Guía Completa: Personalizar el Fondo de Pantalla de Bloqueo en Linux Mint XFCE

*Cómo resolver conflictos de pantalla de bloqueo y configurar tu imagen personalizada*

---

## Tabla de Contenidos

1. [El Problema](#el-problema)
2. [Solución Paso a Paso](#solución-paso-a-paso)
3. [Configuración Final](#configuración-final)
4. [Solución de Problemas](#solución-de-problemas)
5. [Script Automático](#script-automático)
6. [Conclusiones](#conclusiones)

---

## El Problema

En Linux Mint XFCE, es común tener **conflictos entre múltiples pantallas de bloqueo** que causan:
- Fondos negros
- Pantallas de bloqueo duplicadas
- Imposibilidad de personalizar el fondo
- Errores de servicio

**Síntomas típicos:**
```
GDBus.Error:org.freedesktop.DBus.Error.ServiceUnknown: 
The name org.freedesktop.ScreenSaver was not provided by any .service files
```

---

## Solución Paso a Paso

### Paso 1: Limpieza Completa del Sistema

Primero, eliminemos todas las pantallas de bloqueo existentes y sus archivos de configuración:

```bash
# Eliminar todos los paquetes de pantalla de bloqueo
sudo apt remove --purge light-locker light-locker-settings xfce4-screensaver xscreensaver cinnamon-screensaver mate-screensaver -y

# Eliminar archivos de configuración residuales
sudo find /etc -name "*screensaver*" -o -name "*light-locker*" 2>/dev/null | xargs sudo rm -f
sudo find /usr -name "*screensaver*" -o -name "*light-locker*" 2>/dev/null | xargs sudo rm -f
rm -rf ~/.config/autostart/*screensaver* ~/.config/autostart/*light-locker*
```

### Paso 2: Reinstalación Limpia

Reinstalemos solo los componentes necesarios:

```bash
# Actualizar repositorios
sudo apt update

# Instalar light-locker y gnome-screensaver (requerido para el servicio)
sudo apt install light-locker light-locker-settings gnome-screensaver -y
```

### Paso 3: Preparación de la Imagen

Copia tu imagen preferida a una ubicación accesible del sistema:

```bash
# Encontrar tu imagen
find /home/$USER -name "*wallpaper*" -o -name "*pxfuel*" 2>/dev/null

# Copiar imagen al sistema (reemplazar con la ruta de tu imagen)
sudo cp "/home/$USER/Pictures/wallpaperflare.com_wallpaper (1).jpg" /usr/share/backgrounds/lockscreen.jpg
sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg
```

### Paso 4: Configuración de XFCE

Configura XFCE para usar light-locker:

```bash
# Crear configuración de XFCE
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

### Paso 5: Configuración del Fondo

Establece tu imagen como fondo de la pantalla de bloqueo:

```bash
# Configurar gsettings para usar tu imagen
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
gsettings set org.gnome.desktop.screensaver picture-options "scaled"
```

### Paso 6: Prueba

Prueba el sistema:

```bash
# Probar la pantalla de bloqueo
light-locker-command -l
```

---

## Configuración Final

### Estructura de Archivos

```
/usr/share/backgrounds/
├── lockscreen.jpg          # Tu imagen principal
└── lockscreen-alt.jpg      # Imagen alternativa (opcional)

~/.config/xfce4/xfconf/xfce-perchannel-xml/
└── xfce4-session.xml       # Configuración de XFCE
```

### Comandos Útiles

```bash
# Bloquear pantalla manualmente
light-locker-command -l

# Cambiar imagen (reemplazar con ruta de nueva imagen)
sudo cp "/ruta/a/nueva/imagen.jpg" /usr/share/backgrounds/lockscreen.jpg
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"

# Verificar estado de la pantalla de bloqueo
ps aux | grep light-locker
```

---

## Script Automático

Para automatizar el proceso, usa el script incluido `set-lockscreen-es.sh`:

```bash
# Hacer el script ejecutable
chmod +x set-lockscreen-es.sh

# Ejecutar el script
./set-lockscreen-es.sh
```

El script:
- Encuentra automáticamente las imágenes en la misma carpeta
- Te permite elegir entre las imágenes disponibles
- Configura automáticamente la pantalla de bloqueo
- Maneja permisos y configuraciones

---

## Solución de Problemas

### Problema: Error "ServiceUnknown"

**Causa:** Falta el servicio gnome-screensaver

**Solución:**
```bash
sudo apt install gnome-screensaver -y
```

### Problema: Fondo Negro

**Causa:** Imagen no accesible o permisos incorrectos

**Solución:**
```bash
# Verificar que la imagen existe
ls -la /usr/share/backgrounds/lockscreen.jpg

# Corregir permisos
sudo chmod 644 /usr/share/backgrounds/lockscreen.jpg

# Restablecer gsettings
gsettings set org.gnome.desktop.screensaver picture-uri "file:///usr/share/backgrounds/lockscreen.jpg"
```

### Problema: Pantallas de Bloqueo Duplicadas

**Causa:** Archivos de configuración residuales

**Solución:**
```bash
# Eliminar todos los archivos de autostart
rm -f ~/.config/autostart/*lock* ~/.config/autostart/*screensaver*

# Reiniciar sesión
sudo reboot
```

---

## Conclusiones

Con esta guía has:

- **Resuelto** conflictos de pantalla de bloqueo
- **Configurado** light-locker como sistema principal
- **Establecido** tu imagen personalizada
- **Creado** un sistema estable y funcional

### Beneficios de la Solución

- **Sistema limpio:** Sin conflictos entre pantallas de bloqueo
- **Personalizable:** Fácil cambiar la imagen
- **Estable:** Configuración estándar de XFCE
- **Mantenible:** Fácil de actualizar y modificar

### Próximos Pasos

1. **Personalización adicional:** Usa "Light Locker Settings" para otras opciones
2. **Respaldo:** Guarda la configuración para futuras actualizaciones
3. **Explorar:** Prueba otras imágenes para la pantalla de bloqueo

---

## Recursos Adicionales

- [Documentación Oficial de XFCE](https://docs.xfce.org/)
- [Comunidad de Linux Mint](https://forums.linuxmint.com/)
- [Light Locker GitHub](https://github.com/the-cavalry/light-locker)

---

*Guía creada para resolver problemas de pantalla de bloqueo en Linux Mint XFCE. ¡Probada y funcional!*

**¡Disfruta de tu pantalla de bloqueo personalizada! 🔒✨**
