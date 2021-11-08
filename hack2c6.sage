OBimport cPickle as pickle
import sys

execfile("lib.sage")

def pickledump(todump,filename):
    pickle.dump(todump,open("/home/jim/Documents/"+filename+".pickle",'wb'))

# def symVertsFound(c):
#     ret = -1
#     verts = getVerts(c)
#     for j in range(len(vconfigs)):
#         if vertsInSet(verts,vconfigs[j]):
#             return j
#     symconfs = genSymConfigs(c)
#     symverts = []
#     for sc in symconfs: symverts.append(getVerts(sc))
#     return symverts

# def vertsInSet(vs,ss):
#     for s in ss:
#         if set(vs) == set(s): return True
#     return False

# if 'configs' not in vars(): configs = pickle.load(open('/home/jim/Documents/c6.pickle','rb'))

# vconfigs, sconfigs = [], []
# for i in range(len(configs)):
#     if i%1000==0: print i, len(vconfigs)
#     c = configs[i]
#     found = symVertsFound(c)
#     if type(found) == type([]):
#         vconfigs.append(found)
#         sconfigs.append([c])
#     else:
#         sconfigs[found].append(c)
            
    
#### README
# This code assumes that the above has already been run. i.e. we've
# sorted according to sym vert sets, and now we will go through and sort again

def filter(clist):
    ret = []
    for j in range(len(clist)):
        if j % 1000 == 0 and j != 0: print '\t', j, len(ret)
        c = clist[j]
        if not symConfigInSet(c,ret): ret.append(c)
    return ret

ssconfigs = [] # just sorting again
for i in range(17,picklen(sconfigs)):
    print i, len(sconfigs[i])
    ssconfigs.append(filter(sconfigs[i]))
        
tot = []
for s in ssconfigs:
    tot.extend(s)
