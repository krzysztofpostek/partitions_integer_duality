% This script checks if a given solution is binary or not, caring about
% variables with a positive dual multplier

function [not_binary, index_of_fractional] = binary_check(x_arg, beta_arg)

    not_binary = (prod(abs(round(x_arg) - x_arg) < eps) < 1);
    
    if(not_binary)
        index_of_fractional = find(~(abs(round(x_arg) - x_arg) < eps) & (beta_arg > eps));
        
        if(isempty(index_of_fractional))
            index_of_fractional = find(~(abs(round(x_arg) - x_arg) < eps));
        end
        
        index_of_fractional = index_of_fractional(1);
    else
        index_of_fractional = 0;
    end
        
end