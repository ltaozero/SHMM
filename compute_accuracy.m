clear;
%filestr = 'result_KSVD_slave1_dict200_s3_itr_%d.mat';
filestr = 'result_fix_beta_EM_slave1_dict500_beta0.1000_itr_%d.mat';
ntests = 5;
load(sprintf(filestr,1),'conf');
for test_number = 1 : ntests
    fprintf(['Test number ', num2str(test_number) '\n']);
    testfilename=(fullfile([num2str(test_number),'_Out'],['itr_1'],'Test.txt'));
    
    data_filenames = [];
    trans_filenames = [];
    fid = fopen(testfilename);
    tline = fgetl(fid);
    while ischar(tline)
        b = strread(tline,'%s');
        data_filenames = [data_filenames,{fullfile(conf.datapath, [b{2}])}];
        trans_filenames = [trans_filenames,{fullfile(conf.transpath, [b{2}])}];
        tline = fgetl(fid);
    end
    fclose(fid);
    ntrial = length(trans_filenames);
    
    %Trans = cell(1,ntrial);
    len = zeros(1,ntrial);
    for i = 1 : ntrial
        [~, Trans] = read_data_and_trans(data_filenames{i}, trans_filenames{i}, conf.data_index);
        len(i) = sum(ismember(Trans, conf.usedidx));
    end
    len_all{test_number} = len;
end

len_all = cell2mat(len_all);
for rs = 1
    load(sprintf(filestr,rs));
    rate = cell2mat(rate);
    ratebasic = cell2mat(ratebasic);
    avg_rate(rs) = sum(rate.*len_all)/sum(len_all);
    avg_rate_basic(rs) = sum(ratebasic.*len_all) /sum(len_all);
end
avg_rate
avg_rate_basic
