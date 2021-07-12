% This is a file solving the LP relaxation in our BB solver

%cvx_solver Gurobi

cvx_begin
    variable x_var(Number_of_arcs, 1) nonnegative
    variable objective
    variable lambda_U(Number_of_arcs, 1) nonnegative
    variable lambda_L(Number_of_arcs, 1) nonnegative
    variable mhu(Number_of_extra_constraints(iterate_subset), 1) nonnegative
    dual variable alfa;
    dual variable beta;

    minimize(objective)
    subject to
    
        x_var <= 1;

        % Objective function constraints
        alfa : x_var'*Distances + ( lambda_U'*u - lambda_L'*l + mhu' * [b(1:Number_of_extra_constraints(iterate_subset), iterate_subset)] ) <= objective;
        beta : 0.5 * x_var .* Distances - lambda_U + lambda_L - [A(1:Number_of_extra_constraints(iterate_subset), :, iterate_subset)]' * mhu <= 0;


        % Feasibility constraint
        for iterate_vertex = 1:N
            if(sum(OUT_arcs_that_stay == iterate_vertex) + sum(IN_arcs_that_stay == iterate_vertex) > 0) % Condition if there are any arcs going to a given vertex
                sum(x_var(OUT_arcs_that_stay' == iterate_vertex)) == sum(x_var(IN_arcs_that_stay' == iterate_vertex)) + (iterate_vertex == s) - (iterate_vertex == t);
            end
        end
        
        if(how_many_bounds(i_node) > 0)
%            fprintf('spotted');
           for i_bound = 1:how_many_bounds(i_node)
               bounds(i_node, i_bound, 2);
               x_var(bounds(i_node, i_bound, 1)) == bounds(i_node, i_bound, 2);
           end
        end
        
cvx_end