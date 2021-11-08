import datetime
import numpy as np

def bini(n,i):
	return (n >> i)%2

N = 5
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

configs = [1]


def recurse(cur,lastbl):
	if cur not in configs:
		configs.append(cur)
		#configs.sort()
		if len(configs)%1000==0: print len(configs), str(datetime.datetime.now())
	
	nextbls = None
	if len(lastbl)==6:
		nextbls=nextblsafterebl[be.index(lastbl)]
	elif len(lastbl)==4:
		nextbls=nextblsafterfbl[bf.index(lastbl)]

	for bl in nextbls:
		if len(bl)==6 and bini(cur,log(bl[0],2)) and bini(cur,log(bl[1],2)):
			recurse(ebl(cur,bl),bl)
		if len(bl)==4 and bini(cur,log(bl[0],2)):
			recurse(fbl(cur,bl),bl)

recurse(bf[0][1]+bf[0][2]+bf[0][3],bf[0])

def recurseorig(cur):
	# found = False
	# for i in range(len(configs)):
	# 	if configs[i] == cur or configs[i] > cur:
	# 		found = True
	# 		break
	# if not found:
	if cur not in configs:
		configs.append(cur)
		#configs.sort()
		if len(configs)%1000==0: print len(configs), str(datetime.datetime.now())
	for bl in bf:
		if bini(cur,log(bl[0],2)):
			recurse(fbl(cur,bl))
	for bl in be:
		if bini(cur,log(bl[0],2)) and bini(cur,log(bl[1],2)):
			recurse(ebl(cur,bl))

#recurseorig(1)