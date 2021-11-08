def vsum(v1,v2):
    return tuple([list(v1)[i]+list(v2)[i] for i in range(len(v1))])

def conesEqual(c1,c2):
    return set(c1)==set(c2)

def coneInConfig(cone,conf):
    for cone2 in conf:
        if conesEqual(cone,cone2): return True
    return False

def coneInSet(cone,conf):
    return coneInConfig(cone,conf)

def cloneConeSet(coneset):
    return [c[0:] for c in coneset]

def removeConeFromSet(cone,coneset):
    cs = cloneConeSet(coneset)
    for cone2 in cs:
        if conesEqual(cone,cone2):
            cs.remove(cone2)
            return cs
    return cs

def shareEdge(cone1,cone2):
    numsame = 0
    for c in cone1:
        if c in cone2: numsame += 1
    if numsame == 2: return True
    else: return False

def sharedEdge(cone1,cone2):
    inboth = []
    for c in cone1:
        if c in cone2: inboth.append(c)
    if len(inboth)!=2: 
        print 'ERROR, NO SHARED EDGE!'
    else: return inboth 

def configsEqual(conf1,conf2):
    if len(conf1) != len(conf2): return False
    for cone1 in conf1:
        if not coneInConfig(cone1,conf2): return False
    return True
    
def configInSet(conf,confset):
    for conf2 in confset:
        if configsEqual(conf,conf2): return True
    return False

def pointsInConfig(conf):
    vs = []
    for cone in conf:
        for v in cone:
            if v not in vs: vs.append(v)
    return vs

def edgeBlow(conf,v1,v2):
    newconf = []
    for cone in conf:
        if v1 not in cone or v2 not in cone:
            newconf.append(cone)
        else:
            not12 = None
            ve = vsum(v1,v2)
            for vi in cone:
                if vi != v1 and vi != v2:
                    not12 = vi
                    break
            if not coneInConfig([not12,v1,ve],newconf): newconf.append([not12,v1,ve]) 
            if not coneInConfig([not12,ve,v2],newconf): newconf.append([not12,ve,v2])
            for cone2 in conf: # find other cone with v1, v2, to gen new cones
                if v1 in cone2 and v2 in cone2 and not12 not in cone2: 
                    not12again = None
                    for vi in cone2:
                        if vi != v1 and vi != v2:
                            not12again = vi
                    if not coneInConfig([not12again,v1,ve],newconf): newconf.append([not12again,v1,ve])
                    if not coneInConfig([not12again,ve,v2],newconf): newconf.append([not12again,ve,v2])
            
    return newconf

def faceBlow(conf,v1,v2,v3):
    newconf = []
    for cone in conf:
        if v1 not in cone or v2 not in cone or v3 not in cone:
            newconf.append(cone)
        else:
            ve = vsum(vsum(v1,v2),v3)
            newconf.append([ve,v2,v3])
            newconf.append([v1,ve,v3])
            newconf.append([v1,v2,ve])
    return newconf

def satisfiesBenBound(conf):
    for cone in conf:
        for v in cone:
            if sum(v) > N: return False
    return True

def vertsFromSimplexPair(pair):
    c1, c2, vs = pair[0], pair[1], []
    for c in c1:
        if c in c2:
            vs.append(c)
    return vs


def coneFromPair(pair):
    cone = []
    for c1 in pair[0]:
        if c1 in pair[1]: cone.append(c1)
    return cone

def sumConfigs():
    confsum = 0
    for confsWithCones in configs: 
        for confsWithConesAndVerts in confsWithCones:
            confsum += len(confsWithConesAndVerts[1])
    return confsum

def configInSet(conf,confset):
    for conf2 in confset:
        if configsEqual(conf,conf2): return True
    return False

