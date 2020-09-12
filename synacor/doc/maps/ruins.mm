graph TD
A[Ruins]-->|north|B
B-->|south|A
B[Ruins foyer=red]-->|north|C
C-->|south|B
C[Ruins hall]-->|west|D
D-->|east|C
D[Ruins dining=concave]-->|down|E
E[Ruins kitchen=corroded]-->|up|D
C-->|east|F
F-->|west|C
F[Ruins living=blue]-->|up|G
G[Ruins throne=shiny]-->|down|F
C-->|north|H
H-->|south|C
H[Ruins teleport]-->|teleport|I
I[see Island map]
