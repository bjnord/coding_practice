#include <stdio.h>
#include <stdlib.h>

#define NREG 6

void main(argc, argv)
{
	unsigned int r[NREG], di;
	for (di = 0; di < NREG; di++)
		r[di] = 0;
	r[0] = 0xB3B61C;  /* initial R0 - upper bound */

	/* DECOMPILED PROGRAM: (r[4] bound to IP) */

	/* this just tests AND logic; should break first time and fall thru */
	r[5] = 0x00007B;
	while (1) {
		r[5] = r[5] & 0x0001C8;
		r[5] = (r[5] == 0x000048) ? 1 : 0;
		if (r[5] == 1) break;
	}

	/* here begins the real program: */

	r[5] = 0x000000;
top:
	r[3] = r[5] | 0x010000;
	r[5] = 0xA53AF2;

bigloop:
	r[2] = r[3] & 0x0000FF;
	r[5] = r[5] + r[2];
	r[5] = r[5] & 0xFFFFFF;
	r[5] = r[5] * 0x01016B;
	r[5] = r[5] & 0xFFFFFF;
	r[2] = (0x000100 > r[3]) ? 1 : 0;
	if (r[2] == 1) {
		goto compare_r5_r0;
	}

	/* original (looped):
	r[2] = 0x000000;
	while (1) {
		r[1] = r[2] + 0x000001;
		r[1] = r[1] * 0x000100;
		r[1] = (r[1] > r[3]) ? 1 : 0;
		if (r[1] == 1) break;
		r[2] = r[2] + 0x000001;
	}
	*/
        /* one step (optimized): */
	r[2] = (((r[3] & 0xFFFF00) + 0x100) >> 8) - 0x1;
	r[1] = 1;

	r[3] = r[2];
	goto bigloop;

compare_r5_r0:
	r[2] = (r[5] == r[0]) ? 1 : 0;
	if (r[2] == 1) goto end;

	/* fprintf(stderr, "r[5]=0x%06X\n", r[5]); */
	goto top;

end:
	r[4] = 31; /* HALT (set bound reg) */

	for (di = 0; di < NREG; di++)
		printf("R%d=x%06X ", di, r[di]);
	printf("\n");
	exit(0);
}
