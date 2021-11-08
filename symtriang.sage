charges = [[-1,-1,-1,1,0,0,0],
           [-1,-1,0,-1,1,0,0],
           [-1,0,-1,-1,0,1,0],
           [0,-1,-1,-1,0,0,1]]

def dot(v1,v2):
    c = 0
    for i in range(len(v1)): c += v1[i]*v2[i]
    return c

def scan7Exp(Q, box): # Q is charge matrix
    fexps, gexps = [], []
    fvec = matrix([-2,-2,-2,-2]).transpose()
    gvec = matrix([-12,-12,-12,-12]).transpose()
                                                            
    for i1 in range(box):
        for i2 in range(box):
            for i3 in range(box):
                for i4 in range(box):
                    for i5 in range(box):
                        for i6 in range(box):
                            for i7 in range(box):
                                exp = [i1,i2,i3,i4,i5,i6,i7]
                                if matrix(charges)*matrix(exp).transpose() == fvec:
                                    fexps.append(exp)
                                if matrix(charges)*matrix(exp).transpose() == gvec:
                                    gexps.append(exp)
    
    print matrix(fexps)
    print matrix(gexps)

scan7Exp(charges, 4)
