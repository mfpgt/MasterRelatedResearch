function obj = create(obj, varargin)

N = fieldnames(obj);

for i = 1:length(varargin)
    if ischar(varargin{i})
        
        % Look for a field (attribute) with the input name
        wh = strmatch(varargin{i}, N, 'exact');
        
        if ~isempty(wh)
            
            obj.(varargin{i}) = varargin{i + 1};
            
            % special methods for specific fields
            switch varargin{i}
                case 'dat'
                    xx = isnan(obj.(varargin{i}));
                    if any(xx(:))
                        fprintf('fmri_data.create: Converting %3.0f NaNs to 0s.', sum(xx(:)));
                        obj.dat(xx) = 0;
                    end
                
            end
        end
        
    end
end

end % function