import re
from operator import itemgetter
import itertools
from heapq import heappush, heappop

fn = "../teleport/input/input.txt"


def intersects(cube, nano):
    """cube: ((min_x, min_y, min_z), (max_x, max_y, max_z))
    nano: ((x, y, z), range)

    """
    verts = set()
    (x, y, z), r = nano
    (min_x, min_y, min_z), (max_x, max_y, max_z) = cube
    if min_x <= x <= max_x \
       and min_y <= y <= max_y \
       and min_z <= z <= max_z:
        return True

    for new_x in [x - r, x + r]:
        verts.add((new_x, y, z))
    for new_y in [y - r, y + r]:
        verts.add((x, new_y, z))
    for new_z in [z - r, z + r]:
        verts.add((x, y, new_z))

    for (x, y, z) in verts:
        if min_x <= x <= max_x \
           and min_y <= y <= max_y \
           and min_z <= z <= max_z:
            return True

    corners = itertools.product((min_x, max_x), (min_y, max_y), (min_z, max_z))
    for c in corners:
        if dist(c, nano[0]) <= nano[1]:
            return True

    return False


def dist(a, b):
    return abs(a[0] - b[0]) + abs(a[1] - b[1]) + abs(a[2] - b[2])


with open(fn) as f:
    raw_data = f.read().strip().splitlines()

nanos = {}

for l in raw_data:
    (x, y, z, r) = [int(i) for i in re.findall(r'(-?\d+)', l)]
    nanos[(x, y, z)] = r

strongest = max(nanos.items(), key=itemgetter(1))

in_range = 0

for n in nanos.keys():
    if dist(n, strongest[0]) <= strongest[1]:
        in_range += 1

print('Nano count:', len(nanos))
print('strongest nano:', strongest)
print('Has', in_range, 'nanos in range')

mins = []
maxes = []
for d in range(3):
    mins.append(min([k[d] for k in nanos.keys()]))
    maxes.append(max([k[d] for k in nanos.keys()]))

# print(mins)
# print(maxes)

largest_axis_length = max([abs(maxes[d] - mins[d]) for d in range(3)])
print('Largest axis length:', largest_axis_length)
box_length = 1
while box_length < largest_axis_length:
    box_length *= 2

boxes = []
heappush(boxes, (0, box_length, 0, (tuple(mins))))

while boxes:
    ir, box_length, distance, (bx, by, bz) = heappop(boxes)
    if box_length == 1:
        print("Point:", (bx, by, bz))
        print("In range:", -ir)
        print("d from (0, 0, 0):", distance)
        break
    box_length //= 2
    offsets = [0, box_length]
    for sub_x, sub_y, sub_z in set(itertools.product(offsets, repeat=3)):
        box = ((bx + sub_x, by + sub_y, bz + sub_z),
               (bx + sub_x + box_length - 1, by + sub_y + box_length - 1,
                bz + sub_z + box_length - 1))
        in_range = 0
        for n in nanos.items():
            if intersects(box, n):
                in_range += 1
        distance = min((abs(box[0][0]), abs(box[1][0]))) + \
            min((abs(box[0][1]), abs(box[1][1]))) + \
            min((abs(box[0][2]), abs(box[1][2])))
        heappush(boxes, (-in_range, box_length, distance, box[0]))