def genSymConfigs(conf):
    symConfs = []
    for shift in range(0,3): # these implement the shifts of the z3 action
        n = []
        for c in conf:
            n.append([(c[0][(0+shift)%3],c[0][(1+shift)%3],c[0][(2+shift)%3]),
                      (c[1][(0+shift)%3],c[1][(1+shift)%3],c[1][(2+shift)%3]),
                      (c[2][(0+shift)%3],c[2][(1+shift)%3],c[2][(2+shift)%3])])
        symConfs.append(n)
    for fix in range(3):
        if fix == 0: m=[0,2,1] # indices to be swapped
        if fix == 1: m=[2,1,0]
        if fix == 2: m=[1,0,2]
        n = []
        for c in conf:
            n.append([(c[0][m[0]],c[0][m[1]],c[0][m[2]]),
                      (c[1][m[0]],c[1][m[1]],c[1][m[2]]),
                      (c[2][m[0]],c[2][m[1]],c[2][m[2]])])
        symConfs.append(n)
    
    noRedundSymConfs = [conf]
    for sc in symConfs:
        if not configInSet(sc,noRedundSymConfs): noRedundSymConfs.append(sc)

    
    #print len(noRedundSymConfs), len(symConfs)
    #print symConfs
    #return symConfs 
    return noRedundSymConfs
        
def symConfigInSet(conf,confset):
    symConfs = genSymConfigs(conf)
    for symConf in symConfs:
        if configInSet(symConf,confset): return True
    return False

def getVerts(conf):
    s = []
    for cone in conf:
        for v in cone:
            if v not in s: s.append(v)
    return s

def configOrSymConfigInSetWithNumConesAndVerts(conf,confconeswverts):
    if set(getVerts(conf)) != set(coneconeswverts[0]): return False
    return symConfigInSet(conf,confconeswverts[1])

def vertsInSet(vs,ss):
    for s in ss:
        if set(vs) == set(s): return True
    return False

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

def singleBlowupConnecting(t1,t2): # False if not, 1 if t2 is blow of t1, -1 if t1 is blow of t2
    vs1, vs2 = getVerts(t1), getVerts(t2)
    if abs(len(vs1)-len(vs2)) != 1: return False
    if len(vs1) > len(vs2): # make sure t1 is smaller tree for convenience
        b1,b2,c1,c2 = t1, t2, vs1, vs2
        tt1, tt2, vs1, vs2 = b2, b1, c2, c1
    else:
        tt1, tt2 = t1, t2
    v2not1, v1not2 = [v for v in vs2 if v not in vs1], [v for v in vs1 if v not in vs2]
    if len(v1not2) > 0: return False # tt1 smaller, but has vert not in tt2, so not blowup
    if len(v2not1) != 1:
        return False
    else:
        vdiff = v2not1[0]
        # if tt2 is a blowup of tt1, we have uncovered the offending vertex
        vdc = [c for c in tt2 if vdiff in c]
        print len(vdc)
        # for cone in tt1:
        #     if vsum(cone[0],cone[1])==vdiff:
        #         new = edgeBlow(tt1,cone[0],cone[1])
        #         if configsEqual(tt2, new): # True -> tt2 is blowup of tt1
        #             if tt1 == t1: # t2 is a blowup of t1
        #                 return 1
        #             else: return -1
        #         else: return False

        #     elif vsum(cone[1],cone[2])==vdiff:
        #         new = edgeBlow(tt1,cone[1],cone[2])
        #         if configsEqual(tt2, new): # True -> tt2 is blowup of tt1
        #             if tt1 == t1: # t2 is a blowup of t1
        #                 return 1
        #             else: return -1
        #         else: return False

        #     elif vsum(cone[2],cone[0])==vdiff:
        #         new = edgeBlow(tt1,cone[2],cone[0])
        #         if configsEqual(tt2, new): # True -> tt2 is blowup of tt1
        #             if tt1 == t1: # t2 is a blowup of t1
        #                 return 1
        #             else: return -1
        #         else: return False

        #     elif vsum(vsum(cone[0],cone[1]),cone[2])==vdiff:
        #         new = faceBlow(tt1,cone[0],cone[1],cone[2])
        #         if configsEqual(tt2,new):
        #             if tt1 == t1: 
        #                 return 1
        #             else: return -1
        #         else: return False
