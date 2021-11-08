def multV(r,v):
    return [r*k for k in v]

def addV(v1,v2):
    return [v1[i]+v2[i] for i in range(len(v1))]

v1 = [1,0,1]
v2 = [0,1,1]
v3 = [-1,-1,1]

points = [v1,v2,v3]
lincombs = []
for i in range(1,7):
    for j in range(1,7):
        for k in range(1,7):
            if i + j + k <= 4: lincombs.append([i,j,k])
for lc in lincombs:
    new = addV(multV(lc[2],v3),addV(multV(lc[0],v1),multV(lc[1],v2)))
    if new not in points: points.append(new)
    
tree = PointConfiguration(points)
