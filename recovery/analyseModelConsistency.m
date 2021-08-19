init;

% differentiating parameters
nl = 2;
dw = 20;
mm = 34;
vs=0.4;

% load all files that are similar except their random seed
dircontent = dir(fullfile(basedir, subfolder, sprintf('*BRvEMMC_gp10_lm1_sig4_mu4_ca2_sm2_rm4_in1_im1_cm2_mm%i_od0_ou15_dw%i_nl%i_rs*_ds1_ct5_sc22-V_vs1_vm%.1f*.mat',mm,dw, nl,vs)));
ModelResultsFiles = cell(size(dircontent,1),1);
for a = 1:size(ModelResultsFiles,1)
    ModelResultsFiles{a} = dircontent(a).name;
end


nfiles = size(ModelResultsFiles,1);
fprintf('Loading results\n');
fprintf('---------------\n');

% for i = 1:nfiles
%     % link #column with filename
%     fprintf('Model number %3i - Filename: %s\n', i, ModelResultsFiles{i});
%     load(fullfile(basedir, subfolder,ModelResultsFiles{i}),'amInterventions');
%     % add latent cruve allocation
%     curveallocation(:,i+1) = amInterventions.LatentCurve;
%     rs(:,i+1) = 
% end
% curveallocation(:,1) = amInterventions.IntrNbr;
% ninterventions = size(curveallocation,1);


%-> started to add rs in top row
load(fullfile(basedir, subfolder,ModelResultsFiles{1}),'amInterventions');
ninterventions = size(amInterventions,1);

%%
T = table(amInterventions.IntrNbr,'VariableNames',{'ID'});

for i = 1:nfiles
    % link #column with filename
    fprintf('Model number %3i - Filename: %s\n', i, ModelResultsFiles{i});
    load(fullfile(basedir, subfolder,ModelResultsFiles{i}),'amInterventions','niterations');
    % add latent cruve allocation
    T = addvars(T,amInterventions.LatentCurve);
    temp = split(ModelResultsFiles{i},'_');
    T = renamevars(T,sprintf('Var%i',i+1),temp(17));
    
    Iterations(i,1) = niterations;
    obj = temp{25};
    Obj(i,1) = str2num(obj(4:end-4));
    
end

%% harmonise the class numbers by evaluating 1-1 closeness with each rs taken as reference

Ttest = T;

% identify switching interventions, iterations, smm,
% curve allocation with new indices

% find the rs which has most in common with all
best_match = 2;
% matchmatrix = nan(nrs-1);
% for i = 2:nrs
%     for j = 2:nrs
%         matchmatrix(i-1,j-1) = sum(Ttest{:,i}==1 & Ttest{:,j}==1);
%     end
% end

% put the right latent curve index

changed = zeros(nfiles,1);
for rscol = 2:nfiles+1
    yes1 = Ttest{:,rscol} == 1;
    for i = 2:nfiles+1
        % get logicals
        yes2 = Ttest{:,i} == 1;

        % if yes1 has more in common with not(yes2), rename yes2 indices
        if sum(yes1 & yes2) < sum(yes1 & not(yes2))
            Ttest{yes2,i} = 2;
            Ttest{not(yes2),i} = 1;
            changed(i-1)=1;
        end
    end

    % show different lines
    idx_same = sum(Ttest{:,2:8},2) == nfiles | sum(Ttest{:,2:8},2) == 2*nfiles;
    Same = Ttest(idx_same,:);
    Different = Ttest(not(idx_same),:);

    % more than 2 out of 7 are different
    allowed_false = 2;
    idx_same_almost = sum(Ttest{:,2:8},2) <= nfiles + allowed_false | sum(Ttest{:,2:8},2) >= 2*nfiles - allowed_false;
    SameAlmost = Ttest(idx_same_almost,:);
    VeryDifferent = Ttest(not(idx_same_almost),:);

    OutlierIntr(rscol-1,1) = join(string(VeryDifferent.ID),", ");
    ExactSameClass(rscol-1,1) = sum(idx_same);
    AlmostSame_Less2Err(rscol-1,1) = sum(idx_same_almost);
    Diff_Over3Err(rscol-1,1) = sum(not(idx_same_almost));
