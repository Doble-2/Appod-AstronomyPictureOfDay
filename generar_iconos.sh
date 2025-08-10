#!/usr/bin/env bash
set -euo pipefail

# Uso: ./generar_iconos.sh [imagen_base]
# Si no pasas argumento usa assets/icon/splash.png

command -v ffmpeg >/dev/null 2>&1 || { echo "ffmpeg no encontrado. Instala con: sudo apt-get install -y ffmpeg"; exit 1; }

SRC="${1:-assets/icon/splash.png}"
OUT="web/icons"
SIZES=(48 72 96 128 144 152 180 192 256 384 512)
MASKABLE_SIZES=(192 512)
PADDING_PERCENT=80 # El contenido ocupa 80% del lado (resto = padding para maskable)

if [ ! -f "$SRC" ]; then
  echo "No existe el archivo base: $SRC" >&2
  exit 1
fi

mkdir -p "$OUT"

echo "Generando íconos estándar..."
for SZ in "${SIZES[@]}"; do
  ffmpeg -loglevel error -y -i "$SRC" \
    -vf "scale=${SZ}:-1:force_original_aspect_ratio=decrease,pad=${SZ}:${SZ}:(ow-iw)/2:(oh-ih)/2:color=0x00000000" \
    "$OUT/appod-${SZ}.png"
  echo "  appod-${SZ}.png listo"
done

echo "Generando íconos maskable (padding) ..."
for MSZ in "${MASKABLE_SIZES[@]}"; do
  INNER=$(( MSZ * PADDING_PERCENT / 100 ))
  ffmpeg -loglevel error -y -i "$SRC" \
    -vf "scale=${INNER}:-1:force_original_aspect_ratio=decrease,pad=${MSZ}:${MSZ}:(ow-iw)/2:(oh-ih)/2:color=0x00000000" \
    "$OUT/appod-maskable-${MSZ}.png"
  echo "  appod-maskable-${MSZ}.png listo"
done

# Favicon base (32x32 / 16x16)
for FAV in 16 32; do
  ffmpeg -loglevel error -y -i "$SRC" \
    -vf "scale=${FAV}:-1:force_original_aspect_ratio=decrease,pad=${FAV}:${FAV}:(ow-iw)/2:(oh-ih)/2:color=0x00000000" \
    "web/favicon-${FAV}.png"
  echo "  favicon-${FAV}.png listo"
done

echo "Iconos generados en $OUT (y favicons en web/)."
echo "Recuerda: limpia caché del navegador / PWA para ver el cambio." 