% This is the main file of the experiment

cvx_solver Gurobi;
N_range = [10:5:40];
B_range = [2 3 4];
Nb_of_problem_instances = 50;
theta_range = [0];
mmargin = 0.01;

Max_nb_of_subsets = 10;
Initial_table = zeros(Nb_of_problem_instances, length(N_range), length(theta_range), length(B_range));
Final_table = zeros(Nb_of_problem_instances, Max_nb_of_subsets, length(N_range), length(theta_range), length(B_range));
Final_table_UC_corr = zeros(Nb_of_problem_instances, Max_nb_of_subsets, length(N_range), length(theta_range), length(B_range));
NB_scenarios_table = zeros(Nb_of_problem_instances, Max_nb_of_subsets, length(N_range), length(theta_range), length(B_range));
Verification_table = zeros(Nb_of_problem_instances, length(N_range), length(theta_range), length(B_range));
Time_table = zeros(Nb_of_problem_instances, length(N_range), length(theta_range), length(B_range));

for iterate_instance = 1:Nb_of_problem_instances % Iterate over problem instance
    for iterate_N = 1:length(N_range) % Iterate over graph size
        for iterate_theta = 1:length(theta_range) % iterate over theta value
            for iterate_B = 1:length(B_range) % iterate over B (budget) value
                
                tic
                Data_setting_old_style; % Setting the data
                Initialize_variables; % Initialize variables (related to the uncertainty set)
                Solver_binary_smarter; % Solve the static problem
                Initial_table(iterate_instance, iterate_N, iterate_theta) = Problem_optimum; %write down the optimal value
                Final_table(iterate_instance, Number_of_subsets, iterate_N, iterate_theta, iterate_B) = Problem_optimum; %write down the optimal value
                max_subsets_not_reached = true; %indicator if the maximum number of partitions is reached
                
                while(max_subsets_not_reached)
                    
                    Solver_binary_smarter; % Solve the problem
                    Final_table(iterate_instance, Number_of_subsets, iterate_N, iterate_theta, iterate_B) = Problem_optimum; %write down the optimal value
                    
                    if(Number_of_subsets > 1)  %if there are more than 1 uncertainty subset then we do the uncertainty subset correction (ex post in the paper)
                        Uncertainty_set_correction; % file running the correction
                        Final_table_UC_corr(iterate_instance, Number_of_subsets, iterate_N, iterate_theta, iterate_B) = max(WC_values_corr); %write down the improved optimal value
                        splitting_correction; %splitting correction
                    end
                    
                    Worst_case_scenarios = zeros(Number_of_arcs, 2, Number_of_subsets); % Build up the table to store the critical scenarios
                    Distinct_two_scenarios = zeros(Number_of_subsets, 1); % Indicator if there are two distinct critical scenarios for a given subset
                    NB_of_scenarios_per_subset = zeros(Number_of_subsets, 1); % Number of critical scenarios per subset
                    
                    for iterate_subset = 1:Number_of_subsets %iterate over subsets
                        if(Worst_case_values(iterate_subset) >= max(Worst_case_values) - mmargin) % if a given subset corresponds to the 
                            Per_subset_BB_scenario_recovery; % Run solving our own BB solver and recovering from it the critical scenarios
                        end
                    end
                    
                    NB_scenarios_table(iterate_instance, Number_of_subsets, iterate_N, iterate_theta, iterate_B) = mean(NB_of_scenarios_per_subset(Worst_case_values >= max(Worst_case_values) - mmargin)); % Counting the average number of critical scenarios per subsets that correspond to the w-c optimal value
                    splitting; % splitting the uncertainty set
                    
                    % This part of the code stops splitting if there was no
                    % split done
                    if(~any_split_done)
                        max_subsets_not_reached = false; 
                    end
                end
                
                cvx_clear; % Finally solving after all the splits are done.
                Solver_binary_smarter;
                Final_table(iterate_instance, Number_of_subsets, iterate_N, iterate_theta, iterate_B) = Problem_optimum;
                if(Number_of_subsets > 1)
                    Uncertainty_set_correction;
                    Final_table_UC_corr(iterate_instance, Number_of_subsets, iterate_N, iterate_theta, iterate_B) = max(WC_values_corr);
                end
                
                Time_table(iterate_instance, Number_of_subsets, iterate_N, iterate_theta, iterate_B) = toc;
                
                save('Results_remake_with_UC_splitting.mat');
                
            end
        end
    end
end