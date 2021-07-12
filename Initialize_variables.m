% Initialize variables used in solving the problem

A = ones(1,Number_of_arcs);
b = B;
u = ones(Number_of_arcs,1);
l = zeros(Number_of_arcs,1);
Number_of_extra_constraints = 1;
Worst_case_scenarios = [];
Number_of_subsets = 1;