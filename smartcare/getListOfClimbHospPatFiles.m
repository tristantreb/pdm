function [patfilelist] = getListOfClimbHospPatFiles(basedir, subfolder)

% getListOfClimbHospPatFiles - returns a cell array containing the list of
% patient clinical data files for a given climb hospital

patfilelisting = dir(fullfile(basedir, subfolder, '*.xls'));
patfilelist = cell(size(patfilelisting,1),1);
for a = 1:size(patfilelist,1)
    patfilelist{a} = patfilelisting(a).name;
end

end

