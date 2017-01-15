# name: set_custom_icons.sh
# author: scott moore
# description:
#	set custom icons to the following custom folders.

set_custom_icon() {
	gvfs-set-attribute "$1" metadata::custom-icon-name "$2"
}

remove_custom_icon() {
	gvfs-set-attribute "$1" metadata::custom-icon-name -t unset
}

# NOTE: currently nautilus does not display emblems with custom icons.
# 	in order to be be consistant, every folder is set to a custom icon.
# NOTE: both design, scripts do not have custom icons.

set_custom_icon "$HOME/code" 'folder-git'
set_custom_icon "$HOME/design" 'folder'
set_custom_icon "$HOME/documents" 'folder-documents'
set_custom_icon "$HOME/downloads" 'folder-download'
set_custom_icon "$HOME/google" 'folder-gdrive'
set_custom_icon "$HOME/music" 'folder-music'
set_custom_icon "$HOME/pictures" 'folder-pictures'
set_custom_icon "$HOME/scripts" 'folder'
set_custom_icon "$HOME/temp" 'folder-recent'
