% Example script for LOS cross validation
% INPUT:task_index, setup_index, globalDir
%  globalDir = '~/lab/Data/California76/';
%  task_index = 1;
%  setup_index = 1;

addpath ~/lab/matlab_toolbox/MPPCA/
addpath helper
% cross_validation parameters
taskset = {'Suturing', 'Needle_Passing', 'Knot_Tying'};
setupset = {'UserOut', 'SuperTrialOut'};
ntest_set = [8,5];
surgemes_set = { [1:6,8:11],[1,11:15],[1:6,8,9,10,11]};
setuptask = taskset{task_index};
setupname = setupset{setup_index};
ntests = ntest_set(setup_index);

% set conf parameters
conf.datapath = [globalDir,'/data/' setuptask '/california76/AllGestures/'];
conf.transpath = [globalDir,'/data/' setuptask '/transcriptions_final/'];
conf.usedidx = surgemes_set{task_index};
conf.num_sub = 5;
conf.latent_dim = 10;
conf.data_index = [1:76];

predicted_labels = cell(1, ntests); rate = cell(1,ntests);
for test_number = 1 : ntests
            trainfilename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
            [num2str(test_number),'_Out'],'itr_1','Train.txt'));
            testfilename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
            [num2str(test_number),'_Out'],'itr_1','Test.txt'));
            result_filename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
            [num2str(test_number),'_Out'],'itr_1','result.mat'));
            model = MFA_train(trainfilename, conf);
            [predicted_labels{test_number}, rate{test_number}] = MFA_test(testfilename, conf, model,[]);           
end
