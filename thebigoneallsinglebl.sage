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
mat = matrix(pts)

possconesonf = []
for face in p.faces(2):
    faceip = [list(k) for k in face.as_polyhedron().integral_points()]
    possfacecones = []
    for i in range(len(faceip)):
        for j in range(i+1,len(faceip)):
            for k in range(j+1,len(faceip)):
                cone = [faceip[i],faceip[j],faceip[k]]
                m = matrix(cone)
                if m.determinant() == 1: possfacecones.append(cone)
    possconesonf.append(possfacecones)


blverts=[]
for fcones in possconesonf:
    for c in fcones:
        ve3 = pl(pl(c[0],c[1]),c[2])
        ve21 = pl(c[0],c[1])
        ve22 = pl(c[0],c[2])
        ve23 = pl(c[1],c[2])
        if ve3 not in blverts: blverts.append(ve3)
        if ve21 not in blverts: blverts.append(ve21)
        if ve22 not in blverts: blverts.append(ve22)
        if ve23 not in blverts: blverts.append(ve23)

mk = [1 for k in range(mat.nrows() + 1)] # +1 for sing bl, same below
m4k, m6k = [4 for k in range(mat.nrows() + 1)], [6 for k in range(mat.nrows() + 1)]
minfgs = []
for ve in blverts:
    nverts = pts[0:]
    nverts.append(ve)
    fsecs = sections(m4k,nverts)
    gsecs = sections(m6k,nverts)
    minfgthis = []
    for i in range(len(nverts)):
        minfgthis.append(minfg(i,fsecs,gsecs))
    minfgs.append(minfgthis)

groundallsame = [True for k in nverts]
for i in range(len(pts)):
    for m in minfgs:
        if minfgs[0][i] != m[i]: groundallsame[i] = False

for i in range(len(groundallsame)):
    if groundallsame[i]: print minfgs[0][i]
    # for i in range(mat.nrows()):
# mk = [1 for k in range(mat.nrows())]
# m4k, m6k = [4 for k in range(mat.nrows())], [6 for k in range(mat.nrows())]


# fsecs2 = sections([4,4,4,4],verts)
# gsecs2 = sections([6,6,6,6],verts)

# allevengsecs = []
# for g in gsecs:
#     if alleven(g):
#         allevengsecs.append(g)

# #####
# # Engineer some blowups consistent with the Ben bound
# #####
        
# v = verts[0:]
# for i in range(4):
#     for j in range(i+1,4):
#         for a in range(1,6):
#             for b in range(1,6):
#                 if a + b <= 6:
#                     v.append(pl(ti(a,v[i]),ti(b,v[j])))

# m4k, m6k = [4 for k in range(len(v))], [6 for k in range(len(v))]
# fsecs3 = sections(m4k,v)
# gsecs3 = sections(m6k,v)

# #####
# # Engineer some blowups consistent with the Ben bound
# #####

# v = verts[0:]
# for i in range(4):
#     for j in range(i+1,4):
#         for a in range(1,6):
#             for b in range(1,6):
#                 if a + b <= 6:
#                     v.append(pl(ti(a,v[i]),ti(b,v[j])))

# m4k, m6k = [4 for k in range(len(v))], [6 for k in range(len(v))]
# fsecs3 = sections(m4k,v)
# gsecs3 = sections(m6k,v)

# #for i in range(len(v)):
# #    print minfg(i,fsecs3, gsecs3)

# #####
# # Second engineered set
# #####

