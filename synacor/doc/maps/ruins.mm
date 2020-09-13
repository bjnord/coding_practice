graph TD
A[Ruins]-->|north|B
B-->|south|A
B[Ruins foyer=red]-->|north|C
C-->|south|B
C[Ruins hall]-->|east|D
D-->|west|C
D[Ruins dining=concave]-->|down|E
E[Ruins kitchen=corroded]-->|up|D
C-->|west|F
F-->|east|C
F[Ruins living=blue]-->|up|G
G[Ruins throne=shiny]-->|down|F
C-->|north|H
H-->|south|C
H[Mural room=teleporter]-->|teleport|I
I[see Island map]
