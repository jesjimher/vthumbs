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

    # Averiguar si es entrelazado o no
    scantype=`mediainfo "$fichero" | grep -i "scan type" | cut -d: -f2 | sed 's/ //g'`
    entrelazado=
    if [ $scantype = "Interlaced" ]; then
		echo "  Detectado vídeo entrelazado, desentrelazando..."
        entrelazado=1
    fi

    # Calcular los fps a capturar para obtener 9 frames distribuidos equitativamente por el vídeo
    fps=$(echo "scale=4;8/$duracion" | bc)
	
	# Si ya existe el fichero, saltar
	fsalida="${fichero%.*}_thumb.jpg"
	if test -f "$fsalida"; then
		echo "  El fichero ya tiene previsualización, saltando al siguiente..."
		continue
	fi

    # Extraer fotogramas según los fps calculados, escalando a 320xloquesea:
    echo "  Extrayendo fotogramas cada $(echo "scale=2;1/$fps" | bc) segundos..."
    filtro=
    if [ $entrelazado ]; then
        filtro="yadif=1,"
    fi
    filtro="$filtro"scale=320:-1
    if avconv -v quiet -i "$fichero" -bt 20M -vsync 1 -r $fps -an -y -filter "$filtro" $dtemp/'cap%03d.jpg'; then
    	# Montar la imagen con las capturas
		echo "  Generando mosaico..."
		montage $dtemp/cap00[1-9].jpg -mode Concatenate -geometry +5+5 -shadow -tile 3x3 -quality 75 -title "$fichero ($durlegible)" "$fsalida"
    else
		echo "*** ERROR PROCESANDO $fichero"
    fi

    # Eliminar temporales
    rm "$dtemp"/*
done

rm -rf "$dtemp"

echo
echo "Listo"
