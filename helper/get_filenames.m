function [data_filenames, trans_filenames] = get_filenames(trainfilename, conf,split)
data_filenames = [];
trans_filenames = [];

fid = fopen(trainfilename);
tline = fgetl(fid);
while ischar(tline)
    b = strread(tline,'%s');
    if conf.task_index <=3
        data_filenames = [data_filenames,{fullfile(conf.data_params.datapath, [b{2}])}];
        trans_filenames = [trans_filenames,{fullfile(conf.data_params.transpath, [b{2}])}];
    else
        data_filenames = [data_filenames,{fullfile(conf.data_params.datapath,['Split_',num2str(split)], ['rgb-',b{1},'.avi.mat'])}];
        trans_filenames = [trans_filenames,{fullfile(conf.data_params.transpath,['Split_',num2str(split)], ['rgb-',b{1},'.avi.mat'])}];
    end
    tline = fgetl(fid);
     

end

fclose(fid);

end
