#include <stdio.h>
#include <string.h>
#include <stdlib.h>
int main () {
	FILE *text = fopen("code.txt", "r");
	FILE *ktext = fopen("handler.txt", "r");
	FILE *code = fopen("code.coe", "w");
	char *buff;
	int ret;
	buff = (char *) malloc (sizeof (char) * 128);
	int text_line_cnt = 0;
	int i;
	fputs("memory_initialization_radix=16;\n", code);
	fputs("memory_initialization_vector=\n", code);
	for (i=0; i<1120; i++) {
		ret = fread(buff, 1, 9, text);
		if (ret != 0 && buff[0] != 0) {
			fwrite(buff, ret-1, 1, code);
			fputs(",\n", code);
		}
		else
			fputs("00000000,\n", code);
	}
	fclose(text);
	while (1) {
		ret = fread(buff, 1, 9, ktext);
		if (ret != 0 && buff[0] != 0) {
			fwrite(buff, ret-1, 1, code);
			fputs(",\n", code);
		}
		else break;
	}
	fclose(ktext);
	fseek(code, -3L, SEEK_CUR);
	fputc(';', code);
	fclose(code);
	return 0;
}