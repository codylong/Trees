execfile("lib.sage")
import cPickle as pickle
import numpy

ftrees = pickle.load(open("Data/facetreesNoBad46pts.pickle",'rb'))
if True: #'A' not in vars():
    A = [[0 for i in ftrees] for j in ftrees]
    checks=[]
    for i in range(len(ftrees)):
        for j in range(i+1,len(ftrees)):
            checks.append(singleBlowupConnecting(ftrees[i],ftrees[j]))
            #if k != False: 
            #    A[i][j] = k
            #    A[j][i] = -k

ftreenet = DiGraph(matrix(A))
