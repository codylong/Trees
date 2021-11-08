import cPickle as pickle
import datetime

def constructTVsFromMatrix(mat):
    print 'Point matrix', ksmat.index(mat), 'of', len(ksmat)
    matlist = list(mat)
    b3verts = [[0,0,0]]
    b3verts.extend(matlist)
    # print b3verts
    b3pc = PointConfiguration(b3verts,star=0)
    b3pc_fine = b3pc.restrict_to_fine_triangulations()
    b3triangs = list(b3pc_fine.triangulations())
    b3tvsinit = constructToricVarieties(b3triangs)
    b3tvs = []
    for tv in b3tvsinit:
        if tv.is_smooth():
            b3tvs.append(tv)
    for tv2 in b3tvs: computeDs(tv2)
    return b3tvs


def dot(v1,v2):
    c = 0
    for i in range(len(v1)): c += v1[i]*v2[i]
    return c


def numsections(ai,b3v):
    #print ai
    #print b3v
    eqs = []
    for i in range(len(ai)):
        p = b3v[i]
        eqs.append((ai[i],p[0],p[1],p[2]))
    poly = Polyhedron(ieqs=eqs)
    return len(poly.integral_points())
   
def numsectionsIrest(ai,b3v,Zind):
    eqs = []
    for i in range(len(ai)):
        if i != Zind:
            p = b3v[i]
            eqs.append((ai[i],p[0],p[1],p[2]))
    p = b3v[Zind]
    eqs.append((ai[Zind],p[0],p[1],p[2]))
    eqs.append((-ai[Zind],-p[0],-p[1],-p[2]))
    poly = Polyhedron(ieqs=eqs)
    return len(poly.integral_points())

def sections(ai,b3v):
    eqs = []
    for i in range(len(ai)):
        p = b3v[i]
        eqs.append((ai[i],p[0],p[1],p[2]))
    points = Polyhedron(ieqs=eqs).integral_points()
    secs = []
    for p in points:
        secs.append([dot(p,b3v[i])+ai[i] for i in range(len(ai))])
    
    return secs

def sectionsi(ai,b3v,i): # splits sections according to exponent of i'th homog coord
    secs = sections(ai,b3v)
    themax = 0
    for s in secs:
        if s[i] > themax: themax = s[i]
    secsi = [[] for k in range(themax+1)]
    for s in secs:
        secsi[s[i]].append(s)
    return secsi

def numsectionsi(ai,b3v,i): # splits sections according to exponent of i'th homog coord
    return [len(s) for s in sectionsi(ai,b3v,i)]

def numFacetInteriorPoints(facetP): #comes in as polyhedron object
    numInterior = len(facetP.integral_points())
    for e in facetP.faces(1):
        eP = e.as_polyhedron()
        numInterior = numInterior - len(eP.integral_points())
    numInterior += len(facetP.vertices())
    return numInterior

def alleven(sec):
    for k in sec:
        if k % 2 != 0: return False
    return True

def pl(v1,v2):
    return [v1[0]+v2[0],v1[1]+v2[1],v1[2]+v2[2]]

def ti(r,v1):
    return [r*k for k in v1]

def minfg(i,fsecs,gsecs):
    minf, ming = 10^6, 10^6
    for f in fsecs:
        if f[i] < minf: minf = f[i]
    for g in gsecs:
        if g[i] < ming: ming = g[i]
    return (minf, ming)

verts = [[-1,-1,-1],[-1,-1,5],[-1,5,-1],[1,-1,-1]]
p = Polyhedron(verts)
pts = [list(k) for k in p.integral_points()]
pts.remove([0,0,0])


p = LatticePolytope(verts)

bigface=p.faces_lp(2)[0]
bigfacees = bigface.faces_lp(1)
#pts.append([-2,-2,1]) # opposite edge blw to one below.
#pts.append([-2,-2,7]) # one edge blw
pts.append([-3,1,1]) # interior blw
#pts.append([-2,1,-2])
#pts.append([-2,1,7])
mat = matrix(pts)



#for i in range(mat.nrows()):
mk = [1 for k in range(mat.nrows())]
m4k, m6k = [4 for k in range(mat.nrows())], [6 for k in range(mat.nrows())]
fsecs = sections(m4k,pts)
gsecs = sections(m6k,pts)

edgepts = [list(k) for k in bigfacees[0].points()]
for pt in edgepts:
    for k in range(len(pts)):
        if pts[k] == pt:
            print minfg(k,fsecs,gsecs)
#fsecs2 = sections([4,4,4,4],verts)
#gsecs2 = sections([6,6,6,6],verts)

#allevengsecs = []
#for g in gsecs:
#    if alleven(g):
#        allevengsecs.append(g)
