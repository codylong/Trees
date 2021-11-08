box = 10
frac
for l1 in range(1,box):
    for l2 in range(box):
        for l3 in range(box):
            fmin = 4 + l2/l1*(1-4)+l3/l1*(1-4)
            if fmin > 1: print l1, l2, l3, fmin
