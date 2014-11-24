vthumbs
=======

vthumbs is a small bash script that, given a video file, generates an image mosaic composed of selected thumbnails. This kind of mosaic is a quick way to check the contents of the video, without having to open the file, so it may be useful while browsing remote filesystems where video playing is not an option.

Right now, vthumbs generates a 3x3 mosaic of thumbnails. Thumbnails are distributed equally throughout the video, so they're separated roughly a 10% of video duration. The generated file is called with the same name as the video file, just adding _thumb at the end.

Execution is very simple. The only argument to the script is the video file:

`vthumbs.sh video.mp4`

Glob expansion is also supported:

`vthumbs.sh *.mp4`
