function [info] = canlab_glm_getinfo(modeldir,varargin)
%
% SUBJECT LEVEL input
% INFO = canlab_glm_getinfo(spm_subject_level_directory, option, [n])
% Get information out of an spm subject level analysis.
%
% OPTIONS (each option can be called by the listed letter or word + a number, when noted)
%  'i' 'input'             number of volumes and (first) volume name for each run
%  'b' 'betas' [n]         beta names (for nth session)     
%  'B' 'taskbetas' [n]     beta names (that didn't come from multiple regressors)  (for nth session)
%  'c' 'cons' [n]          contrast names (for nth contrast)
%  'C' 'conw' [n]          beta names and weights for contrasts (for nth con)
%  'v' 'image' [n]         create figure of design matrix (for nth session)
%                            (design matrix is multiplied by 100 for visibility)
%                            (works well for multiple runs)
%  'V' 'taskimage' [n]     same as 'image', but only for task betas
%  'imagesc'               same as 'image', but uses imagesc
%                            (works well for single runs)
%
%
% GROUP LEVEL input
% INFO = canlab_glm_getinfo(robfit_group_level_directory, option, [n])
% Get information out of a robfit group level analysis.
%
% OPTIONS (each option can be called by the listed word or letter + a number, when noted)
%  Any of the subject level options can be used on a group level robfit
%    analysis by prefixing '1i' (output is generated based on the first input
%    to the first robust analysis).
%  EX: canlab_glm_getinfo('second_level/model3','1iconw')
%
%  'i' 'input' [n]        input contrasts by number and name (for nth analysis)
%  'I' 'allinput' [n]     input images (for nth analysis)
%  'm' 'model'            weights by subject (i.e., directory containing input contrast images)
%  'M' 'allmodels' [n]    weights and input images (for nth analysis)
%
%  ASSUMPTIONS: In some options, the first contrasts and group level analysis
%    directories are assumed to represent the rest, which may not be the
%    case.
%  NOTE: group level options do not yet return a usable INFO struct.
%

if nargin ~= 2 && nargin ~= 3
    error('USAGE: INFO = canlab_glm_getinfo(spm_dir|robfit_dir,option,[n])')
end

opt = varargin{1};
if nargin == 3, s = varargin{2}; else s = 0; end

if ~exist(modeldir,'dir')
    error('No such directory: %s',modeldir)
else
    spmmat = fullfile(modeldir,'SPM.mat');
    setupmats = filenames(fullfile(modeldir,'robust[0-9][0-9][0-9][0-9]','SETUP.mat'));
    if exist(spmmat,'file')
        info = get_subject_level_info(modeldir,opt,s);
    elseif ~isempty(setupmats)
        if regexp(opt,'^1i')
            load(setupmats{1});
            firstinput = fileparts(deblank(SETUP.files(1,:)));
            info = get_subject_level_info(firstinput,regexprep(opt,'^1i',''),s);
        else
            info = get_group_level_info(modeldir,opt,s);
        end            
    else
        error('%s is neither a subject level SPM directory nor a group level robfit directory',modeldir);
    end
end


end


function [info] = get_subject_level_info(modeldir,opt,s)

load(fullfile(modeldir,'SPM'));

switch opt
    case {'c' 'con' 'cons'}
        if s
            info.contrast_name{1} = SPM.xCon(s).name;
        else            
            info.contrast_name = cellstr(strvcat(SPM.xCon.name));  %#ok
        end
        
        fprintf('CONTRASTS:\n')
        for i=1:numel(info.contrast_name)
            fprintf('%4d %s\n',i,info.contrast_name{i});
        end
        
    case {'C' 'conw' 'consw'}
        if s
            info.contrast_name{1} = SPM.xCon(s).name;
            info.beta_numbers{1} = find(SPM.xCon(s).c);
            info.beta_names{1} = cellstr(strvcat(SPM.xX.name{info.beta_numbers{1}})); %#ok
            info.beta_weights{1} = SPM.xCon(s).c(info.beta_numbers{1});
        else            
            info.contrast_name = cellstr(strvcat(SPM.xCon.name)); %#ok            
            info.contrast_num = 1:numel(info.contrast_name);
            for i = 1:numel(info.contrast_name);
                info.beta_numbers{i} = find(SPM.xCon(i).c);
                info.beta_names{i} = cellstr(strvcat(SPM.xX.name{info.beta_numbers{i}})); %#ok
                info.beta_weights{i} = SPM.xCon(i).c(info.beta_numbers{i});
            end
        end
        
        for s = 1:numel(info.contrast_name)
            fprintf('%3d: %s:\n',s,info.contrast_name{s})
            for i=1:numel(info.beta_names{s})
                fprintf('\t%10.5f\t%s\n',info.beta_weights{s}(i),info.beta_names{s}{i});
            end
        end
        
        
    case {'b' 'betas'}
        if s
            info.beta_number = find(~cellfun('isempty',regexp(SPM.xX.name,sprintf('^Sn\\(%d\\)',s))))';
            info.beta_name = cellstr(strvcat(SPM.xX.name{info.beta_number})); %#ok
        else
            info.beta_name = cellstr(strvcat(SPM.xX.name)); %#ok
            info.beta_number = [1:numel(info.beta_name)]'; %#ok
        end
        
        for i = 1:numel(info.beta_name)
            fprintf('%4d %s\n',info.beta_number(i),info.beta_name{i});
        end
        
        
    case {'B' 'taskbetas'}
        n = cellfun('isempty',regexp(SPM.xX.name,' R[0-9]*$'))';
        if s
            n = n .* ~cellfun('isempty',regexp(SPM.xX.name,sprintf('^Sn\\(%d\\)',s)))';
        end
        info.beta_number = find(n);
        info.beta_name = cellstr(strvcat(SPM.xX.name{info.beta_number})); %#ok
        
        for i = 1:numel(info.beta_number)
            fprintf('%4d %s\n',info.beta_number(i),info.beta_name{i});
        end
        
        
%     case {'cond' 'consd'}
%         info = {};
%         if s
%             info.condition_name{1} = {};
%             for i = 1:numel(SPM.Sess(s).U)
%                 info.condition_name{1}{end+1} = SPM.Sess(s).U(i).name{1};
%             end
%         else
%             for s = 1:numel(SPM.Sess)
%                 info.condition_name{s} = {};
%                 for i = 1:numel(SPM.Sess(s).U)
%                     info.condition_name{s}{end+1} = SPM.Sess(s).U(i).name{1};
%                 end
%             end
%         end
%         
%         fprintf('%4s %4s %s\n','sess','n','condition')
%         for s = 1:numel(info.condition_name)
%             for i = 1:numel(info.condition_name{s})
%                 fprintf('%4d %4d %s\n',s,i,info.condition_name{s}{i})
%             end
%         end
        
        
    case 'nsess'
        info.nsess = numel(SPM.Sess);
        fprintf('%d\n',info.nsess);
        
        
    case {'i' 'input' 'sess'}
        info.nsess = numel(SPM.nscan);
        info.nscan = SPM.nscan;
        
        n=1; for i=1:info.nsess, first(i)=n; n=n+info.nscan(i); end %#ok
        
        fprintf('%4s %5s  %s\n','sess','nscan','first_volume_name')
        for i = 1:numel(first)
            info.first_volume_name{i} = SPM.xY.VY(first(i)).fname;
            fprintf('%4d %5d  %s\n',i,info.nscan(i),info.first_volume_name{i})
        end
        
        
    case {'v' 'image'}
        info = 'N/A';
        if s
            canlab_glm_getinfo(modeldir,'betas',s);
            figure; image(SPM.xX.X(SPM.Sess(s).row,SPM.Sess(s).col) * 40)
            colormap('Bone');
        else
            canlab_glm_getinfo(modeldir,'betas');
            figure; image(SPM.xX.X * 40)
            colormap('Bone');
        end
        
    case {'V' 'taskimage'}
        info = 'N/A';
        n = cellfun('isempty',regexp(SPM.xX.name,' R[0-9]*$'));
        if s
            canlab_glm_getinfo(modeldir,'taskbetas',s);
            n = n .* ~cellfun('isempty',regexp(SPM.xX.name,['^Sn\(' num2str(s) '\)']));
            n = find(n);
            figure; image(SPM.xX.X(SPM.Sess(s).row,n) * 40) %#ok
            colormap('Bone');
        else
            canlab_glm_getinfo(modeldir,'taskbetas');
            n = find(n);
            figure; image(SPM.xX.X(:,n) * 100) %#ok
            colormap('Bone');
        end
        
    case {'vsc' 'imagesc'}
        info = 'N/A';
        spmlowerinfo(modeldir,'betas')
        if s
            canlab_glm_getinfo(modeldir,'betas',s)
            figure; imagesc(SPM.xX.X(SPM.Sess(s).row,SPM.Sess(s).col))
            colormap('Bone');
        else
            canlab_glm_getinfo(modeldir,'betas')
            figure; imagesc(SPM.xX.X)
            colormap('Bone');
        end
        
        
    otherwise
        error('Unrecognized option for spm lower level analyses: %s',opt)
end 

end

function [info] = get_group_level_info(modeldir,opt,s)

info = [];

% load SETUP structs
f = filenames(fullfile(modeldir,'robust[0-9][0-9][0-9][0-9]'));
for i=1:numel(f),
    load(fullfile(f{i},'SETUP'));
    SETUPS(i) = SETUP; %#ok
    clear SETUP
end

switch opt
    case {'i' 'input'}
        % load lower levels        
        evalc('tmp = canlab_glm_getinfo(fileparts(SETUPS(i).V(1).fname),''cons'');');
        connames = tmp.contrast_name;
        if ~s, s = 1:numel(SETUPS); end
        fprintf('%-12s %-12s %-s\n','dir','input_con','con_name')        
        for i = s          
            [find finf] = fileparts(SETUPS(i).V(1).fname);
            
            fprintf('%-12s',SETUPS(i).dir)
            fprintf(' %-12s',finf)
            if regexp(finf,'^con_')
                fprintf(' "%-s"',connames{str2num(regexprep(finf,'^con_',''))}) %#ok
            end
            fprintf('\n')
        end
    case {'I' 'allinput'}
        if ~s, s = 1:numel(SETUPS); end
        for i = s
            fprintf('%s:\n',SETUPS(i).dir)
            disp(SETUPS(i).files)
        end
    case {'m' 'model'}
        fprintf('weight input\n')
        for i = 1:numel(SETUPS(1).X)
            fprintf('%-7.3f %s\n',SETUPS(1).X(i),regexprep(SETUPS(1).V(i).fname,'/[^/]*$',''))
        end
    case {'M' 'allmodels'}
        if ~s, s = 1:numel(SETUPS); end
        for m = s
            fprintf('%s\n',SETUPS(m).dir)
            fprintf('weight input\n')
            for i = 1:numel(SETUPS(m).X)
                fprintf('%-7.3f %s\n',SETUPS(m).X(i),SETUPS(m).V(i).fname)
            end
        end
        
    otherwise
        error('Unrecognized option for robfit analyses: %s',opt)
end



end
        
        