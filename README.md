# mpv-color
Advanced color settings for MPV: brightness, contrast, gamma for separate R G B channels and for all channels at once; saturation for all channels at once.

## Installation

Put the lines from `fragment-of-input.conf` in your `input.conf`. Put `color.lua` under `scripts/color.lua`. Restart `mpv`.


## Usage


### Select mode

- F9: adjust all channels
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


## Bugs

Report any bugs in this repo.
