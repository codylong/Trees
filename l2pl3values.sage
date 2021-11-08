import cPickle as pickle
import datetime

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

def sectionsipasssecs(i,secs): # splits sections according to exponent of i'th homog coord
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

def facetInteriorPoints(facetP): #comes in as polyhedron object
    Interior = list(facetP.integral_points())
    for e in facetP.faces(1):
        eP = e.as_polyhedron()
        for e in list(eP.integral_points()):
            if e in Interior: Interior.remove(e)
    return Interior

def allFacetInteriorPoints(poly):
    facetinteriors = []
    for facet in poly.faces(2):
        facetP = facet.as_polyhedron()
        facetinteriors.extend(facetInteriorPoints(facetP))
    return facetinteriors

count = 0
from sage.geometry.polyhedron.palp_database import PALPreader
polys=PALPreader(3)    #read KS 3-folds
ksmat = []
f = 0
sum = 0
for p in polys:
    count +=1
    mat = list(p.integral_points())
    if count % 100 == 0: print count
    # s = str(count)+" "+str(len(mat))+" "+ str(datetime.datetime.now())
    # print s
    m4k = [4 for k in mat]
    m6k = [6 for k in mat]
    fs, gs = sections(m4k, mat), sections(m6k, mat)
    interiors = allFacetInteriorPoints(p)
    interiorsindices = [mat.index(intpt) for intpt in interiors]
    for intindex in interiorsindices:
        f0index = []
        for f in fs:
            if f[intindex] == 0: f0index.append(f)
        g0index = []
        for g in gs:
            if g[intindex] == 0: g0index.append(g)
        a = (len(f0index),len(g0index))
        if a != (1,1): print a
        if a == (1,1): print (f0index,g0index)
