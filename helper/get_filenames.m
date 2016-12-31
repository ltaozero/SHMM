function [data_filenames, trans_filenames] = get_filenames(trainfilename, conf)
data_filenames = [];
trans_filenames = [];
fid = fopen(trainfilename);
tline = fgetl(fid);
while ischar(tline)
    b = strread(tline,'%s');
    data_filenames = [data_filenames,{fullfile(conf.datapath, [b{2}])}];
    trans_filenames = [trans_filenames,{fullfile(conf.transpath, [b{2}])}];
    tline = fgetl(fid);
end
fclose(fid);

end
