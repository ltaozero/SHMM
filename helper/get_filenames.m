function [data_filenames, trans_filenames] = get_filenames(trainfilename, conf)
data_filenames = [];
trans_filenames = [];
fid = fopen(trainfilename);
tline = fgetl(fid);
while ischar(tline)
    b = strread(tline,'%s');
    if conf.task_index <=3
        data_filenames = [data_filenames,{fullfile(conf.datapath, [b{2}])}];
        trans_filenames = [trans_filenames,{fullfile(conf.transpath, [b{2}])}];
    else
        data_filenames = [data_filenames,{fullfile(conf.datapath, ['rgb-',b{1},'.avi.mat'])}];
        trans_filenames = [trans_filenames,{fullfile(conf.transpath, ['rgb-',b{1},'.avi.mat'])}];
    tline = fgetl(fid);
end
fclose(fid);

end
