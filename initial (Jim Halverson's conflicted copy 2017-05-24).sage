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
palppolys=PALPreader(3)    #read KS 3-folds
polys=[p for p in palppolys]
f = 0
sum = 0
sum2 = 0
mydict = []
maxE = 1
maxF = 1
maxcont = 1
maxi = -1
ests = []
for p in polys:
    count +=1
    s = str(count)+" "+ str(datetime.datetime.now())
    #print s
    est=1
    est2=1
    for facet in p.faces(2):
        f = facet.as_polyhedron()
        nI = numFacetInteriorPoints(f)
        nB = len(f.integral_points()) - nI
        E = 2*nB + 3*nI - 3
        if E > maxE: maxE = E
        F = nB + 2*nI - 2
        if F > maxF: maxF = F
        if count==8:
            print E,F
        #mydict.append(N(log(1000000^F*82^E,10)))       
        est = est*41439964^F*82^E
        #est = est*1405^F*82^E
        #est2 = est2 * factorial(E)
    for edge in p.faces(1):
        overcount = 82^(len(edge.as_polyhedron().integral_points())-1)
        est = est / overcount
    if est > maxcont:
        maxcont=est
        maxi = count
    #print est

    sum += est
    ests.append(N(log(int(est),10)))
    if N(log(int(est),10))>700:
        print N(log(int(est),10)), N(log(int(sum),10)), maxF, maxE
        print est
        print est/3
    #sum2 += est2
    

# There are E 11 edges
# There are E! choices for the order of blowing up these

# Each E-Bl sends E -> E + 2. After doing all 11 E-bl
                                              # Have 2E edges. None have a 3, so I can at least blow up those 
