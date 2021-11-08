count = 0

def goforit(gb,pr):
    print gb, pr
    if gb[0]==3:
        pr = pr * 3
        goforit([2,gb[1]+3],pr)
    if gb[0]==2:
        pr = pr * 2
        goforit([1,gb[1]+2],pr)
    if gb[0]==1:
        pr = pr * 1
        goforit([0,gb[1]+1],pr)
    if gb[1]>0:
        pr = pr * gb[1]
        goforit([gb[0],gb[1]-1],pr)
    if gb==[0,0]: print pr
    
GB = [3,0]
goforit(GB,1)
