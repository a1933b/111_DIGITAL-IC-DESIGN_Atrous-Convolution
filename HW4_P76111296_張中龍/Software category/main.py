import numpy as np
import cv2 


def outputdat(name,size,img):
    path = name
    file = open(path, 'w')

    for i in range(size):
        for j in range(size):
            k = img.item(i,j)
            binintf=bin(int(k))[2:]
            floatf=k-int(k)
            floatf=floatf*16
            binff=bin(int(floatf))[2:]
            for t in range(0,(4-len(binff))) :
                binff=str('0')+binff
            strbin=binintf+binff
            finalstr=strbin
            for t in range(0,(13-len(strbin))) :
                finalstr=str('0')+finalstr
            file.write(finalstr+'\n')
    file.close()



img = cv2.imread('./image.png',0)
# img = cv2.imread('si.png')
# img=cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
img = cv2.resize(img, (64, 64), interpolation=cv2.INTER_NEAREST	)
outputdat('img.dat',64,img)
# img = cv2.resize(img, (64, 64), interpolation=cv2.INTER_AREA)
# cv2.imwrite('si.png', img)




# ### output img.dat


# ###
### padding 2
imgo = np.zeros([68,68],dtype=np.uint8)
layer0out = np.zeros([64,64],dtype=np.float32)


imgo[2:66,2:66]=img

for i in range(2):
    # up
    for col in range(2-i,66+i):
        imgo[1-i,col]=imgo[2-i,col]
    # down
    for col in range(2-i,66+i):
        imgo[66+i,col]=imgo[65+i,col]
    for row in range(2-i,66+i):
        imgo[row,1-i]=imgo[row,2-i]
    for row in range(2-i,66+i):
        imgo[row,66+i]=imgo[row,65+i]
    imgo[1-i,1-i]=imgo[2-i,2-i]
    imgo[66+i,66+i]=imgo[65+i,65+i]
    imgo[1-i,66+i]=imgo[2-i,65+i]
    imgo[66+i,1-i,]=imgo[65+i,2-i]
###layer0 out

for row in range(2,66):
    for col in range(2,66):
        temp=(imgo[row-2,col-2]*(-0.0625)+imgo[row-2,col]*(-0.125)+imgo[row-2,col+2]*(-0.0625)
        +imgo[row,col-2]*(-0.25)+ imgo[row,col]*1 +imgo[row,col+2]*(-0.25)
        +imgo[row+2,col-2]*(-0.0625)+imgo[row+2,col]*(-0.125)+imgo[row+2,col+2]*(-0.0625))
        temp=temp-0.75
        if(temp<0): temp=0
        layer0out[row-2,col-2]=temp
# cv2.imwrite('layer0out.png', layer0out)
outputdat('layer0_golden.dat',64,layer0out)

layer1out = np.zeros([32,32],dtype=np.float32)

for row in range(0,64,2):
    for col in range(0,64,2):
        layer1out[int(row*0.5),int(col*0.5)]=np.ceil(max(layer0out[row,col],layer0out[row+1,col],layer0out[row,col+1],layer0out[row+1,col+1]))
outputdat('layer1_golden.dat',32,layer1out)


# cv2.imwrite('layer1out.png', layer1out)


