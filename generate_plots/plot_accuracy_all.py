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

s_set = [3,5,7,9,11]

beta_set = [0.1,0.5,1,2,5,10]

b_set = [1,10,100,1e3,1e4,1e5,1e6,1e7]



def get_acc(filename):
    a=sio.loadmat(filename)
    rate = a['rate'][0]
    rate1=[]
    length = []
    for r in rate:
        rate1 +=list(r[0])
    for predictions in a['predicted_labels'][0]:
        for pred in predictions[0]:
            length += [pred.shape[1]]
    acc = np.sum(rate1*np.array(length))/np.sum(length)
    return acc
    
# l1 o-
# l2 D
# layer 1 m
# layer 3 b
# multiscale .-
pattern = ['cd-','bd-','c*--','b*--']
legend = []
idx =0
data_source =['all','slave','14dim']
for zeromean in [0,1]:    
    for slaveonly in [0,1]:
        source = data_source[slaveonly]
        acc = np.zeros(len(s_set))
            
        for i,s in enumerate(s_set):
            fname ='result_{}_slave{}_dict{}_s{}_mean{}_itr{}.mat'.format('KSVD',slaveonly, 200, s, zeromean, 1)

            filename=globalDir+'/Experiments/'+ dataset+'/unBalanced/GestureRecognition/'+setupname+'/'+fname

                                      
            if os.path.isfile(filename):
                print filename
                acc[i] = get_acc(filename)        
        # add plot and legend here
        print acc
        labelstr = source
        if zeromean:
            labelstr += '_modelmean'
        plt.plot(acc,pattern[idx],linewidth=3,markersize=8, label=labelstr)
        idx +=1


ax = plt.gca()

#ax.set_ylim(ylim)
plt.xlabel('sparsity level',fontsize=18)
plt.ylabel('accuracy',fontsize=18)
plt.xticks(range(5),['3','5','7','9','11'])
plt.legend(loc='lower right')
plt.title('{}_{}: SHMM-KSVD performance'.format(dataset,setupname))
#plt.title('Performance on {}'.format(dataset),fontsize=24)
#plt.title('{}_accuracy_for_different_dictsize_l1{}_layer{}'.format(dataset,nword,layer))
#os.mkdir('/home-3/ltao4@jhu.edu/scratch/mp_journal/plots/{}'.format(dataset))
plt.savefig('/home-3/ltao4@jhu.edu/scratch/shmm/plots/{}_{}_KSVD_performance.png'.format(dataset,setupname))       

#plot fix_beta_EM
plt.figure()
legend = []
idx =0
data_source =['all','slave','14dim']
for zeromean in [0,1]:    
    for slaveonly in [0,1]:
        source = data_source[slaveonly]
        acc = np.zeros(len(beta_set))
            
        for i,beta in enumerate(beta_set):
            fname ='result_{}_slave{}_dict{}_beta{:6.4f}_mean{}_itr{}_new.mat'.format('fix_beta_EM',slaveonly, 200, beta, zeromean, 1)

            filename=globalDir+'/Experiments/'+ dataset+'/unBalanced/GestureRecognition/'+setupname+'/'+fname

                                      
            if os.path.isfile(filename):
                print filename
                acc[i] = get_acc(filename)
        # add plot and legend here
        print acc
        labelstr=source
        if zeromean:
            labelstr += '_modelmean'
        plt.plot(acc,pattern[idx],linewidth=3,markersize=8, label=labelstr)
        idx +=1


ax = plt.gca()

#ax.set_ylim(ylim)
plt.xlabel('regularizer weight',fontsize=18)
plt.ylabel('accuracy',fontsize=18)
plt.xticks(range(6),['0.1','0.5','1','2','5','10'])
plt.legend(loc='lower right')
plt.title('{}_{}: SHMM-AEM performance'.format(dataset,setupname))
#plt.title('{}_accuracy_for_different_dictsize_l1{}_layer{}'.format(dataset,nword,layer))
#os.mkdir('/home-3/ltao4@jhu.edu/scratch/mp_journal/plots/{}'.format(dataset))
plt.savefig('/home-3/ltao4@jhu.edu/scratch/shmm/plots/{}_{}_fixBeta_performance.png'.format(dataset,setupname))       

plt.figure()
legend = []
idx =0
data_source =['all','slave','14dim']
for zeromean in [0,1]:    
    for slaveonly in [0,1]:
        source = data_source[slaveonly]
        acc = np.zeros(len(b_set))
            
        for i,b in enumerate(b_set):
            fname ='result_{}_slave{}_dict{}_a{:6.4f}_b{:6.4f}_mean{}_itr{}.mat'.format('Bayesian',slaveonly, 200, 10*b,b, zeromean, 1)

            filename=globalDir+'/Experiments/'+ dataset+'/unBalanced/GestureRecognition/'+setupname+'/'+fname

                                      
            if os.path.isfile(filename):
                print filename
                acc[i] = get_acc(filename)
        # add plot and legend here
        labelstr=source
        if zeromean:
            labelstr += '_modelmean'
        plt.plot(acc,pattern[idx],linewidth=3,markersize=8, label=labelstr)
        idx +=1


ax = plt.gca()

#ax.set_ylim(ylim)
plt.xlabel('b',fontsize=18)
plt.ylabel('accuracy',fontsize=18)
plt.xticks(range(8),['1','10','1e2','1e3','1e4','1e5','1e6','1e7'])
plt.legend(loc='lower right')
plt.title('{}_{}: BSHMM performance'.format(dataset,setupname))
#plt.title('{}_accuracy_for_different_dictsize_l1{}_layer{}'.format(dataset,nword,layer))
#os.mkdir('/home-3/ltao4@jhu.edu/scratch/mp_journal/plots/{}'.format(dataset))
plt.savefig('/home-3/ltao4@jhu.edu/scratch/shmm/plots/{}_{}_bayesian_performance.png'.format(dataset,setupname))       


