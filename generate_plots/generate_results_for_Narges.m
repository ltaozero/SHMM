globalDir = '/home-3/ltao4@jhu.edu/work/Data/California76'
taskset = {'Suturing', 'Knot_Tying','Needle_Passing'};
setupset = {'UserOut', 'SuperTrialOut'};
ntest_set = [8,5];
% Note: change the used surgeme in Needle passing from [1:6,8:11], to
% [1:6,8,11].
surgemes_set = { [1:6,8:11],[1,11:15],[1:6,8,11]};
setuptask = taskset{task_index};
setupname = setupset{setup_index};
ntests = ntest_set(setup_index);
if exist('sparsity','var')
    conf.sparsity = sparsity;
end
conf.skip = 1;
conf.dict_size = 200;
conf.dict_type = 'KSVD';
slaveonly = 1;
zeromean=1;

switch slaveonly
    case 1
        conf.data_index = [39:76];
    case 0
        conf.data_index = [1:76];
    case 2
        conf.data_index = [39:41,54:57,58:60,73:76];
    otherwise
        % by default use all data
        conf.data_index=[1:76];
end

% set conf parameters
% use normalized data
conf.rs = 1;
conf.datapath = [globalDir,'/data/' setuptask '/california76/AllGestures_norm/'];
conf.transpath = [globalDir,'/data/' setuptask '/transcriptions_final/'];
conf.usedidx = surgemes_set{task_index};
conf.cross_valid = 1;
conf.zeromean = zeromean;
if conf.cross_valid ==0
    conf.default_sigma = 2.0;
    conf.default_lambda = 0.01;
end

% load data
fprintf(conf.dict_type)
switch conf.dict_type
    case 'fix_beta_EM'
result_filename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
           sprintf('result_%s_slave%d_dict%d_beta%1.4f_mean%d_itr%d',conf.dict_type,slaveonly, conf.dict_size, conf.beta, conf.zeromean, conf.rs)));
    fprintf(result_filename);   
    case 'KSVD'
result_filename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
           sprintf('result_%s_slave%d_dict%d_s%d_mean%d_itr%d', conf.dict_type,slaveonly, conf.dict_size, conf.sparsity,conf.zeromean, conf.rs)));
    fprintf(result_filename);   
    case 'Bayesian'
    result_filename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
           sprintf('result_%s_slave%d_dict%d_a%1.4f_b%1.4f_mean%d_itr%d', conf.dict_type,slaveonly, conf.dict_size, conf.param.a, conf.param.b,conf.zeromean, conf.rs)));
    fprintf(result_filename);   
end

result_filename = strcat(result_filename,'.mat');


load(result_filename)


for test_number = 1 : ntests
            fprintf(['Test number ', num2str(test_number) '\n']);
            trainfilename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
            [num2str(test_number),'_Out'],['itr_1'],'Train.txt'));
            testfilename=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
            [num2str(test_number),'_Out'],['itr_1'],'Test.txt'));
            data_filenames = [];
            trans_filenames = [];
            fid = fopen(testfilename);
            tline = fgetl(fid);
            while ischar(tline)
              b = strread(tline,'%s');
              data_filenames = [data_filenames,{b{2}}];
              trans_filenames = [trans_filenames,{b{2}}];
              tline = fgetl(fid);
            end
            fclose(fid); 
            %write result here
            if (length(trans_filenames)~=length(predicted_labels{test_number}))
                  error('Number of data files does not equal number of transcription files');
            end
            for i = 1:length(trans_filenames)
              result_dir = fullfile(globalDir,'SHMM', setuptask,'unBalanced/GestureRecognition',setupname,...
            [num2str(test_number),'_Out'],['itr_1'],['result_s',num2str(conf.sparsity)]);
              if ~exist(result_dir,'dir')
                system(sprintf('mkdir -p %s', result_dir))
              end

              result_filename = fullfile(result_dir, trans_filenames{i})
              fid = fopen(result_filename,'w');
              trans = predicted_labels{test_number}{i};
              switch_idx = find(trans(2:end)~=trans(1:end-1));
              switch_idx = [0,switch_idx, length(trans)];
              for j = 1:length(switch_idx)-1
                fprintf(fid,'%d %d G%d\n', switch_idx(j)+1,switch_idx(j+1), trans(switch_idx(j)+1));
              end
              fclose(fid);
            end
end


