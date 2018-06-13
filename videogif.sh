#!/bin/bash

set -e;

print_help() {
    >&2 echo "Usage: $(basename "${0}") <source> <destination> [width] [framerate]";
    >&2 echo;
    >&2 echo "Examples:";
    >&2 echo;
    >&2 echo "# same size and FPS as the source video:";
    >&2 echo "  videogif.sh kitten.mp4 kitten.gif";
    >&2 echo;
    >&2 echo "# 240px width, same FPS as the source video:";
    >&2 echo "  videogif.sh kitten.mp4 kitten.gif 240";
    >&2 echo;
    >&2 echo "# 240px width, 15 FPS:";
    >&2 echo "  videogif.sh kitten.mp4 kitten.gif 240 15";
    >&2 echo;
    >&2 echo "# output to stdout for use with additional tools:";
    >&2 echo "  videogif kitten.mp4 /dev/stdout | gifsicle -O9 -o kitten.gif";
    >&2 echo;
    >&2 echo "Supported formats: anything readable by FFmpeg (see 'ffmpeg -formats', 'D' column).";
}

if [ "${1}" = "-h" ] || [ "${1}" = "--help" ]; then
    print_help;
    exit 0;
fi

if [ "${#}" -lt 2 ] || [ "${#}" -gt 4 ]; then
    print_help;
    exit 1;
fi

if [ "${#}" -gt 2 ] && ! [ "${3}" -eq "${3}" ] 2>/dev/null; then
    >&2 echo "Width must be an integer."
    >&2 echo;
    print_help;
    exit 1;
fi

if [ "${#}" -gt 3 ] && ! [ "${4}" -eq "${4}" ] 2>/dev/null; then
    >&2 echo "Framerate must be an integer."
    >&2 echo;
    print_help;
    exit 1;
fi

FFMPEG_BIN=$(command -v ffmpeg)
FFPROBE_BIN=$(command -v ffprobe)
FFPROBE_OPTS="-v error -select_streams v:0 -of default=noprint_wrappers=1:nokey=1 -show_entries stream="

if [ "${#}" -lt 3 ]; then
    >&2 echo -n "No width specified, using video width: ";
    WIDTH=$(${FFPROBE_BIN} ${FFPROBE_OPTS}width "${1}");
    >&2 echo "${WIDTH}";
else
    WIDTH=${3}
fi

if [ "${#}" -lt 4 ]; then
    >&2 echo -n "No framerate specified, using video FPS: ";
    FPS=$(${FFPROBE_BIN} ${FFPROBE_OPTS}r_frame_rate "${1}");
    >&2 echo "${FPS}";
else
    FPS=${4}
fi

PALETTE=$(mktemp -t videogif-palette-XXXXXX.png);
FILTERS="fps=${FPS},scale=${WIDTH}:-1:flags=bicubic";

${FFMPEG_BIN} -v warning -i "${1}" -vf "${FILTERS},palettegen" -threads 0 -y "${PALETTE}";
${FFMPEG_BIN} -v warning -i "${1}" -i "${PALETTE}" -lavfi "${FILTERS} [x]; [x][1:v] paletteuse" -threads 0 -f gif -y "${2}";

rm "${PALETTE}";
