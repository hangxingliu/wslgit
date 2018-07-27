BEGIN {
	# if(length(mount_list) <= 0)
	#	exit 1;
	# print mount_list;
	split(mount_list, mount_array, "\n");
	replace_index = 1;
	for(key in mount_array) {
		split(mount_array[key], parts, "type drvfs");
		if(parts[1]) {
			part1 = parts[1];
			border = index(part1, "on");
			if(border > 1) {
				drive = substr(part1, 1, border - 1);
				mount_to = substr(part1, border + 3); # +3 => +2+1(1 more space character)

				gsub(/^\s/, "", drive);    gsub(/\s$/, "", drive);
				gsub(/^\s/, "", mount_to); gsub(/\s$/, "", mount_to);

				replace_from[replace_index] = mount_to;
				replace_to[replace_index++] = drive;
			}
		}
	}
}
{
	for(i = 1; i < replace_index ; i ++ )
		gsub(replace_from[i], replace_to[i]);
	print $0;
}
