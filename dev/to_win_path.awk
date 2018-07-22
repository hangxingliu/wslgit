{
	print gensub(/\/mnt\/([A-Za-z])(\/\S*)/, "\\1:\\2", "g");
}
