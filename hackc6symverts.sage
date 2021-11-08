import cPickle as pickle
import sys

execfile("lib.sage")

def pickledump(todump,filename):
    pickle.dump(todump,open("/home/jim/Documents/"+filename+".pickle",'wb'))

def symVertsFound(c):
    ret = -1
    verts = getVerts(c)
    for j in range(len(vconfigs)):
        if vertsInSet(verts,vconfigs[j]):
            return j
    symconfs = genSymConfigs(c)
    symverts = []
    for sc in symconfs: symverts.append(getVerts(sc))
    return symverts

def vertsInSet(vs,ss):
    for s in ss:
        if set(vs) == set(s): return True
    return False

def filter(clist):
    ret = []
    for j in range(len(clist)):
        if j % 1000 == 0 and j != 0: print '\t', j, len(ret)
        c = clist[j]
        if not symConfigInSet(c,ret): ret.append(c)
    return ret

def numWith111(conf):
    ret = 0
    for c in conf:
        if (1,1,1) in c: ret += 1
    return ret

def numTouch111(conf):
    ret = []
    for c in conf:
        if (1,1,1) in c:
            for v in c:
                if v != (1,1,1) and v not in ret:
                    ret.append(v)
    return len(ret)

if 'configs' not in vars(): configs = pickle.load(open('/home/jim/Documents/c6.pickle','rb'))

vconfigs, sconfigs = [], []
for i in range(len(configs)):
    if i%1000==0: print i, len(vconfigs)
    c = configs[i]
    found = symVertsFound(c)
    numCones = len(c)
    if type(found) == type([]):
        vconfigs.append(found)
        sconfigs.append([[[numCones,numWith111(c), numTouch111(c)],[c]]])
    else:
        ind = [numCones,numWith111(c), numTouch111(c)]
        wasfound = False
        for sconfi in sconfigs[found]:
            if sconfi[0] == ind:
                sconfi[1].append(c)
                wasfound = True
                break
        if not wasfound: sconfigs[found].append([[numCones,numWith111(c), numTouch111(c)],[c]])
    
            
pickledump(vconfigs,"vconfigs")
pickledump(sconfigs,"sconfigs")    
    
