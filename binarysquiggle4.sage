import datetime
import numpy as np

def bini(n,i):
	return (n >> i)%2

N = 6
vs = [(1,0,0),(0,1,0),(0,0,1)]
for a in range(1,7):
	for b in range(1,7):
		for c in range(1,7):
			if a + b + c <= N: vs.append((a,b,c))

if (2,2,2) in vs: vs.remove((2,2,2))

cones = []
for ai in range(len(vs)):
	for bi in range(ai,len(vs)):
		for ci in range(bi,len(vs)):
			a,b,c = vs[ai],vs[bi],vs[ci]
			res = -a[2]*b[1]*c[0] + a[1]*b[2]*c[0] + a[2]*b[0]*c[1] - a[0]*b[2]*c[1] - a[1]*b[0]*c[2] + a[0]*b[1]*c[2]
			if abs(res)== 1: cones.append((a,b,c))

allowededgebl = []
allowedfacebl = []

def blrelate(c1,c2): # does c1 bl to c2?
	for bl in bf:
		if c1-bl[0]==c2-bl[1]-bl[2]-bl[3]: return True
	for bl in be:
		if c1-bl[0]-bl[1]==c2-bl[2]-bl[3]-bl[4]-bl[5]: return True
	return False

def equals(c1,c2):
	if c2-c1==0: return True
	return False

def fbl(c1,bl):
	return c1-bl[0]+bl[1]+bl[2]+bl[3]

def ebl(c1,bl):
	return c1-bl[0]-bl[1]+bl[2]+bl[3]+bl[4]+bl[5]

def coneind(cur):
	for c in cones:
		if c[0] in cur and c[1] in cur and c[2] in cur:
			return cones.index(c)
	return -1

for c in cones:
 	if sum(c[0])+sum(c[1])+sum(c[2]) <= N: 
 		ve = (c[0][0]+c[1][0]+c[2][0],c[0][1]+c[1][1]+c[2][1],c[0][2]+c[1][2]+c[2][2])
 		cc1,cc2,cc3=(c[0],c[1],ve),(c[0],c[2],ve),(c[1],c[2],ve)
 		allowedfacebl.append((coneind(c),coneind(cc1),coneind(cc2),coneind(cc3)))

orig = [(1,0,0),(0,1,0),(0,0,1)]
for c1i in range(len(cones)):
	for c2i in range(c1i,len(cones)):
		c1,c2 = cones[c1i],cones[c2i]
		inboth = []
		for v in c1:
			if v in c2:
				inboth.append(v)
		if len(inboth)==2 and (inboth[0] not in orig or inboth[1] not in orig) and sum(inboth[0])+sum(inboth[1])<=N: 
			u1, u2 = None, None # vertices unique to c1, c2
			for v in c1:
				if v not in c2: u1 = v
			for v in c2:
				if v not in c1: u2 = v 

			ve = (inboth[0][0]+inboth[1][0],inboth[0][1]+inboth[1][1],inboth[0][2]+inboth[1][2])
			cc1,cc2,cc3,cc4=(u1,inboth[0],ve),(u1,inboth[1],ve),(u2,inboth[0],ve),(u2,inboth[1],ve)
			allowededgebl.append((coneind(c1),coneind(c2),coneind(cc1),coneind(cc2),coneind(cc3),coneind(cc4)))



bf = []
for bl in allowedfacebl:
	bf.append([2^c for c in bl])

be = []
for bl in allowededgebl:
	be.append([2^c for c in bl])

def befind(c1,c2): # find the edge blowup using c1 and c2
	for cbl in be:
		if cbl[0] == c1 and cbl[1] == c2: return cbl
		if cbl[0] == c2 and cbl[1] == c1: return cbl
	return -1

def bffind(c1):
	for cbl in bf:
		if cbl[0] == c1: return cbl
	return -1

nextblsafterebl = []
nextblsafterfbl = []

for bl in be:
	cur = []
	if befind(bl[2],bl[4]) != -1: cur.append(befind(bl[2],bl[4])) # edge 1 interior to squiggle we can bl
	if befind(bl[3],bl[5]) != -1: cur.append(befind(bl[3],bl[5])) # edge 2 interior to squiggle we can bl
	if befind(bl[2],bl[3]) != -1: cur.append(befind(bl[2],bl[3])) # edge 1 interior to squiggle we can bl
	if befind(bl[4],bl[5]) != -1: cur.append(befind(bl[4],bl[5])) # edge 2 interior to squiggle we can bl
	for bl2 in be:
		if (bl2[0] == bl[2] and bl2[1] not in [bl[3],bl[4],bl[5]]):
			cur.append(bl2)
		if (bl2[1] == bl[2] and bl2[0] not in [bl[3],bl[4],bl[5]]):
			cur.append(bl2)
		if (bl2[0] == bl[3] and bl2[1] not in [bl[2],bl[4],bl[5]]):
			cur.append(bl2)
		if (bl2[1] == bl[3] and bl2[0] not in [bl[2],bl[4],bl[5]]):
			cur.append(bl2)
		if (bl2[0] == bl[4] and bl2[1] not in [bl[3],bl[2],bl[5]]):
			cur.append(bl2)
		if (bl2[1] == bl[4] and bl2[0] not in [bl[3],bl[2],bl[5]]):
			cur.append(bl2)
		if (bl2[0] == bl[5] and bl2[1] not in [bl[3],bl[4],bl[2]]):
			cur.append(bl2)
		if (bl2[1] == bl[5] and bl2[0] not in [bl[3],bl[4],bl[2]]):
			cur.append(bl2)
	if bffind(bl[2]) != -1: cur.append(bffind(bl[2]))
	if bffind(bl[3]) != -1: cur.append(bffind(bl[3]))
	if bffind(bl[4]) != -1: cur.append(bffind(bl[4]))
	if bffind(bl[5]) != -1: cur.append(bffind(bl[5]))
	nextblsafterebl.append(cur)

