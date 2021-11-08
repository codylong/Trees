N = 4
r3=sqrt(3)
v=[[0,1],[-r3/2,-1/2],[r3/2,-1/2]]

def convertPt(p):
    return [p[0]*v[0][0]+p[1]*v[1][0]+p[2]*v[2][0],p[0]*v[0][1]+p[1]*v[1][1]+p[2]*v[2][1]]

def numTriangs(pts):
    vpts = [convertPt(p) for p in pts]
    print vpts
    pc = PointConfiguration(vpts)
    pc.restrict_to_fine_triangulations()
    return len(pc.triangulations())

posspts = []
for i in range(1,N+1):
    for j in range(1,N+1):
        for k in range(1,N+1):
            if i + j + k <= N: posspts.append([i,j,k])
