# mpv-color
Advanced color settings for MPV: brightness, contrast, gamma for separate R G B channels and for all channels at once; saturation for all channels at once.


## Installation

Put the lines from `fragment-of-input.conf` in your `input.conf`. Put `color.lua` under `scripts/color.lua`. Restart `mpv`.


## Why use this?

A lot of movies and shows nowadays have terrible mastering, and are just straight up too dark, or have messed up colors. This is a quick way to fix them.


## Features

Allows adjusting brightness, contrast, gamma for R G and B channels separately, which is necessary for some badly mastered movies and shows.

Reloads the settings from mpv config if possible, so that you don't have to re-adjust everything when you reopen the file and want to make further adjustments.

The reloading will not work if you set the `vf` value yourself or modify it in some way compared to what this script is doing.


## Usage


### Select mode

- F9: adjust all channels (this is the default setting)
- F10: adjust red only
- F11: adjust green only
- F12: adjust blue only


### Adjust settings

The following adjustments apply to the channels selected with F9-F12
- F1/F2: lower/raise brightness
- F3/F4: lower/raise contrast
- F5/F6: lower/raise gamma

The following adjustment applies to all channels, no matter what mode is selected:
- F7/F8: lower/raise saturation


### Reset adjustments:

- Shift+F1: reset brightness (current channel selection)
- Shift+F3: reset contrast (current channel selection)
- Shift+F5: reset gamma (current channel selection)
- Shift+F7: reset saturation (all channels)
- Shift+F9: reset everything (all channels+per-channel)


### How to fix certain video issues

Recipes on how to fix common color problems with movies and tv shows:

- Everything is too dark: add brightness, then see if any other adjustments are needed
- Everything looks like a cartoon, people's faces are orange, or shadows are blue: lower saturation
- Things are the right brightness, but highlights are too bright: lower gamma
- Some things are the right brightness, but a lot of stuff is too dark: add brightness, then go to "Things are the right brightness, but highlights are too bright"
- Everything looks good, but the areas that should be black (or very dark gray) look blueish: play around with the blue settings (press F12). Try lowering blue brightness and add a little contrast.
- Everything looks fine, but the bars at the top and bottom of the video are not perfectly black on my OLED screen: this is normal. Most movies are shot and/or encoded with dynamic range that doesn't give you perfect black colors. This isn't a limitation of technology, it's just how the scene looks: a normal area, even a dark one in the night, still has some light shining into the shadows. This makes the shadows gray. Then, in video mastering (i.e. where they adjust the colors so they look good on the screen), some idiot adjusts that so the shadows are pitch black, i.e. unnatural. Then they encode it like that. Now, the black bars at the top and bottom of the screen are the same color as the shadows in the movie, so if you *raise the blacks* (i.e. make them brighter so they look how they should in real life), the black bars get raised too, and now they're just dark grey.
- Things look too purple: play around with red, green, and blue channels separately (F10, F11, F12). You want less red and blue and perhaps a tiny bit more green.
- Everything has a glare over it: try reducing brightness, or reducing gamma.

## Bugs

Report any bugs in this repo.
