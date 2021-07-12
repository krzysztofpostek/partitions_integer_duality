% Splitting the uncertainty subsets

New_number_of_problems = Number_of_subsets;
margin = 0.01;
any_split_done = false;

for iterate_subset = 1:Number_of_subsets
    
    %pause(1);
    %[(Worst_case_values(iterate_subset) >= max(Worst_case_values) - margin) (Distinct_two_scenarios(iterate_subset) == 1)]
    if((Worst_case_values(iterate_subset) >= max(Worst_case_values) - margin) && (Distinct_two_scenarios(iterate_subset) == 1) && max_subsets_not_reached)
        any_split_done = true;
        
        SH_normal = Worst_case_scenarios(:, 1, iterate_subset) -  Worst_case_scenarios(:, 2, iterate_subset);
        SH_intercept = SH_normal' * (Worst_case_scenarios(:, 1, iterate_subset) + Worst_case_scenarios(:, 2, iterate_subset)) / 2;
        
        A(Number_of_extra_constraints(iterate_subset) + 1, :, iterate_subset) = SH_normal';
        b(Number_of_extra_constraints(iterate_subset) + 1, iterate_subset) = SH_intercept;
        
        New_number_of_problems = New_number_of_problems + 1;
        if(New_number_of_problems == Max_nb_of_subsets)
            max_subsets_not_reached = false;
        end
        
        A(1:Number_of_extra_constraints(iterate_subset), :, New_number_of_problems) = A(1:Number_of_extra_constraints(iterate_subset), :, iterate_subset);
        A(Number_of_extra_constraints(iterate_subset)+1, :, New_number_of_problems) = -SH_normal';
        
        b(1:Number_of_extra_constraints(iterate_subset), New_number_of_problems) = b(1:Number_of_extra_constraints(iterate_subset),iterate_subset);
        b(Number_of_extra_constraints(iterate_subset)+1, New_number_of_problems) = -SH_intercept;
        
        Number_of_extra_constraints(iterate_subset) = Number_of_extra_constraints(iterate_subset) + 1;
        Number_of_extra_constraints(New_number_of_problems) = Number_of_extra_constraints(iterate_subset);
    end
end

Number_of_subsets = New_number_of_problems;