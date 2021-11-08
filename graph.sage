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

count = 0
from sage.geometry.polyhedron.palp_database import PALPreader
polys=PALPreader(3)    #read KS 3-folds
ksmat = []
f = 0
sum = 0
mydict = []
for p in polys:
    count +=1
    s = str(count)+" "+ str(datetime.datetime.now())
    print s
    est=1
    for facet in p.faces(2):
        f = facet.as_polyhedron()
        nI = numFacetInteriorPoints(f)
        nB = len(f.integral_points()) - nI
        E = 2*nB + 3*nI - 3
        F = nB + 2*nI - 2
        mydict.append(N(log(E^8*F^4,10)))
        #if str(E^8*F^4,10) not in mydict.keys():
        
        est = est*E^8*F^4
    print est
    sum += est
