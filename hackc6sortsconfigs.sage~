import cPickle as pickle
import sys
import datetime

execfile("lib.sage")

def pickledump(todump,filename):
    pickle.dump(todump,open("/home/jim/Documents/"+filename+".pickle",'wb'))

def coneHeight(cone):
    ret = 0
    for v in cone:
        ret += sum(v)
    return ret

def cvhEqual(vh1,vh2):
    for v in vh1:
        if vh1.count(v) != vh2.count(v): return False
    return True

def coneVHeights(cone):
    return [sum(v) for v in cone]

def numConesWithHeight(config):
    ret = [0 for i in range(19)]
    # for N=6 max vheight = 6, so max cone height = 18
    for c in config:
        ret[coneHeight(c)] += 1
    return ret

def numConesWithHeightTrip(config):
    ret = []
    for c in config:
        cvh = coneVHeights(c)
        found = -1
        for i in range(len(ret)):
            if cvhEqual(cvh,ret[i][0]):
                found = i
                break
        if found == -1:
            ret.append([cvh,1])
        else:
            ret[found][1] += 1
    return ret

def heightTripsEqual(ht1, ht2):
    if len(ht1) != len(ht2): return False
    for h1 in ht1:
        found = False
        for h2 in ht2:
            if cvhEqual(h1[0],h2[0]):
                if h1[1] != h2[1]: 
                    return False
                else:
                    found = True
                    break
        if not found: return False
    return True
                

def intelligentSort(tosort):
    ret = []
    temp = []
    for conf in tosort:
        cheights = numConesWithHeightTrip(conf)
        #cheights = numConesWithHeight(conf)
        found = -1
        #print cheights
        for i in range(len(temp)):
            #if cheights == temp[i][0]:
            if heightTripsEqual(cheights,temp[i][0]):
                found = i
                break
        if found == -1:
            temp.append([cheights,[conf]])
        else: 
            temp[i][1].append(conf)
    temp2 = [[] for k in temp]
    k = [len(t[1]) for t in temp]
    print '\t\t', k

    toPrint = False
    if len(tosort) > 1000: toPrint = True
    
    for i in range(len(temp)):
        if toPrint: print "\t\tbegin subset", len(temp[i][1])
        for j in range(len(temp[i][1])):
            conf = temp[i][1][j]
            if toPrint and j % 1000 == 0 and k != 0: print '\t\tPROG', j, datetime.datetime.now().isoformat()
            if not symConfigInSet(conf,temp2[i]):
                temp2[i].append(conf)
            
    for t in temp2: ret.extend(t)
    return ret

if 'sconfigs' not in vars(): sconfigs = pickle.load(open('/home/jim/Documents/sconfigs.pickle','rb'))

sortconfigs = []

tot, totnondup = 0, 0
for i in range(len(sconfigs)):
    newv = []
    print "BEGIN", i, "OF", len(sconfigs), "LENGTH", len(sconfigs[i])
    for j in range(len(sconfigs[i])):
        newstrat = []
        print "\t",i,"SORTING", len(sconfigs[i][j][1]), "total sorted so far", tot, "total non-dup", totnondup
        newstrat = intelligentSort(sconfigs[i][j][1])
        tot += len(sconfigs[i][j][1])
        totnondup += len(newstrat)
        newv.append(newstrat)
        diff = len(sconfigs[i][j][1])-len(newstrat)
        if diff != 0: print '\tDIFF', diff
    pickledump(newv,"newv"+str(i))
    sortconfigs.append(newv)
    check = 0
    for j in range(len(sortconfigs)):
        for k in range(len(sortconfigs[j])): check += len(sortconfigs[j][k])
    print "HERE", check, totnondup, tot
    
pickledump(sortconfigs,"sortconfigs")    
     
