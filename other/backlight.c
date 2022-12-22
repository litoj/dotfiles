#include <dirent.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Soure code for my backlight control program, rewritten from rust 'coz size too big
int main(int argc, char* argv[]) {
	DIR* d             = opendir("/sys/class/backlight/");
	struct dirent* dir = readdir(d);
	while (dir && dir->d_type != DT_LNK) dir = readdir(d);
	closedir(d);
	if (!dir) return EXIT_FAILURE;
	char str[55];
	int dirEnd = 20;
	strcpy(str, "/sys/class/backlight/");
	strcat(str, dir->d_name);
	while (str[dirEnd]) dirEnd++;
	str[dirEnd++] = '/';

	str[dirEnd]   = 0;
	strcat(str + dirEnd, "max_brightness");
	FILE* file = fopen(str, "r");
	if (!file) return EXIT_FAILURE;
	int max = 0;
	for (char c; (c = fgetc(file)) > 47;) max = (max * 10) + c - 48;
	fclose(file);

	str[dirEnd] = 0;
	strcat(str + dirEnd, "brightness");
	if (!(file = fopen(str, "r+"))) {
		printf("Please do sudo chown root:root ./backlight && sudo chmod +s ./backlight");
		return EXIT_FAILURE;
	}
	int now = 0;
	for (char c; (c = fgetc(file)) > 47;) now = (now * 10) + c - 48;
	if (argc > 1) {
		if (argv[1][0] == 'v') {
			if (now < 3) now = 0;
			else now = now * 2 / 3 - 1;
		} else if (argv[1][0] == '^') now = now * 3 / 2 + 3;
		else if (argc < 3) {
			fclose(file);
			return EXIT_FAILURE;
		} else {
			int val = atoi(argv[2]) * max / 100;
			if (argv[1][0] == '-') now = now >= val ? now - val : 0;
			else if (argv[1][0] == '+') now += val;
			else if (argv[1][0] == '=') now = val;
			else {
				printf("usage: backlight [v^][[+-=] int]\n");
				return EXIT_FAILURE;
			}
		}
		if (now > max) now = max;

		sprintf(str, "%d", now);
		for (int i = 0; str[i]; i++) fputc(str[i], file);
	}
	fclose(file);
	printf("%d\n", now * 100 / max);

	return EXIT_SUCCESS;
}
