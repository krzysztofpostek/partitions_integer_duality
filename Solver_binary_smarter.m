% This file solves the integer programming problem per each uncertainty
% subset using an off-the-shelf solver

% This is the binary solver

Worst_case_values = zeros(Number_of_subsets, 1);
x_sbs = zeros(Number_of_arcs, Number_of_subsets);

for iterate_subset = 1:Number_of_subsets

    cvx_begin
        variable x_var(Number_of_arcs, 1) binary
        variable objective
        variable lambda_U(Number_of_arcs, 1) nonnegative
        variable lambda_L(Number_of_arcs, 1) nonnegative
        variable mhu(Number_of_extra_constraints(iterate_subset), 1) nonnegative

        minimize(objective)
            subject to

                % Objective function constraints

                x_var'*Distances + ( lambda_U'*u - lambda_L'*l + mhu' * [b(1:Number_of_extra_constraints(iterate_subset), iterate_subset)] ) <= objective;
                0.5 * x_var.*Distances - lambda_U + lambda_L - [A(1:Number_of_extra_constraints(iterate_subset), :, iterate_subset)]' * mhu == 0;

                % Feasibility constraint
                for iterate_vertex = 1:N
                    if(sum(OUT_arcs_that_stay == iterate_vertex) + sum(IN_arcs_that_stay == iterate_vertex) > 0) % Condition if there are any arcs going to a given vertex
                        sum(x_var(OUT_arcs_that_stay' == iterate_vertex)) >= sum(x_var(IN_arcs_that_stay' == iterate_vertex)) + (iterate_vertex == s) - (iterate_vertex == t);
                    end
                end

    cvx_end
    
    Worst_case_values(iterate_subset) = cvx_optval;
    x_sbs(:, iterate_subset) = int32(x_var);
end

Problem_optimum = max(Worst_case_values);