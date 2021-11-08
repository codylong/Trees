import cPickle as pickle
import datetime
#load("costlibrary.sage")

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

def triandtoric(pts):
	PointConfiguration.set_engine('topcom')
	LP = LatticePolytope(pts)
	facets = LP.facets_lp()
        pointlist = list(LP.points())
	ptlist = list([list(l) for l in LP.points()])
	ptlist = [l for l in ptlist if l != [0,0,0]]
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
        print index
#Since we removed the origin, we need to make sure the index of the facets are correct. This is a problem if the origin is not the last point in the list of points of the polytope
  	org = eval(str(pointlist).replace('M','')).index((0,0,0))
        print org
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
    	        if len(overlap) == 3:
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
    	fanrays = eval(str(pointlist).replace("M","").replace(", (0, 0, 0)",""))
    	fancones = eval(str(facetriang).replace("[","(").replace("]",")").replace("((","[(").replace("))",")]"))
    	fan = Fan(cones = fancones, rays = fanrays)
    	V = ToricVariety(fan)
    	return V

count = 0
from sage.geometry.polyhedron.palp_database import PALPreader
polys=PALPreader(3)    #read KS 3-folds


lI2, lI3ns, lI3s, lI4ns, lI4s, lI5ns, lI5s, lI1starns, lI1stars, lII, lIII, lIVns = [],[],[],[],[],[],[],[],[],[],[],[]
lIVs, lI0starns, lI0stars1, lI0stars2, lIVstarns, lIVstars, lIIIstar, lIIstar = [],[],[],[],[],[],[],[]

import datetime
for polynum in range(7,8): # hack range to focus on polytope number 7, "the big one", index from 0
    print polynum, datetime.datetime.now()
    curmat =  [list(k) for k in polys[polynum].integral_points()]
    curmat.remove([0,0,0])
    print curmat
    mat = matrix(curmat)
    tI2, tI3ns, tI3s, tI4ns, tI4s, tI5ns, tI5s, tI1starns, tI1stars, tII, tIII, tIVns = [],[],[],[],[],[],[],[],[],[],[],[]
    tIVs, tI0starns, tI0stars1, tI0stars2, tIVstarns, tIVstars, tIIIstar, tIIstar = [],[],[],[],[],[],[],[]
    for i in range(mat.nrows()):
        mk = [1 for k in range(mat.nrows())]
        m2k = [2 for k in range(mat.nrows())]
        m3k = [3 for k in range(mat.nrows())]
        m4k, m6k = [4 for k in range(mat.nrows())], [6 for k in range(mat.nrows())]
        a1secs = numsectionsi(mk,mat,i)
        a2secs = numsectionsi(m2k,mat,i)
        a3secs = numsectionsi(m3k,mat,i)
        fsecs = numsectionsi(m4k,mat,i)
        gsecs = numsectionsi(m6k,mat,i)
        tI2.append(fsecs[0]+gsecs[0]+gsecs[1]-a2secs[0])
        tIII.append(fsecs[0]+gsecs[0]+gsecs[1])
        tIVns.append(fsecs[0]+fsecs[1]+gsecs[0]+gsecs[1])
       
    lI2.append(tI2)
    lIII.append(tIII)
    lIVns.append(tIVns)
    V = triandtoric(polys[polynum].integral_points())
    print V.is_smooth()
    

alltunings = [lI2,lIII,lIVns]
pts = [list(k) for k in polys[7].integral_points() if tuple(k) != (0,0,0)]
