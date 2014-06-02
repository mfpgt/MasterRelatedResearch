function vif = getvif(model, no_add_intercept)

% function vif = getvif(model, [no_add_intercept])

if nargin < 2, no_add_intercept = 0; end


for i = 1:size(model,2)

    if no_add_intercept
        X = model;
    else
        X = [model ones(size(model,1),1)];
    end

     y = X(:,i);

     X(:,i) = [];

     b = X\y;fits = X * b;

     rsquare = var(fits) / var(y);

     if rsquare == 1,rsquare = .9999999;end

     vif(i) = 1 / (1 - rsquare);

end  