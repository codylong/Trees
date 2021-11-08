execfile("lib.sage")
import gc
gc.enable()

# given a squiggle, find all of its cones after blowup
def squiggleBlowCones(squiggle):
    ret = []
    for cone in squiggle[0]:
        if not coneInSet(cone,ret): ret.append(cone)
    for pair in squiggle[1]:
        for cone in pair:
            if not coneInSet(cone,ret): ret.append(cone)
    return squiggleBlow(ret,squiggle)

def squigglesEqual(s1,s2):
    if not configsEqual(s1[0],s2[0]): return False
    if not len(s1[1]) == len(s2[1]): return False
    for p in s1[1]:
        if not configInSet(p,s2[1]): return False
    return True

def squiggleInSet(sq, sqset):
    for s2 in sqset:
        if squigglesEqual(sq,s2): 
            return True
    return False

# efromlastblowup are edges from the last EDGE blowups
def newSquiggles(freecones,oldsquigglecones,cursquiggle,newsquiggles, edgesfromlastblowup): 
    # freecones: cones that haven't been used yet in a new squiggle. init the whole config
    # oldsquigglecones: the cones of the old squiggle that we're building on. need just cones
    # cursquiggle: the squiggle we're currently building
      # cursquiggle[0] list of faces blown
      # cursquiggle[1] list of pairs of faces that meet on an edge that's blown
    # newsquiggles: set of all new squiggles
    
    for cone in oldsquigglecones: # any blowup has to use an old squiggle cone
        if coneInSet(cone,freecones): # if it's free to use

            newfreecones = removeConeFromSet(cone,freecones) # no longer free to use
            
            # BEGIN FACE BLOWUP
            if sum(cone[0])+sum(cone[1])+sum(cone[2]) <= N: # Ben bound
                
                newsquiggle = cloneConeSet(cursquiggle)
                newsquiggle[0].append(cone) # add to new squiggle
                if not squiggleInSet(newsquiggle,newsquiggles):
                    newsquiggles.append(newsquiggle)
                    newSquiggles(newfreecones,oldsquigglecones,newsquiggle,newsquiggles, edgesfromlastblowup) # pass it on

            # FIND PAIR FOR EDGE BLOWUP
                
            for cone2 in newfreecones:
                if shareEdge(cone,cone2):
                    shared = sharedEdge(cone,cone2)
                    o1, o2 = [shared[0],shared[1]], [shared[1],shared[0]]
                    s = 0
                    for v in cone:
                        if v in cone2: s += sum(v)
                    if o1 not in edgesfromlastblowup and o2 not in edgesfromlastblowup and s <= N:
                        newfreecones = removeConeFromSet(cone2,newfreecones)
                        newsquiggle = cloneConeSet(cursquiggle)
                        newsquiggle[1].append([cone,cone2]) # add a pair of cones, ie edge blow
                        
                        if not squiggleInSet(newsquiggle,newsquiggles):
                            newsquiggles.append(newsquiggle)
                            newSquiggles(newfreecones,oldsquigglecones,newsquiggle,newsquiggles, edgesfromlastblowup)
  
def squiggleBlow(config,squiggle): # blows up according to a squiggle
    newconfig = config
    for face in squiggle[0]:
        newconfig = faceBlow(newconfig,face[0],face[1],face[2])
    for edgeblow in squiggle[1]:
        edge = vertsFromSimplexPair(edgeblow)
        newconfig = edgeBlow(newconfig,edge[0],edge[1])
    return newconfig

def squigglesSort(squigglesList): # sort according to e, f
    ret = []
    for squiggle in squigglesList:
        f, e = len(squiggle[0]), len(squiggle[1])
        found = False
        for k in ret:
            if [f,e] == k[0]:
                found = True
                k[1].append(squiggle)
                break
        if not found: ret.append([[f,e],[squiggle]])
    return ret

def sortedSquigglesModSymmetry(initconfig,newsquiggles):
    sortsquiggles = squigglesSort(newsquiggles)
    modout = [[] for i in range(len(sortsquiggles))]
    configmodout = [[] for i in range(len(sortsquiggles))]
    for i in range(len(sortsquiggles)):
        for newsquiggle in sortsquiggles[i][1]:
            #if not symSquiggleInSet(newsquiggle,modout[i]): modout[i].append(newsquiggle)
            newconfig = squiggleBlow(initconfig,newsquiggle)
            if not symConfigInSet(newconfig,configmodout[i]): 
                modout[i].append(newsquiggle)
                configmodout[i].append(newconfig)
    ret = []
    for m in modout: ret.extend(m)
    return ret

def symSquiggleInSet(squiggle,sset):
    if squiggleInSet(squiggle,sset): return True
    symsquiggles = genSymSquiggles(squiggle)
    for sym in symsquiggles:
        if squiggleInSet(sym,sset): return True
    return False
    
def coneShift(c,shift): # shift a cone by an amount
    return [(c[0][(0+shift)%3],c[0][(1+shift)%3],c[0][(2+shift)%3]),
                      (c[1][(0+shift)%3],c[1][(1+shift)%3],c[1][(2+shift)%3]),
                      (c[2][(0+shift)%3],c[2][(1+shift)%3],c[2][(2+shift)%3])]

def coneMap(c,m): # map a cone c
    return [(c[0][m[0]],c[0][m[1]],c[0][m[2]]),
                      (c[1][m[0]],c[1][m[1]],c[1][m[2]]),
                      (c[2][m[0]],c[2][m[1]],c[2][m[2]])]

