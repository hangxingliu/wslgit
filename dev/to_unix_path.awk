{
	is_win_path = index($0, ":\\");
	if(is_win_path != 2) {
		print $0;
		exit;
	}

	part1 = "/mnt/" tolower(substr($0, 1, 1));
	part2 = substr($0, 3);
	
	gsub(/\\/, "/", part2);
	gsub("//", "/", part2);

	print part1 part2;
	exit;
}
