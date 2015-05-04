##  Set of utilities to work with cases

### FEATURES
- Download all/separate attachments if using from CLI
- Show progress of downloading in wget's style
- Daemon to monitor "downloader.queue" folder and download attachments

### INSTALLATION
- aws with SSL support must be installed (Fedora's version is broken, WIP)
- gnatcoll must be installed (yum install gnatcoll-devel)
- RPM spec preparation is in progress

### CONFIGURATION
See casendra.conf.templ for more details. Config file (casendra.conf) should be placed either in ~/.config or
in current directory
