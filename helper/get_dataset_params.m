function data_params = get_dataset_params(task_index, setup_index, conf)
    taskset = {'Suturing', 'Knot_Tying','Needle_Passing','50Salads_eval','50Salads_mid'};
    setupset = {'UserOut', 'SuperTrialOut'};
    ntest_set = [8,5];
    % Note: change the used surgeme in Needle passing from [1:6,8:11], to
    % [1:6,8,11].
    surgemes_set = { [1:6,8:11],[1,11:15],[1:6,8,11],[0:9],[0:17]};
    data_params.setuptask = taskset{task_index};
    data_params.setupname = setupset{setup_index};
    data_params.ntests = ntest_set(setup_index);
    data_params.usedidx = surgemes_set{task_index};
    if task_index >3
        data_params.ntests = 5
        conf.slaveonly = -1
    end

    switch slaveonly
        case 1
            data_params.data_index = [39:76];
        case 0
            data_params.data_index = [1:76];
        case 2
            data_params.data_index = [39:41,54:57,58:60,73:76];
        otherwise
            % by default use all data
            data_params.data_index=[];
    end

    if task_index <=3
        data_params.datapath = [globalDir,'California76/data/' setuptask '/california76/AllGestures_norm/'];
        data_params.transpath = [globalDir,'California76/data/' setuptask '/transcriptions_final/'];
        data_params.trainfilename_str=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
                ['%s_Out'],['itr_1'],'Train.txt'));
        data_params.testfilename_str=(fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname,...
                ['%s_Out'],['itr_1'],'Test.txt'));
    else
        data_params.datapath = [globalDir, setuptask];
        data_params.transpath =  [globalDir, setuptask];
        data_params.trainfilename_str=(fullfile(globalDir, setuptask,'Experiments',...
                'Split_%s','Train.txt'));
        data_params.testfilename_str=(fullfile(globalDir, setuptask,'Experiments',...
                'Split_%s','Test.txt'));
    end


    



    fprintf(conf.dict_type)
    % first create result_dir
    if task_index <=3
        result_dir = fullfile(globalDir,'Experiments', setuptask,'unBalanced/GestureRecognition',setupname);
    else 
        result_dir = fullfile(globalDir, setuptask, 'Experiments')
    end

    switch conf.dict_type
        case 'fix_beta_EM'
            result_filename=(fullfile(result_dir, ...
               sprintf('result_%s_slave%d_dict%d_beta%1.4f_mean%d_itr%d',conf.dict_type,slaveonly, conf.dict_size, conf.beta, conf.zeromean, conf.rs)));
           
        case 'KSVD'
            result_filename=(fullfile(result_dir, ...
               sprintf('result_%s_slave%d_dict%d_s%d_mean%d_itr%d', conf.dict_type,slaveonly, conf.dict_size, conf.sparsity,conf.zeromean, conf.rs)));
        case 'Bayesian'
            result_filename=(fullfile(result_dir,...
               sprintf('result_%s_slave%d_dict%d_a%1.4f_b%1.4f_mean%d_itr%d', conf.dict_type,slaveonly, conf.dict_size, conf.param.a, conf.param.b,conf.zeromean, conf.rs)));  
    end
    fprintf(result_filename);   
    if conf.skip>1
      result_filename = sprintf('%s_skip%d',result_filename,conf.skip);
    end
    data_params.result_filename = strcat(result_filename,'.mat');