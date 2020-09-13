graph TD
A[Beach]-->|east|B
B-->|west|A
B[East Beach]-->|north|C
C-->|south|B
C[Excited pool]-->|west|D
C-->|north|F
D-->|east|C
D[Bird chirp]-->|south|A
A-->|north|D
A-->|west|E
E[West Beach]-->|north|D
E-->|east|A
D-->|north|F
F-->|south|D
F[Rock faces]-->|north|G
G-->|south|F
G[Narrow path]-->|north|H
H-->|south|G
H[Narrow slope]-->|north|I
I-->|south|H
I[Cave entrance]-->|north|J
J-->|south|I
J[Tropical cave]-->|north|K
K-->|south|J
K[Tropical cave 2]-->|east|L
L[Alcove=journal]-->|west|K
K-->|north|M
M[Cave slope]-->|north|N
M-->|south|K
N[Vault Antechamber]-->|via grid|V
N-->|south|M
V[Vault Door]-->|via grid|N
V-->|vault|W
W[Vault=mirror]-->|leave|V
