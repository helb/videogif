# `videogif.sh`

> A simple shell script to convert videos to animated gifs with an optimized color palette (using [ffmpeg](http://ffmpeg.org/)).

## Usage examples

same size and FPS as the source video:

```bash
videogif.sh kitten.mp4 kitten.gif
```

240px width, same FPS as the source video:

```bash
videogif.sh kitten.mp4 kitten.gif 240
```

240px width, 15 FPS:

```bash
videogif.sh kitten.mp4 kitten.gif 240 15
```

output to stdout for use with additional tools:

```bash
videogif kitten.mp4 /dev/stdout | gifsicle -O9 -o kitten.gif
```
