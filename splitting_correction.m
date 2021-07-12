
% correcting the set partitioning
WC_values_corr = zeros(1, size(x_sbs, 2));

A = ones(size(x_sbs, 2), Number_of_arcs, size(x_sbs, 2));
A(1,:,:) = 1;
b = zeros(size(x_sbs, 2), size(x_sbs, 2));
b(1, :) = B;

for j = 1:size(x_sbs, 2)
    
    A_adversarial = 0.5 * (repmat(x_sbs(:, j), [1 size(x_sbs, 2)]) - x_sbs) .* repmat(Distances, [1 size(x_sbs, 2)]);
    A_adversarial = A_adversarial(:, ~([1:size(x_sbs, 2)] == j))';
    
    A(2:size(x_sbs, 2), :, j) = A_adversarial;
    
    b_adversarial = Distances' * (x_sbs - repmat(x_sbs(:, j), [1 size(x_sbs, 2)]));
    b_adversarial = b_adversarial(~([1:size(x_sbs, 2)] == j))';
    
    b(2:size(x_sbs, 2), j) = b_adversarial;
    
end

Number_of_extra_constraints = size(x_sbs, 2) * ones(1, Number_of_subsets);