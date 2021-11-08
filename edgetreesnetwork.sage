execfile("lib.sage")
import cPickle as pickle
import numpy

def getverts(etree):
	verts = []
	for ed in etree:
		for v in ed:
			if v not in verts:
				verts.append(v)
	return verts

etrees = pickle.load(open("edgetrees.pickle",'rb'))
if True: #'A' not in vars():
    A = [[0 for i in etrees] for j in etrees]
    checks=[]
    for i in range(len(etrees)):
        for j in range(i+1,len(etrees)):
	    if abs(len(set(etrees[i]) - set(etrees[j]))) ==1 or abs(len(set(etrees[j]) - set(etrees[i]))) == 1:
                A[i][j] = 1
                A[j][i] = 1

#dnet = DiGraph(matrix(A),format='weighted_adjacency_matrix')
#net = Graph(matrix(A),format='weighted_adjacency_matrix')
