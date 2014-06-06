function xout = scale(x,varargin)
% x = scale(x,[just center])
%
% centers and scales column vectors
% to mean 0 and st. deviation 1

xout = NaN .* zeros(size(x));

for i = 1:size(x,2)

    [nanvec x_no_nan] = nanremove(x(:,i));

    if isempty(x_no_nan)
        % no data.  return original input.
        xout = x;
        return
    end
    
    x_no_nan = x_no_nan - mean(x_no_nan); %repmat(mean(x_no_nan),size(x_no_nan,1),1);

    if length(varargin) == 0 || varargin{1} == 0
        
        x_no_nan = x_no_nan ./ max(eps, std(x_no_nan)); %repmat(std(x_no_nan),size(x_no_nan,1),1);
    
    end

    xout(~nanvec,i) = x_no_nan;
end

return