def vsum(v1,v2):
    return tuple([list(v1)[i]+list(v2)[i] for i in range(len(v1))])

def conesEqual(c1,c2):
    return set(c1)==set(c2)

def coneInConfig(cone,conf):
    for cone2 in conf[1]:
        if conesEqual(cone,cone2): return True
    return False

def coneInSet(cone,coneset):
    for cone2 in coneset:
        if conesEqual(cone,cone2): return True
    return False

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
    if len(conf1[0]) != len(conf2[0]): return False # check numverts
    if len(conf1[1]) != len(conf2[1]): return False # check numcones
    if set(conf1[0]) != set(conf2[0]): return False # check verts same
    for cone1 in conf1[1]: # check cones same
        if not coneInConfig(cone1,conf2): return False
    return True

def coneSetsEqual(conf1,conf2):
    if len(conf1) != len(conf2): return False
    for cone1 in conf1:
        if not coneInSet(cone1,conf2): return False
    return True
    
def configInSet(conf,confset):
    for conf2 in confset:
        if configsEqual(conf,conf2): return True
    return False

def pointsInConfig(conf):
    return conf[0]

def edgeBlow(conf,v1,v2):
    vs = conf[0]
    newconf = [[v for v in vs],[]]
    for cone in conf[1]:
        if v1 not in cone or v2 not in cone:
            newconf[1].append(cone)
        else:
            not12 = None
            ve = vsum(vs[v1],vs[v2])
            newconf[0].append(ve)
            vei = len(newconf[0])-1
            for vi in cone:
                if vi != v1 and vi != v2:
                    not12 = vi
                    break
            if not coneInConfig([not12,v1,vei],newconf): newconf.append((not12,v1,vei)) 
            if not coneInConfig([not12,vei,v2],newconf): newconf.append((not12,vei,v2))
            for cone2 in conf: # find other cone with v1, v2, to gen new cones
                if v1 in cone2 and v2 in cone2 and not12 not in cone2: 
                    not12again = None
                    for vi in cone2:
                        if vi != v1 and vi != v2:
                            not12again = vi
                    if not coneInConfig([not12again,v1,vei],newconf): newconf.append((not12again,v1,vei))
                    if not coneInConfig([not12again,vei,v2],newconf): newconf.append(n(ot12again,vei,v2))
            
    return newconf

def faceBlow(conf,v1,v2,v3):
    vs = conf[0]
    newconf = [[v for v in vs],[]]
    
    for cone in conf[1]:
        if v1 not in cone or v2 not in cone or v3 not in cone:
            newconf[1].append(cone)
        else:
            ve = vsum(vsum(vs[v1],vs[v2]),vs[v3])
            newconf[0].append(ve)
            vei = len(newconf[0])-1
            newconf[1].append((vei,v2,v3))
            newconf[1].append((v1,vei,v3))
            newconf[1].append((v1,v2,vei))
    return newconf

def satisfiesBenBound(conf):
    for v in conf[0]:
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

def genSymConfigs(conf):
    symConfs = []
    for shift in range(0,3): # these implement the shifts of the z3 action
        n = [[],conf[1]]
        for c in conf[0]:
            n[0].append((c[(0+shift)%3],c[(1+shift)%3],c[(2+shift)%3]))
        symConfs.append(n)
    for fix in range(3):
        if fix == 0: m=[0,2,1] # indices to be swapped
        if fix == 1: m=[2,1,0]
        if fix == 2: m=[1,0,2]
        n = [[],conf[1]]
        for c in conf[1]:
            n[0].append((c[m[0]],c[m[1]],c[m[2]]))
        symConfs.append(n)
    
    noRedundSymConfs = [conf]
    for sc in symConfs:
        if not configInSet(sc,noRedundSymConfs): noRedundSymConfs.append(sc)

    return noRedundSymConfs
        
def symConfigInSet(conf,confset):
    symConfs = genSymConfigs(conf)
    for symConf in symConfs:
        if configInSet(symConf,confset): return True
    return False

def getVerts(conf):
    return conf[0]
