
    % Data setting
    N = N_range(iterate_N);
    B = B_range(iterate_B);

    Points_coordinates = Graphs_to_archive(1:N, :, iterate_N, iterate_instance, iterate_theta);
    Distances = zeros(N * (N-1),1);
    Number_of_arcs = N * (N-1);
    Arcs_that_stay = 1:N * (N-1);
    
    OUT_arcs_that_stay = zeros(N*(N-1),1);
    IN_arcs_that_stay = zeros(N*(N-1),1);
    
    iterate_thingy = 1;
    for i = 1:N
        for j = 1:i-1
            OUT_arcs_that_stay(iterate_thingy) = i;
            IN_arcs_that_stay(iterate_thingy) = j;
            iterate_thingy = iterate_thingy + 1;
        end
        
        for j = i+1:N
            OUT_arcs_that_stay(iterate_thingy) = i;
            IN_arcs_that_stay(iterate_thingy) = j;
            iterate_thingy = iterate_thingy + 1;
        end
    end
    
    for iterate_arc = 1:Number_of_arcs
        
        Distances(iterate_arc) = norm(Points_coordinates(OUT_arcs_that_stay(iterate_arc),:) - Points_coordinates(IN_arcs_that_stay(iterate_arc),:));
        
    end
    
    Ends_of_path = Arcs_that_stay(find(Distances >= max(Distances)));
    s = OUT_arcs_that_stay(Ends_of_path(1));
    t = IN_arcs_that_stay(Ends_of_path(1));

    Arcs_that_stay = Arcs_that_stay(Distances < quantile(Distances,0.3));
    OUT_arcs_that_stay = OUT_arcs_that_stay(Arcs_that_stay);
    IN_arcs_that_stay = IN_arcs_that_stay(Arcs_that_stay);
    Distances = Distances(Distances < quantile(Distances,0.3));
    Number_of_arcs = length(Distances);
    
    Arc_data = [OUT_arcs_that_stay IN_arcs_that_stay Distances];
    
    clear Ends_of_path;
    
    figure(1);
    clf;
    hold on;

    scatter(Points_coordinates(:,1), Points_coordinates(:,2),'o');
    xlim([0 10]);
    ylim([0 10]);
    
    for iterate_arc = 1:Number_of_arcs
        plot([Points_coordinates(Arc_data(iterate_arc,1),1); Points_coordinates(Arc_data(iterate_arc,2),1)] , [Points_coordinates(Arc_data(iterate_arc,1),2); Points_coordinates(Arc_data(iterate_arc,2),2)],'LineWidth',0.5);        
    end