def vsum(v1,v2):
    return tuple([list(v1)[i]+list(v2)[i] for i in range(len(v1))])

def conesEqual(c1,c2):
    return set(c1)==set(c2)

def coneInConfig(cone,conf):
    for cone2 in conf:
        if conesEqual(cone,cone2): return True
    return False

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

def sumConfigs():
    confsum = 0
    for confs in configs: confsum += len(confs)
    return confsum


def genConfigs(blowconf):
    if sumConfigs() % 100 == 0: print sumConfigs()
    for cone in blowconf:
        for i in range(len(cone)): # edge blows
            for j in range(i+1,len(cone)):
                if sum(cone[i]) > 1 or sum(cone[j]) > 1: # don't blow exterior edges
                    newconf = edgeBlow(blowconf,cone[i],cone[j])
                    if not configInSet(newconf,configs[len(newconf)-1]) and satisfiesBenBound(newconf):
                        configs[len(newconf)-1].append(newconf)
                        genConfigs(newconf)

        newconf = faceBlow(blowconf,cone[0],cone[1],cone[2]) # face blows
        if not configInSet(newconf,configs[len(newconf)-1]) and satisfiesBenBound(newconf):
            configs[len(newconf)-1].append(newconf)
            genConfigs(newconf)

N = 5
configs = [[] for i in range(1000)]
configs[0].append([[(1,0,0),(0,1,0),(0,0,1)]])
genConfigs(configs[0][0])
print sumConfigs()

# N=5 result: 4231, finished in 21 minutes
