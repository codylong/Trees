import cPickle as pickle
import sys


def configConvert(config):
    newconfig = [[],[]]
    for c in config:
        for v in c:
            if v not in newconfig[0]: newconfig[0].append(v)
    for c in config:
        app = []
        newconfig[1].append(tuple([newconfig[0].index(v) for v in c]))
    return (tuple(newconfig[0]),tuple(newconfig[1]))

def pickledump(todump,filename):
    pickle.dump(todump,open("/home/jim/Documents/"+filename+".pickle",'wb'))

l, d = int(sys.argv[1]), int(sys.argv[2])
#l, d = 0, 500000
print 'loading'
configs = pickle.load(open('/home/jim/Documents/c6.pickle','rb'))
print 'done loading'
cconfigs = []
for i in range(l,d):
    if i % 10000 == 0: print i
    cconfigs.append(configConvert(configs[i]))
pickledump(cconfigs,"cniceFormat"+str(l)+"to"+str(d))
    
