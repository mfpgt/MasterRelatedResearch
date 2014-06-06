% prints summaries for every variable, or specified variables
%
% input:
%    - D:  dataset
%    'subj': a cell array of subject level var names, to only see those vars
%    'event': a cell array of event level var names, to only see those vars
%
% if either varargin is unspecified, all variables will be printed
function print_summary(D, varargin)

    fprintf('\n\n --------- DATASET VARS -------- \n\n');
  
    fprintf('%d subjects, %d subject-level vars, %d event-level vars\n', ...
        length(D.Subj_Level.id), length(D.Subj_Level.names), length(D.Event_Level.names));
    
    fprintf('\n\n --------- SUBJECT LEVEL VARS -------- \n\n');
    
    subj_varnames = D.Subj_Level.names;
    svars = find(strcmp('subj', varargin));
    if ~isempty(svars), subj_varnames = varargin{svars+1}; end

    
    for varname=subj_varnames
        vname = char(varname);
        [var,~,~,descrip] = get_var(D, vname);
        fprintf('%s (%s): min:%3.2f\t max:%3.2f\t mean:%3.2f\t sd:%3.2f\n', ...
            vname, descrip, min(var), max(var), mean(var), std(var));
    end
    
    
    fprintf('\n\n --------- EVENT LEVEL VARS -------- \n\n');
   
    event_varnames = D.Event_Level.names;
    evars = find(strcmp('event', varargin));
    if ~isempty(evars), event_varnames = varargin{evars+1}; end
    
    for varname=event_varnames
        vname = char(varname);
        [var,~,~,descrip] = get_var(D, vname);
        fprintf('%s (%s): min:%3.2f\t max:%3.2f\t mean:%3.2f\n', ...
            vname, descrip{1}, min(min(var)), max(max(var)), mean(mean(var)));
    end
end