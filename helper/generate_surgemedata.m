function[S, trr]= generate_surgemedata(data_filenames,trans_filenames,usedidx, data_index, expertise)
    
    ntrial = length(data_filenames);
    if (length(trans_filenames)~=ntrial)
        error('Number of data files does not equal number of transcription files');
    end
    data = cell(1,ntrial);
    Trans = cell(1,ntrial);
    for i = 1 : ntrial
      [data{i}, Trans{i}] = read_data_and_trans(data_filenames{i}, trans_filenames{i}, data_index);
    end
 
            
     
    S=cell(max(usedidx),3);
    trr=cell(max(usedidx),3);
    %expertise=[ones(10,1);2*ones(10,1);3*ones(19,1)];
    %expertise=[3*ones(5,1);2*ones(5,1);1*ones(10,1);2*ones(5,1);3*ones(14,1)];
    for i=1:ntrial

        for j=1:max(usedidx)
            S{j,expertise(i)}=[S{j,expertise(i)};data{i}(Trans{i}==j,:)];
            trr{j,expertise(i)}=[trr{j,expertise(i)};i*ones(sum(Trans{i}==j),1)];
        end  
    end
    %save(surgemepath,'S');
    %save(trrpath,'trr');

end