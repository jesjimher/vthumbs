#!/bin/bash

# Generate an image mosaic from video frames
# Requires mediainfo, avconv and Imagemagick suite

if [ $# -lt 1 ]; then
    echo "Use: vthumb.sh <video file(s)>"
    exit 1
fi

# Check for dependencies
if ! type mediainfo > /dev/null 2>&1; then
    mensaje "Comando mediainfo no encontrado. "
    exit 1
fi
if ! type avconv > /dev/null 2>&1; then
    mensaje "Comando avconv no encontrado. "
    exit 1
fi
if ! type montage > /dev/null 2>&1; then
    mensaje "Comando montage no encontrado. "
    exit 1
fi

dtemp=`mktemp -d`
for fichero in "$@"; do
    # Obtener duración en segundos
    duracion=$(mediainfo --Inform="Video;%Duration%" "$fichero")
    let duracion=duracion/1000
    durlegible=$(date -u -d @$duracion +"%_Hh%_Mm %_Ss")

    echo "Procesando $fichero, $durlegible"

    # Calcular los fps a capturar para obtener 9 frames distribuidos equitativamente por el vídeo
    fps=$(echo "scale=4;8/$duracion" | bc)

    # Extraer fotogramas según los fps calculados, escalando a 320xloquesea:
    echo "  Extrayendo fotogramas cada $(echo "scale=2;1/$fps" | bc) segundos..."
    avconv -v quiet -i "$fichero" -vsync 1 -r $fps -an -y -filter scale=320:-1 $dtemp/'cap%03d.jpg'

    # Montar la imagen con las capturas
    echo "  Generando mosaico..."
    fsalida="${fichero%.*}_thumb.jpg"
    montage $dtemp/cap00[1-9].jpg -mode Concatenate -geometry +5+5 -shadow -tile 3x3 -quality 75 -title "$fichero ($durlegible)" "$fsalida"

    # Eliminar temporales
    rm "$dtemp"/*
done

rm -rf "$dtemp"

echo
echo "Listo"
