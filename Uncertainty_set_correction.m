%  This file corrects the partition of the uncertinaty set givens a
%  solution (just like the ex post correction in the paper)

WC_values_corr = zeros(1, size(x_sbs, 2));

for j = 1:size(x_sbs, 2)
    
    A_adversarial = 0.5 * (repmat(x_sbs(:, j), [1 size(x_sbs, 2)]) - x_sbs) .* repmat(Distances, [1 size(x_sbs, 2)]);
    A_adversarial = A_adversarial(:, ~([1:size(x_sbs, 2)] == j))';
    
    b_adversarial = Distances' * (x_sbs - repmat(x_sbs(:, j), [1 size(x_sbs, 2)]));
    b_adversarial = b_adversarial(~([1:size(x_sbs, 2)] == j))';
    
    cvx_begin
        variable z(Number_of_arcs, 1) nonnegative
        maximize(x_sbs(:, j)' * Distances + 0.5 * Distances' * (x_sbs(:, j) .* z))
        subject to
            sum(z) <= B;
            z <= 1;
            
            if(size(x_sbs, 2) > 1)
                A_adversarial * z <= b_adversarial;
            end
    cvx_end
    
    WC_values_corr(j) = cvx_optval;
    
end