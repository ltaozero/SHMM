'''
For each dataset, plot # activated mp per part per action for each alpha
'''


import scipy.io as sio
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import os
import os.path
import numpy as np
import sys
from mpl_toolkits.axes_grid1 import make_axes_locatable
dataset_idx = int(sys.argv[1])
setup = int(sys.argv[2])
#l1 = float(sys.argv[2])
#layer=int(sys.argv[3])

globalDir = '/home-3/ltao4@jhu.edu/work/Data/California76'
taskset = ['Suturing', 'Knot_Tying','Needle_Passing'];
setupset = ['UserOut','SuperTrialOut']
setupname = setupset[setup]
dataset = taskset[dataset_idx]

s_set = [3]

beta_set = [0.5]

skip_set = [1,10,20,40,80,120,160,320]

#gamma_set = [0,1,10,100]

# l1 o-
# l2 D
# layer 1 m
# layer 3 b
# multiscale .-
pattern = ['cd-','bd-','md-','c*--','b*--','m*--']
legend = []
idx =0
data_source =['all','slave','14dim']
for zeromean in [1]:    
    for slaveonly in [1]:
        source = data_source[slaveonly]
        acc = np.zeros(len(skip_set))
        s=3    
        for i,skip in enumerate(skip_set):
            fname ='result_{}_slave{}_dict{}_s{}_mean{}_itr{}_skip{}.mat'.format('KSVD',slaveonly, 200, s, zeromean, 1,skip)
            if skip is 1:
                fname ='result_{}_slave{}_dict{}_s{}_mean{}_itr{}.mat'.format('KSVD',slaveonly, 200, s, zeromean, 1)
            filename=globalDir+'/Experiments/'+ dataset+'/unBalanced/GestureRecognition/'+setupname+'/'+fname

                                      
            if os.path.isfile(filename):
                print filename
                a=sio.loadmat(filename)
                rate = a['rate'][0]
                rate1=[]
                for r in rate:
                    rate1 +=list(r[0])
                acc[i] = np.mean(rate1)
        # add plot and legend here
        print acc
        plt.plot(acc,pattern[idx],linewidth=3,markersize=8, label='SHMM-KSVD_{}_modelmean'.format(source))
        idx +=1


#ax = plt.gca()

#plt.xlabel('skip length',fontsize=18)
#plt.ylabel('accuracy',fontsize=18)
#plt.xticks(range(6),['10','20','40','80','160','320'])
#plt.legend(loc='lower right')
#plt.title('{}_{}_KSVD_skip_length.png'.format(dataset,setupname))
#plt.savefig('/home-3/ltao4@jhu.edu/scratch/shmm/plots/{}_{}_KSVD_skip_length.png'.format(dataset,setupname))       

#plot fix_beta_EM
#plt.figure()
pattern = ['cd-','bd-','md-','c*--','b*--','m*--']
legend = []
idx =1
data_source =['all','slave','14dim']
for zeromean in [1]:    
    for slaveonly in [1]:
        source = data_source[slaveonly]
        acc = np.zeros(len(skip_set))
        beta=0.5    
        for i,skip in enumerate(skip_set):
            fname ='result_{}_slave{}_dict{}_beta{:6.4f}_mean{}_itr{}_skip{}.mat'.format('fix_beta_EM',slaveonly, 200, beta, zeromean, 1,skip)
            if skip is 1:
                fname='result_{}_slave{}_dict{}_beta{:6.4f}_mean{}_itr{}.mat'.format('fix_beta_EM',slaveonly, 200, beta, zeromean,1)

            filename=globalDir+'/Experiments/'+ dataset+'/unBalanced/GestureRecognition/'+setupname+'/'+fname

                                      
            if os.path.isfile(filename):
                print filename
                a=sio.loadmat(filename)
                rate = a['rate'][0]
                rate1=[]
                for r in rate:
                    rate1 +=list(r[0])
                acc[i] = np.mean(rate1)
        # add plot and legend here
        print acc
        plt.plot(acc,pattern[idx],linewidth=3,markersize=8, label='SHMM-AEM_{}_modelmean'.format(source))
        idx +=1

pattern = ['cd-','bd-','md-','c*--','b*--','m*--']
legend = []
data_source =['all','slave','14dim']
for zeromean in [1]:    
    for slaveonly in [1]:
        source = data_source[slaveonly]
        acc = np.zeros(len(skip_set))
        b=1e6    
        for i,skip in enumerate(skip_set):
            fname ='result_{}_slave{}_dict{}_a{:6.4f}_b{:6.4f}_mean{}_itr{}_skip{}.mat'.format('Bayesian',slaveonly, 200, 10*b,b, zeromean, 1,skip)
            if skip is 1:
                fname='result_{}_slave{}_dict{}_a{:6.4f}_b{:6.4f}_mean{}_itr{}.mat'.format('Bayesian',slaveonly, 200, 10*b,b, zeromean,1)

            filename=globalDir+'/Experiments/'+ dataset+'/unBalanced/GestureRecognition/'+setupname+'/'+fname

                                      
            if os.path.isfile(filename):
                print filename
                a=sio.loadmat(filename)
                rate = a['rate'][0]
                rate1=[]
                for r in rate:
                    rate1 +=list(r[0])
                acc[i] = np.mean(rate1)
        # add plot and legend here
        print acc
        plt.plot(acc,pattern[idx],linewidth=3,markersize=8, label='BSHMM_{}_modelmean'.format(source))
        idx +=1

ax = plt.gca()

#ax.set_ylim(ylim)
plt.xlabel('skip_length',fontsize=18)
plt.ylabel('accuracy',fontsize=18)
plt.xticks(range(8),['1','10','20','40','80','120','160','320'])
plt.legend(loc='lower right')
plt.title('{}_{}:performance for different skip length'.format(dataset,setupname))
#plt.title('{}_accuracy_for_different_dictsize_l1{}_layer{}'.format(dataset,nword,layer))
#os.mkdir('/home-3/ltao4@jhu.edu/scratch/mp_journal/plots/{}'.format(dataset))
plt.savefig('/home-3/ltao4@jhu.edu/scratch/shmm/plots/{}_{}_skip_length.png'.format(dataset,setupname))       

