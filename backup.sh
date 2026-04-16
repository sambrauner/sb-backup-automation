#!/bin/bash

# Konfiguration
WORKDIR="/tmp/backup_work"
BACKUP_DIR="/backup"
DATE=$(date +%F)
ARCHIVE_NAME="backup_${DATE}.tar.gz"
LOG_FILE="/var/log/sb-backup-automation.log"

# Download-URLs der "wichtigen Projektdateien"
FILES=(
  "https://getsamplefiles.com/download/word/sample-1.doc"
  "https://getsamplefiles.com/download/word/sample-2.docx"
  "https://getsamplefiles.com/download/word/sample-3.docx"
  "https://getsamplefiles.com/download/word/sample-4.docx"
  "https://getsamplefiles.com/download/word/sample-5.docx"
)

# Bei einer API müsste stattdessen die API-URL initiert und ggf. der API-Token aus einer Umgebungsvariable geladen werden:
# API_URL="https://api.example.com/data"
# API_TOKEN="${API_TOKEN}"

# Logging Funktion
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

# Skript wird im Fehlerfall sofort beendet
# -> Eigentlich sollten Fehler in jedem Schritt abgefangen werden
set -e

log "Backup gestartet"

# Arbeitsverzeichnis anlegen falls noch nicht vorhanden
mkdir -p "$WORKDIR"
mkdir -p "$BACKUP_DIR/$DATE"

# Alte Daten löschen
[ -d "$WORKDIR" ] && rm -rf "$WORKDIR"/*

# Daten herunterladen
log "Starte Download"

for url in "${FILES[@]}"; do
    filename=$(basename "$url")
    log "Lade herunter: $filename"
    curl -f "$url" -o "$WORKDIR/$filename"
done

# Bei API stattdessen z.B.
# Get URLs über curl von der API -> Response in JSON speichern -> JSON parsen und Files wie hier über URLs downloaden

log "Download abgeschlossen"

# Komprimieren
log "Starte Komprimierung"
tar -czf "$WORKDIR/$ARCHIVE_NAME" -C "$WORKDIR" .
log "Komprimierung abgeschlossen"

# Verschieben ins Backup-Verzeichnis
log "Verschiebe Backup"
mv "$WORKDIR/$ARCHIVE_NAME" "$BACKUP_DIR/$DATE/"
log "Backup erfolgreich abgeschlossen: $BACKUP_DIR/$DATE/$ARCHIVE_NAME"

# Cleanup
[ -d "$WORKDIR" ] && rm -rf "$WORKDIR"/*
# Optional alle Archive älter als 90 Tage im backup direktory löschen 
find "$BACKUP_DIR" -type d -mtime +90 -exec rm -rf {} \;

exit 0