import cPickle as pickle
import datetime

def dot(v1,v2):
    c = 0
    for i in range(len(v1)): c += v1[i]*v2[i]
    return c

def vsum(v1,v2):
    return [v1[i]+v2[i] for i in range(len(v1))]

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

def fgslicecurve(fmons, gmons, v1ind, v2ind):
    newfs, newgs = [], []
    for f in fmons:
        if f[i]+f[j] - 4 >= 0:
            newfs.append(f)
    for g in gmons:
        if g[i] + g[j] - 6 >= 0:
            newgs.append(g)
    return [newfs,newgs]

count = 0
from sage.geometry.polyhedron.palp_database import PALPreader
polys=PALPreader(3)    #read KS 3-folds
ksmat = []
f = 0
sum = 0
for p in polys:
    count +=1
    mat = [list(k) for k in p.integral_points()]
    newmat = []
    for k in mat:
        if k != [0,0,0]: newmat.append(k)
    mat = newmat 
    if count % 100 == 0: print count
    s = str(count)+" "+str(len(mat))+" "+ str(datetime.datetime.now())
    #print s
    m4k = [4 for k in mat]
    m6k = [6 for k in mat]
    fs, gs = sections(m4k, mat), sections(m6k, mat)
    
    for facet in p.faces(2):
        #print "facet"
        facetP = facet.as_polyhedron()
        integralpoints = facetP.integral_points()
        integralpointsindices = [mat.index(list(i)) for i in integralpoints]
        interiors = facetInteriorPoints(facetP)
        interiorsindices = [mat.index(list(intpt)) for intpt in interiors]
        oov = 1
        for i in range(len(integralpointsindices)):
            for j in range(i+1,len(integralpointsindices)):
                for k in range(len(mat)):
                    fks = sectionsipasssecs(k, fs)
                    gks = sectionsipasssecs(k, gs)
                    singfibk = True
                    for f in fks[0]:
                        if f[integralpointsindices[i]]+f[integralpointsindices[j]]-4>=0:
                            singfibk = False
                            break
                    for g in gks[0]:
                        if g[integralpointsindices[i]]+g[integralpointsindices[j]]-6>=0:
                            singfibk = False
                            break
                    if k not in integralpointsindices and singfibk: 
                        print "Sing outside facet", integralpointsindices[i], integralpointsindices[j], fks[0]
                    #if k in integralpointsindices and singfibk: 
                    #    print "Sing inside facet", interiorsindices[i], interiorsindices[j], fks[0]
                        
