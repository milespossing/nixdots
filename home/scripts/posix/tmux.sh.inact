tmux-fzf() {
	tmux ls | fzf
}
tmux-select() {
	fzf-tmux | cut -d : -f 1
}
tmux-attach() {
	tmux a -t $(select-tmux)
}
