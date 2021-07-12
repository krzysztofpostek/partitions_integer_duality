% This file recovers the worst-case scenarios from a BB tree. First we
% solve the integer problem using an off the shelf solver, then our own
% solver in which we have the procedure for finding the critical scenarios


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STAGE 1 - SOLVING the model
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cvx_begin
    variable x_var(Number_of_arcs,1) binary
    variable objective
    variable lambda_U(Number_of_arcs,1) nonnegative
    variable lambda_L(Number_of_arcs,1) nonnegative
    variable mhu(Number_of_extra_constraints(iterate_subset),1) nonnegative

    minimize(objective)
    subject to

    % Objective function constraints

    x_var'*Distances + ( lambda_U'*u - lambda_L'*l + mhu' * [b(1:Number_of_extra_constraints(iterate_subset), iterate_subset)] ) <= objective;
    0.5 * x_var .* Distances - lambda_U + lambda_L - [A(1:Number_of_extra_constraints(iterate_subset), :, iterate_subset)]' * mhu == 0;

    % Feasibility constraint
    for iterate_vertex = 1:N
        if(sum(OUT_arcs_that_stay == iterate_vertex) + sum(IN_arcs_that_stay == iterate_vertex) > 0) % Condition if there are any arcs going to a given vertex
            sum(x_var(OUT_arcs_that_stay' == iterate_vertex)) >= sum(x_var(IN_arcs_that_stay' == iterate_vertex)) + (iterate_vertex == s) - (iterate_vertex == t);
        end
    end
cvx_end

UB = cvx_optval;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STAGE 2 - scenario recovery
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

active_or_not = [1];
how_many_bounds = [0];
bounds = zeros(1, 1, 2);
LBs = - Inf;
scenarios = zeros(Number_of_arcs, 1);

nb_of_nodes = 1;
nb_of_nodes_now = 1;

for breadth_rounds = 1:15
    
    for i_node = 1:nb_of_nodes_now
        if(active_or_not(i_node) > 0)
            Solver_relaxation_BB; % Solving the LP relaxation corresponding to the problem
            if(cvx_optval < Inf)
                [not_binary, which_variable] = binary_check(double(x_var), double(beta));

                if(cvx_optval < UB)
                    if(not_binary > 0)
                        nb_of_nodes = nb_of_nodes + 1;
                        how_many_bounds(i_node) = how_many_bounds(i_node) + 1;
                        how_many_bounds(nb_of_nodes) = how_many_bounds(i_node);
                        active_or_not(nb_of_nodes) = 1;
                        bounds(i_node, how_many_bounds(i_node), 1) = which_variable;
                        bounds(i_node, how_many_bounds(i_node), 2) = 0;

                        if(how_many_bounds(i_node) > 1)
                            bounds(nb_of_nodes, 1:how_many_bounds(i_node) - 1 , 1:2) = bounds(i_node, 1:how_many_bounds(i_node) - 1 , 1:2);
                        end

                        bounds(nb_of_nodes, how_many_bounds(i_node), 1) = which_variable;
                        bounds(nb_of_nodes, how_many_bounds(i_node), 2) = 1;
                        LBs(i_node) = max(LBs(i_node), cvx_optval);
                        LBs(nb_of_nodes) = LBs(i_node);
                    else
                        active_or_not(i_node) = 0;
                        LBs(i_node) = max(LBs(i_node), cvx_optval);
                        scenarios(:, i_node) = double(beta) / double(alfa);
                    end
                else
                    active_or_not(i_node) = 0;
                    LBs(i_node) = max(LBs(i_node), cvx_optval);
                    scenarios(:, i_node) = double(beta) / double(alfa);
                end
            else
                active_or_not(i_node) = 0;
                LBs(i_node) = max(LBs(i_node), cvx_optval);
            end
        end
    end
    
    nb_of_nodes_now = nb_of_nodes;
    
end

% Removing scenarios equal to 0 vector

scenario_stays = ones(size(scenarios, 2), 1);

if(size(scenarios, 2) > 1)
   for j = 2:size(scenarios, 2)
       for i = 1:j-1
           if((all(scenarios(:, i) == scenarios(:, j), 1)) || (norm(scenarios(:, j)) <= 0.05))
               scenario_stays(j) = 0; 
           end
       end
   end
end

scenarios = scenarios(:, scenario_stays > 0.5);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% STAGE 3 - picking the two furthest scenarios
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
max_distance = 0;
couple_scenario = [0 0];

if(size(scenarios, 2) < 2)
    max_subsets_not_reached = false;
end

for i_scenario = 1:size(scenarios, 2) - 1
    for j_scenario = i_scenario+1:size(scenarios, 2)
        if(norm(scenarios(:, i_scenario) - scenarios(:, j_scenario),2) >= max_distance)
            max_distance = norm(scenarios(:,i_scenario) - scenarios(:,j_scenario), 2);
            couple_scenario = [i_scenario j_scenario];
        end
    end
end

if(prod(couple_scenario > 0) > 0)
    Distinct_two_scenarios(iterate_subset) = 1;
    two_furthest_scenarios = scenarios(:, couple_scenario);
    Worst_case_scenarios(:, :, iterate_subset) = two_furthest_scenarios;
else
    Distinct_two_scenarios(iterate_subset) = 0;
end

NB_of_scenarios_per_subset(iterate_subset) = size(scenarios, 2);