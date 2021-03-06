load("lib.sage")

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

def edgeBlow(conf,v1,v2):
    newconf = []
    for cone in conf:
        if v1 not in cone or v2 not in cone:
            newconf.append(cone)
        else:
            if len(cone) == 2:
                ve = vsum(v1,v2)
                newconf.append([v1,ve])
                newconf.append([ve,v2])
            #not12 = None
            #for vi in cone:
            #    if vi != v1 and vi != v2:
            #        not12 = vi
            #        break
    return newconf

def satisfiesBenBound(conf):
    for cone in conf:
        for v in cone:
            if sum(v) > N: return False
    return True

def genConfigs(blowconf):
    for cone in blowconf:
        for i in range(len(cone)): # edge blows
            for j in range(i+1,len(cone)):
                newconf = edgeBlow(blowconf,cone[i],cone[j])
                if not configInSet(newconf,configs[len(newconf)-1]) and satisfiesBenBound(newconf):
                    configs[len(newconf)-1].append(newconf)
                    genConfigs(newconf)
N = 6
configs = [[] for i in range(1000)]
configs[0].append([[(1,0),(0,1)]])
genConfigs(configs[0][0])
confsum = 0
for confs in configs: confsum += len(confs)
print confsum

vs = []
for confs in configs:
    for conf in confs:
        if not vertsInSet(getVerts(conf),vs): vs.append(getVerts(conf))
