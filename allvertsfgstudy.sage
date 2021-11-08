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

def triandtoric(pts):
	PointConfiguration.set_engine('topcom')
	LP = LatticePolytope(pts)
	facets = LP.facets_lp()
        pointlist = list(LP.points())
	ptlist = list([list(l) for l in LP.points()])
	ptlist = [l for l in ptlist if l != [0,0,0,0]]
	PC = PointConfiguration(ptlist).restrict_to_regular_triangulations().restrict_to_fine_triangulations()
	triang  = eval(str(PC.triangulate()).replace('<','[').replace('>',']'))
    	index = []
    	for facet in facets:
       		little = []
        	for point in facet.points():
        	    try:
        	        little.append(pointlist.index(point))
        	    except ValueError:
        	        pass
        	index.append(little)
        #print index
#Since we removed the origin, we need to make sure the index of the facets are correct. This is a problem if the origin is not the last point in the list of points of the polytope
  	org = eval(str(pointlist).replace('M','')).index((0,0,0,0))
        #print org
   	triang2 = []
   	for simp in triang:
            simp2 = []
   	    for pt in simp:
   	        if pt >= org:
   	            simp2.append(pt +1)
   	        else:
   	            simp2.append(pt)
   	    triang2.append(simp2)
   	triang = triang2
    	facetriang = []
    	for simplex in triang:
    	    for facet in index:
    	        overlap = [x for x in simplex if x in facet]
    	        if len(overlap) == 4:
    	            facetriang.append(overlap)
    	ftriang2 = []
    	for simp in facetriang:
    	    simp2 = []
    	    for pt in simp:
    	        if pt >= org:
    	            simp2.append(pt -1)
    	        else:
    	            simp2.append(pt)
    	    ftriang2.append(simp2)
    	facetriang = ftriang2
    	#Now we create the toric variety
    	fanrays = eval(str(pointlist).replace("M","").replace(", (0, 0, 0, 0)",""))
    	fancones = eval(str(facetriang).replace("[","(").replace("]",")").replace("((","[(").replace("))",")]"))
    	fan = Fan(cones = fancones, rays = fanrays)
    	V = ToricVariety(fan)
    	return V

count = -1
from sage.geometry.polyhedron.palp_database import PALPreader
polys=PALPreader(3)    #read KS 3-folds

import datetime
numsecs = []
for polynum in range(4319):
    count+=1
    #print polynum, datetime.datetime.now()
    pts =  [list(k) for k in polys[polynum].integral_points()]
    pts.remove([0,0,0])

    tv = triandtoric(pts) 
    mcones = tv.fan().cones(3)
    mconesvs = [[list(k) for k in c.rays()] for c in mcones]
    for c in mconesvs:
        for m in range(1,7):
            for n in range(1,7):
                for l in range(1,7):
                    if m + n + l <= 6:
                        pts.append(pl(ti(m,c[0]),pl(ti(n,c[1]),ti(l,c[2]))))

    twocones = tv.fan().cones(2)
    twoconesvs = [[list(k) for k in c.rays()] for c in twocones]
    for c in twoconesvs:
        for m in range(1,7):
            for n in range(1,7):
                if m + n <= 6:
                    pts.append(pl(ti(m,c[0]),ti(n,c[1])))

    m4k, m6k = [4 for k in range(len(pts))], [6 for k in range(len(pts))]
    fsecs = sections(m4k,pts)
    gsecs = sections(m6k,pts)
    print count, len(polys[polynum].integral_points()), (len(fsecs),len(gsecs))
    numsecs.append([len(fsecs),len(gsecs)])
    
    
