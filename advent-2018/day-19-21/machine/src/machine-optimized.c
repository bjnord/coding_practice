#include <stdio.h>
#include <stdlib.h>
#define NREG 6
void main(argc, argv) {
unsigned int r[NREG], di;
for (di = 0; di < NREG; di++) r[di] = 0;


/* DECOMPILED PROGRAM: (r[2] bound to IP) */
	goto label17;
label1:
	r[1] = 0x000001;
label2:
	r[3] = 0x000001;
label3:
	r[4] = r[1] * r[3];
	r[4] = (r[4] == r[5]) ? 1 : 0;
	if (r[4] == 1) goto label7;
	goto label8;
label7:
	r[0] = r[1] + r[0];
label8:
	r[3] = r[3] + 0x000001;
	r[4] = (r[3] > r[5]) ? 1 : 0;
	if (r[4] == 1) goto label12;
	goto label3;
label12:
	r[1] = r[1] + 0x000001;
	r[4] = (r[1] > r[5]) ? 1 : 0;
	if (r[4] == 1) goto label16;
	goto label2;
label16:
	r[2] = 16; r[2] = r[2] * r[2]; goto skipper; /* JUMP to r[2] * r[2] + 1 */
label17:
	r[5] = r[5] + 0x000002;
	r[5] = r[5] * r[5];
	r[2] = 19; r[5] = r[2] * r[5]; /* read r[2] */
	r[5] = r[5] * 0x00000B;
	r[4] = r[4] + 0x000005;
	r[2] = 22; r[4] = r[4] * r[2]; /* read r[2] */
	r[4] = r[4] + 0x000009;
	r[5] = r[5] + r[4];
	r[2] = 25; r[2] = r[2] + r[0]; goto skipper; /* JUMP to r[2] + r[0] + 1 */
label26:
	goto label1;
	r[2] = 27; r[4] = r[2]; /* read r[2] */
	r[2] = 28; r[4] = r[4] * r[2]; /* read r[2] */
	r[2] = 29; r[4] = r[2] + r[4]; /* read r[2] */
	r[2] = 30; r[4] = r[2] * r[4]; /* read r[2] */
	r[4] = r[4] * 0x00000E;
	r[2] = 32; r[4] = r[4] * r[2]; /* read r[2] */
	r[5] = r[5] + r[4];
	r[0] = 0x000000;
	goto label1;
label36:
	r[2] = 36; goto end; /* HALT (set bound reg) */

skipper:
	if (r[2] == 25) {
		goto label26;
	} else if (r[2] > 36) {
		goto end;
	}
	printf("unsupported JUMP to %d + 1\n", r[2]);
	exit(1);

end:
for (di = 0; di < NREG; di++)
printf("R%d=x%06X ", di, r[di]);
printf("\n");
exit(0);
}