end

fprintf('%i interventions have the exact same class\n', size(Same,1));
fprintf('%i interventions are classified similary in %i, %i times out of %i rs\n', size(SameAlmost,1), nfiles-allowed_false, nfiles-allowed_false+1, nfiles);
fprintf('%i interventions are classified have a repartition 3,4 \n', size(VeryDifferent,1));

map(1:nl,1) = 1:nl;
for i = 2:nfiles+1
    map(1:nl,i) = groupcounts(Ttest{:,i});
end
fprintf('Result of the curve allocation for %i interventions:\n',ninterventions);
disp(map)
Class1 = map(1,2:end)';
Class2 = map(2,2:end)';

RSview = table(T.Properties.VariableNames(2:end)',Iterations, Obj, Class1, Class2, ExactSameClass,AlmostSame_Less2Err, Diff_Over3Err,OutlierIntr);

%% draw bar plot of consistency of affilitation to class 1

ref_rs = 'rs3';

Ttest = T;
yes1 = Ttest{:,rscol} == 1;
for i = 2:nfiles+1
    % get logicals
    yes2 = Ttest{:,i} == 1;

    % if yes1 has more in common with not(yes2), rename yes2 indices
    if sum(yes1 & yes2) < sum(yes1 & not(yes2))
        Ttest{yes2,i} = 2;
        Ttest{not(yes2),i} = 1;
        changed(i-1)=1;
    end
end

N_class = sum(Ttest{:,2:nfiles+1}==1,2);
N_class = table(N_class,'VariableNames',{'Class1'});
Grouped = groupcounts(N_class,'Class1');

%% 
figure('DefaultAxesFontSize',16,'Position', [1 1 2000 600])
% Get the table in string form.
TString = evalc('disp(RSview)');
% Use TeX Markup for bold formatting and underscores.
TString = strrep(TString,'<strong>','\bf');
TString = strrep(TString,'</strong>','\rm');
TString = strrep(TString,'_','\_');
% Get a fixed-width font.
FixedWidth = get(0,'FixedWidthFontName');
% Output the table using the annotation command.
annotation(gcf,'Textbox','String',TString,'Interpreter','Tex',...
    'FontName',FixedWidth,'Units','Normalized','Position',[0 0 1 1]);

% uitable('Data',RSview{:,:},'ColumnName',RSview.Properties.VariableNames,...
%     'RowName',RSview.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);

%
subplot(2,2,3)

b = bar(Grouped.Class1,Grouped.GroupCount);
b.FaceColor = 'flat'; 
b.CData(4,:) = [1 0.2 0.2]; b.CData(5,:) = [1 0.2 0.2];
title=sprintf('Consistency of affiliation to class 1 for %i rs (vs=%.1f)',nfiles, vs);
xlabel(title)
ylabel('Number of interventions')
grid('on')
saveas(gcf,fullfile(plotfolder,sprintf('%s.png',title)))
% close all

%% sorted view

% create a mapping for each rs to set the right class, and see which
% interventions are changing class

% now which rs, which index initially

map = sort(map,1);
[temp, order] = sort(map(1,:));
disp(map(:,order));

% if same class size, take the first one and apply most similar
% interventions to this idx (hopefully some interventions are consistently
% in the same class)



%% consistency of the curve allocation for different random seeds
accuracy = zeros(ninterventions,nl);
for i = 1:ninterventions
    accuracy(i,:) = getCurveAllocation(curveallocation(i,2:end),nl);
end

%% function


function out = getCurveAllocation(row,nl)
% return number of latent curves
out = zeros(1,nl);
for i = 1:nl
    for j = row
        if i == j
            out(i) = out(i)+1;
        end
    end
    %out(i) = out(i)*100/length(row);
end

end