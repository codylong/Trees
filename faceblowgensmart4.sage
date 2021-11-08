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

def decideHowToAdd(newconf):
    if satisfiesBenBound(newconf): # don't do anything else if not a good fit
        nConesM1 = len(newconf)-1
        if len(configs[nConesM1]) == 0: # first time this number of cones
            symconfs = genSymConfigs(newconf)
            symverts = []
            for sc in symconfs: symverts.append(getVerts(sc))
            configs[nConesM1].append([symverts,genSymConfigs(newconf)])
            genConfigs(newconf)
        else:
            vertMatch = -1
            for k in range(len(configs[nConesM1])):
                if len(configs[nConesM1][k]) > 0 and vertsInSet(getVerts(newconf),configs[nConesM1][k][0]): 
                    vertMatch = k
                    break
            if vertMatch == -1: # first config or sym config with these verts
                symconfs = genSymConfigs(newconf)
                symverts = []
                for sc in symconfs: symverts.append(getVerts(sc))
                configs[nConesM1].append([symverts,genSymConfigs(newconf)])
                genConfigs(newconf)
            else: # config with these verts already found
                if not configInSet(newconf,configs[nConesM1][vertMatch][1]): # if sym conf not already this set
                    configs[nConesM1][vertMatch][1].extend(genSymConfigs(newconf))
                    genConfigs(newconf)


def genConfigs(blowconf):
    if sumConfigs() % 100 == 0: print sumConfigs()
    for cone in blowconf:
        for i in range(len(cone)): # edge blows
            for j in range(i+1,len(cone)):
                if sum(cone[i]) > 1 or sum(cone[j]) > 1: # don't blow exterior edges
                    newconf = edgeBlow(blowconf,cone[i],cone[j])
                    decideHowToAdd(newconf)
                                
        
        newconf = faceBlow(blowconf,cone[0],cone[1],cone[2]) # face blows
        decideHowToAdd(newconf)
    
N = 5
configs = [[] for i in range(1000)] # these are NOT all configs in this code, just the symmetric ones
configs[0].append([[[(1,0,0),(1,0,0),(1,0,0)]],[[[(1,0,0),(0,1,0),(0,0,1)]]]])
genConfigs(configs[0][0][1][0])
print sumConfigs()

#allconfigs = []
#for c1 in configs:
#    for c2 in c1:
#        for c in c2[1]:
#            allconfigs.extend(genSymConfigs(c))
#print len(allconfigs)

#NOW HAVE ALL SYMMETRIC CONFIGS
#CONSTRUCT ALL CONFIGS USING SYMMETRIES
# allconfigs = []
# for confs in configs:
#     if confs != []: print 'syms', configs.index(confs)
#     for confs2 in confs:
#         cur = []
#         print confs2[1]
#         for conf in confs2[1]:
#             s = genSymConfigs(conf)
#         cur.append(c)
#         for c in s:
#             if not configInSet(c,cur):
#                 cur.append(c)
#         allconfigs.append(cur)
# configs = allconfigs
# print sumConfigs()
    


# N=5 result: 4231, finished in 21 minutes
