#!/bin/sh

ls ~/.config/wallpapers/hor | sort -R | tail -1 | cut -d " " -f 1 | while read file; do
	swww img ~/.config/wallpapers/hor/$file --transition-type center --transition-fps 60 -o DP-1
done

ls ~/.config/wallpapers/vert | sort -R | tail -1 | cut -d " " -f 1 | while read file; do
	swww img ~/.config/wallpapers/vert/$file --transition-type center --transition-fps 60 -o DP-2
done