def genSymSquiggles(squiggle):
    symSquiggles = []
    for shift in range(0,3): # these implement the shifts of the z3 action
        n = [[],[]]
        for c in squiggle[0]: # these are the faces, i.e. cones
            n[0].append(coneShift(c,shift))
        for k in squiggle[1]:
            n[1].append([coneShift(k[0],shift),coneShift(k[1],shift)])
        symSquiggles.append(n)

    for fix in range(3):
        if fix == 0: m=[0,2,1] # indices to be swapped
        if fix == 1: m=[2,1,0]
        if fix == 2: m=[1,0,2]
        n = [[],[]]
        for c in squiggle[0]:
            n[0].append(coneMap(c,m))
        for k in squiggle[1]: # go through PAIRS
            n[1].append([coneMap(k[0],m),coneMap(k[1],m)])
        symSquiggles.append(n)
    
    noRedundSymSquiggles = [squiggle]
    for sc in symSquiggles:
        if not squiggleInSet(sc,noRedundSymSquiggles): noRedundSymSquiggles.append(sc)

    return noRedundSymSquiggles

def newEdgesFromEdgeBlowups(squiggle):
    ret = []
    for c in squiggle[1]: # pair of cones
        inc0, inc1, inboth = None, None, []
        for k in c[0]:
            if k in c[1]: 
                inboth.append(k)
            else: inc0 = k
        for k in c[1]:
            if k not in inboth: inc1 = k

        ve = vsum(inboth[0],inboth[1])
        ret.append([inc0,ve])
        ret.append([inc1,ve])
    return ret

def abcCone(cone):
    ret = []
    for v in cone:
        ret.append(sum(v))
    return ret

def triplesSame(t1,t2):
    if len(t1) != len(t2): return False
    for t in t1:
        if t not in t2: return False
        if t1.count(t) != t2.count(t): return False
    return True

def badPtBlowCone(cone):
    bad = [[2,3,5],[1,3,4],[2,5,5],[3,4,4],[3,4,5]]
    abc = abcCone(cone)
    for b in bad:
        if triplesSame(b,abc): return True
    return False

def satisfiesNoBadPtBlowCone(config):
    for c in config:
        if badPtBlowCone(c): return False
    return True       

def configConvert(config):
    newconfig = [[],[]]
    for c in config:
        for v in c:
            if v not in newconfig[0]: newconfig[0].append(v)
    for c in config:
        newconfig[1].append([newconfig[0].index(v) for v in c])
    return newconfig

 

ans1, ans2 = [], []
def genConfigs(config,oldsquigglecones,edgesfromlastblowup):
    newsquiggles = []
    newSquiggles(config,oldsquigglecones,[[],[]],newsquiggles,edgesfromlastblowup)
    squigglesmodsym = sortedSquigglesModSymmetry(config,newsquiggles)

    for squiggle in squigglesmodsym:
        newconfig = squiggleBlow(config,squiggle)
        #if configsEqual(newconfig,c4): print 'strange2'
        newedgesfromlastblowup = newEdgesFromEdgeBlowups(squiggle)
        if satisfiesBenBound(newconfig) and satisfiesNoBadPtBlowCone(newconfig):
            configs.append(newconfig)
            genConfigs(newconfig,squiggleBlowCones(squiggle),newedgesfromlastblowup)
    if len(configs)%100==0: print len(configs)

N = 6
initconf = [[(1,0,0),(0,0,1),(1,1,1)],[(0,1,0),(0,0,1),(1,1,1)],[(1,0,0),(0,1,0),(1,1,1)]]
configs = [initconf]
genConfigs(initconf,initconf,[])    
print len(configs)              
#totconfigs = configs#

#f = open('out2.txt','w')
#f.write(str(len(configs)))
#f.close()#

import cPickle
cPickle.dump(configs,open("/home/jim/Documents/c"+str(N)+".pickle",'wb'))

allconfigs = []
for c in configs:
    if not symConfigInSet(c,allconfigs): allconfigs.append(c)
print len(allconfigs)
#toomanyconfigs = allconfigs

configs = allconfigs
allconfigs = []
allconfigs.append([[(1,0,0),(0,1,0),(0,0,1)]])
for c in configs:
    allconfigs.extend(genSymConfigs(c))
print len(allconfigs)

#c1 = edgeBlow(initconf,(1,0,0),(1,1,1))
#c2 = edgeBlow(c1,(1,1,1),(0,1,0))
#c3 = edgeBlow(c2,(1,1,1),(0,0,1))
#c4 = edgeBlow(c3,(2,1,1),(0,0,1))#

#f = open('out.txt','w')
#f.write(str(len(allconfigs)))
#f.close()

#### Testing the squiggles generator. All works as expected
# testconf = [[(1,0,0),(0,0,1),(1,1,1)],[(0,1,0),(0,0,1),(1,1,1)],[(1,0,0),(0,1,0),(1,1,1)]]
# N, testsquiggles = 10, []
# newSquiggles(testconf,testconf,[[],[]],testsquiggles)
# print len(testsquiggles)
# N, testsquiggles = 4, []
# newSquiggles(testconf,testconf,[[],[]],testsquiggles)
# print len(testsquiggles)
# N, testsquiggles = 5, []
# newSquiggles(testconf,testconf,[[],[]],testsquiggles)
# print len(testsquiggles)
