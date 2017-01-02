function [data, trans] = read_data_and_trans(data_filename, trans_filename, data_index) 
    [pathstr,name,ext] = fileparts(data_filename)
    if strcmp(ext,'.txt')
        fid=fopen(trans_filename);
        a=fscanf(fid,'%d %d G%d',[3,inf]);
        trans=zeros(1,a(2,end));
        for j=1:length(a)
            trans(a(1,j):a(2,j))=a(3,j);
        end
        temp = load(data_filename);
        data = temp(1:length(trans),data_index);
    else if strcmp(ext, '.mat')
        load(data_filename,'A', 'Y');
        data = A;
        trans = Y;
    end
end
