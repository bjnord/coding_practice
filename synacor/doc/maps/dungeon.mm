graph TD
A[Foothills=tablet]-->|south|B
B[Foothills 2]-->|north|A
A-->|doorway|C
C[Dark cave]-->|north|D
C-->|south|A
D-->|south|C
D[Dark cave 2]-->|north|E
E-->|south|D
E[Dark cave 3]-->|bridge|F
F-->|back|E
F[Rope bridge]-->|continue|G
G[Falling]-->|down|H
H[Moss cavern]-->|east|I
I[Lantern room]-->|west|H
H-->|west|J
J[Moss cavern 2]-->|passage|K
J-->|east|H
K[Passage]-->|cavern|J
K-->|ladder|L
L-->|ladder|K
L[see Maze map]
K-->|darkness|M
M[Passage 2]-->|back|K
M-->|continue|N
N-->|east|M
N[Dark passage]-->|west|O
O-->|east|N
O[Dark passage 2]-->|west|P
P-->|east|O
P[Dark passage 3]-->|west|Q
Q-->|east|P
Q[Dark passage 4]-->|west|R
R[see Ruins map]
R-->|east|Q
