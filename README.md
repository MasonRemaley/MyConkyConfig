# Conky Config

KDE plasma's hardware monitor shows the incorrect CPU usage, so I'm displaying this data with Conky for now. This is my current config.

# Setup

1. Add conky to nixos packages
2. Install these files at ~/.config/conky
3. KDE plasma doesn't sort the window correctly, fix it with a widnow rule:
  - Navigate to `System Settings > Apps & Windows > Window Management > Window Rules`
  - Click `Add New...`
	  - Description: Conky
	  - Window class: Exact match, Conky
	  - Match whole window class: No
	  - Window types: All selected
  - Click `Add Property...`
  	- Layer, Force, Notification
  - Click `Apply`
4. Set conky to run on start at `System Settings > System > Autostart`
  - You can also launch it via the command line with `conky` if you don't want to reboot
5. Adjust the positioning by editing the global vars in `conky.conf`
6. This isn't a real taskbar panel, so it's probably a good idea to add a spacer to the panel at this point so that other stuff in the taskbar doesn't overlap
7. Double check the indices passed to `hwmon` in `render.lua`, these may be hardware dependent. See the comment there for more info.

# To Do
- Show CPU speed so you can tell when you're getting throttled
- Fan speeds
- Network stats