for bl in bf:
	cur = []
	if befind(bl[1],bl[2]) != -1: cur.append(befind(bl[1],bl[2]))
	if befind(bl[1],bl[3]) != -1: cur.append(befind(bl[1],bl[3]))
	if befind(bl[2],bl[3]) != -1: cur.append(befind(bl[2],bl[3]))
	for bl2 in be:
	 	if (bl2[0] == bl[1] and bl2[1] not in [bl[2],bl[3]]):
			cur.append(bl2)
		if (bl2[1] == bl[1] and bl2[0] not in [bl[2],bl[3]]):
			cur.append(bl2)
		if (bl2[0] == bl[2] and bl2[1] not in [bl[1],bl[3]]):
			cur.append(bl2)
		if (bl2[1] == bl[2] and bl2[0] not in [bl[1],bl[3]]):
			cur.append(bl2)
		if (bl2[0] == bl[3] and bl2[1] not in [bl[1],bl[2]]):
			cur.append(bl2)
		if (bl2[1] == bl[3] and bl2[0] not in [bl[1],bl[2]]):
			cur.append(bl2)
	if bffind(bl[1]) != -1: cur.append(bffind(bl[1]))
	if bffind(bl[2]) != -1: cur.append(bffind(bl[2]))
	if bffind(bl[3]) != -1: cur.append(bffind(bl[3]))
	nextblsafterfbl.append(cur)

def squigglesEqual(s1,s2):
	if set(s1[0]) != set(s2[0]): return False
	if len(s1[1]) != len(s2[1]): return False
	for p in s1[1]:
		if set(p) not in [set(k) for k in s2[1]]: return False
	return True

def squiggleInSet(sq,sqset):
	for s2 in sqset:
		if squigglesEqual(sq,s2):
			return True
	return False

def newSquiggles(freecones,oldsquigglecones,cursquiggle,newsquiggles,edgesfromlastblowup):

	for i in range(len(cones)):
		if bini(oldsquigglecones,i) and bini(freecones,i): # if it's an osc and free to use
			cone = 2^i
			newfreecones = freecones - cone

			for bl in bf:
				if bl[0] == cone:
					newsquiggle = [c[0:] for c in cursquiggle] # clone
					newsquiggle[0].append(cone)
					if not squiggleInSet(newsquiggle,newsquiggles):
						newsquiggles.append(newsquiggle)
						newSquiggles(newfreecones,oldsquigglecones,newsquiggle,newsquiggles,edgesfromlastblowup)

			for j in range(len(cones)):
				if bini(newfreecones,j):
					cone2, c1, c2 = 2^j, cones[i], cones[j]
					shared = [c for c in c1 if c in c2]
					if len(shared)==2:
						if [cone,cone2] not in edgesfromlastblowup and [cone2,cone] not in edgesfromlastblowup and befind(cone,cone2)!=-1:
							newfreecones2 = newfreecones - cone2
							newsquiggle = [c[0:] for c in cursquiggle] # clone
							newsquiggle[1].append([cone,cone2])
							if not squiggleInSet(newsquiggle,newsquiggles):
								newsquiggles.append(newsquiggle)
								newSquiggles(newfreecones2,oldsquigglecones,newsquiggle,newsquiggles,edgesfromlastblowup)

def squiggleBlow(cur,squiggle): #
	new = cur
	for bl in squiggle[0]: new = fbl(new,bffind(bl))
	for bl in squiggle[1]: new = ebl(new,befind(bl[0],bl[1]))
	return new

def newEdgesFromEdgeBlowups(squiggle):
	ret = []
	for c in squiggle[1]:
		bl = befind(c[0],c[1])
		if bl != -1:
			ret.append([bl[2],bl[3]])
			ret.append([bl[4],bl[5]])
	return ret

def squiggleBlowCones(squiggle):
	ret = 0
	for cone in squiggle[0]:
		if not bini(ret,log(cone,2)): ret += cone
	for pair in squiggle[1]:
		if not bini(ret,log(pair[0],2)): ret += pair[0]
		if not bini(ret,log(pair[1],2)): ret += pair[1]
	return squiggleBlow(ret,squiggle)

def ncones(cur):
	return sum([bini(cur,i) for i in range(len(cones))])

def num():
	return sum([len(configs[i]) for i in range(len(configs))])

def actualnum():
	return sum([len(set(k)) for k in configs])

def genConfigs(config,oldsquigglecones,edgesfromlastblowup):
	newsquiggles = []
	newSquiggles(config,oldsquigglecones,[[],[]],newsquiggles,edgesfromlastblowup)

	for squiggle in newsquiggles:	
		newconfig = squiggleBlow(config,squiggle)
		newedgesfromlastblowup = newEdgesFromEdgeBlowups(squiggle)
		nc = ncones(newconfig)
		configs[nc].append(newconfig)
		if num()%10000==0: print num(), str(datetime.datetime.now())
		genConfigs(newconfig,squiggleBlowCones(squiggle),newedgesfromlastblowup)

	


initconf=bf[0][1]+bf[0][2]+bf[0][3]
configs = [[] for i in range(len(cones))]
configs[0] = [1,initconf]
genConfigs(initconf,initconf,[])



#recurseorig(1)