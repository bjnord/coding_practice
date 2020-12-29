#include <stdio.h>
#include <stdlib.h>

#define N_SIEVE 5000
char composite[N_SIEVE+1];

void sieve_of_eratosthenes() {
	int r1 = 2;
	int r4 = N_SIEVE;
soeA:
	if (composite[r1]) {
		goto soeC;
	}
	int r3 = r1;
soeB:
	r3 = r3 + r1;
	if (r3 > r4) {
		goto soeC;
	}
	composite[r3] = 1;
	goto soeB;
soeC:
	r1 = r1 + 1;
	if (r1 > r4) {
		goto soeD;
	}
	goto soeA;
soeD:
	printf("initialized composite table\n");
}

#define NREG 6
void main(int argc, char **argv) {
unsigned int r[NREG], di;
for (di = 0; di < NREG; di++) r[di] = 0;

	sieve_of_eratosthenes();
	if (argc > 1 && argv[1][0] == '2') {
		r[0] = 1;  /* part 2 */
	}

/* DECOMPILED PROGRAM: (r[2] bound to IP) */
	goto label17;

/*
 * This is the program; it accumulates into R0 the sum of all prime factors
 * of R5 (including 1 and R5).
 */
label1:
	r[1] = 0x000001;

/** FAST ********************************/
	if (argc > 2) {
		printf("using FAST\n");
		goto label36;
	} else {
		printf("using SLOW\n");
	}
/****************************************/

/** SLOW ********************************/
label2:
	r[3] = 0x000001;
label3:
	r[4] = r[1] * r[3];
	r[4] = (r[4] == r[5]) ? 1 : 0;
	if (r[4] == 1) goto label7;
	goto label8;
label7:
	printf("prime factor R1 = %d (x%06X)\n", r[1], r[1]);
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
/****************************************/

/*
 * This is the exit; it jumps to address 256 (beyond the end) which halts.
 */
label16:
	r[2] = 16; r[2] = r[2] * r[2]; goto skipper; /* JUMP to r[2] * r[2] + 1 */

/*
 * These are the initializers.
 * - part 1 (R0=0) will only do label17 yielding R5=955
 * - part 2 (R0=1) will do both label17 and label27 yielding R5=10551355
 * - either way, sets R0=0 and jumps back to label1 to start calculating
 */
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
	printf("initialized R5 to %d (x%06X)\n", r[5], r[5]);
	goto label1;
label27:
	r[2] = 27; r[4] = r[2]; /* read r[2] */
	r[2] = 28; r[4] = r[4] * r[2]; /* read r[2] */
	r[2] = 29; r[4] = r[2] + r[4]; /* read r[2] */
	r[2] = 30; r[4] = r[2] * r[4]; /* read r[2] */
	r[4] = r[4] * 0x00000E;
	r[2] = 32; r[4] = r[4] * r[2]; /* read r[2] */
	r[5] = r[5] + r[4];
	printf("initialized R5 to %d (x%06X)\n", r[5], r[5]);
	r[0] = 0x000000;
	goto label1;

/** FAST ********************************/
/* doesn't yield correct answer (10556089 is too low) */
label36:
	if (composite[r[1]]) {
		goto labelX1;
	}
	if (r[5] % r[1] != 0x000000) {
		goto labelX1;
	}
	printf("prime factor R1 = %d (x%06X)\n", r[1], r[1]);
	r[0] = r[1] + r[0];
labelX1:
	r[1] = r[1] + 0x000001;
	r[4] = (r[1] > r[5]) ? 1 : 0;
	if (r[4] == 1) goto labelX2;
	r[4] = (r[1] > N_SIEVE) ? 1 : 0;
	if (r[4] == 1) goto labelX2;
	goto label36;
labelX2:
	printf("prime factor R5 = %d (x%06X)\n", r[5], r[5]);
	r[0] = r[5] + r[0];
	goto label16;
/****************************************/

skipper:
	if (r[2] == 25) {
		goto label26;
	} else if (r[2] == 26) {
		goto label27;
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
