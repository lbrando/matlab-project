% Inizializzo le variabili
L = 1; % Leader
F = 3; % Followers
K = 1; % Maggiore di 0
delta = 0.1;
gamma = 0.5;

% Posizione dei follower
pos_followers = [0.5, 1.5; 2.0, 2.5; 3.0, 1.5];

% Posizione del leader
pos_leader = [1.5, 3.0];
leader_velocity = [0.1, 0.05]; % Velocità costante del leader

% Numero di iterazioni
num_iterations = 50;

% Parametri aggiuntivi
attraction_strength = 0.3; % Riduco la forza di attrazione tra il leader e i follower
repulsion_strength = 0.1; % Introduco una forza di repulsione tra il leader e i follower per evitare che si avvicinino troppo
leader_attraction_strength = 0.1; % Forza di attrazione del leader

% Parametri del cono di percezione
p1 = 0.9; % Peso per forte percezione
p2 = 0.1; % Peso per debole percezione
theta = pi/2; % Angolo del cono visivo

% Simulazione del movimento nel tempo
figure;
hold on;
% Array per memorizzare le traiettorie di leader e follower
leader_trajectory = zeros(num_iterations, 2);
follower_trajectory = zeros(num_iterations, F, 2);
for t = 1:num_iterations
    % Memorizza le posizioni attuali di leader e follower
    leader_trajectory(t, :) = pos_leader;
    follower_trajectory(t, :, :) = pos_followers;

    % Distanza tra follower e leader
    distances = sqrt(sum((pos_followers - pos_leader).^2, 2));

    for i = 1:F
        % Distanza tra follower tra loro
        distances_follower_i = sqrt(sum((pos_followers - repmat(pos_followers(i,:), F, 1)).^2, 2));

        % Forza di interazione del follower i
        forza_interazione_i = sum(H(distances_follower_i, K, delta, gamma)) * (pos_followers(i,:) - pos_leader) / (norm(pos_followers(i,:) - pos_leader) + delta);
        
        % Forza di repulsione tra follower per evitare sovrapposizione
        repulsion_force = repulsion_strength * (pos_followers(i,:) - pos_leader) / (norm(pos_followers(i,:) - pos_leader) + delta);
        
        % Calcolo la forza di attrazione del leader verso il follower i
        leader_attraction_force = leader_attraction_strength * (pos_followers(i,:) - pos_leader);
        
        % Calcolo il vettore direzione del cono visivo
        direction_vector = pos_followers(i,:) - pos_leader;
        direction_vector = direction_vector / norm(direction_vector);
        
        % Calcolo la forza di interazione del cono visivo
        visual_cone_force = zeros(1,2);
        for j = 1:F
            if j ~= i
                % Calcolo il vettore tra il follower i e il follower j
                follower_vector = pos_followers(j,:) - pos_followers(i,:);
                follower_vector = follower_vector / norm(follower_vector);
                
                % Calcolo il prodotto scalare tra i vettori
                dot_product = dot(direction_vector, follower_vector);
                
                % Verifico se il follower j rientra nel cono visivo
                if dot_product >= cos(theta/2)
                    visual_cone_force = visual_cone_force + (p1 - p2) * (pos_followers(j,:) - pos_followers(i,:));
                end
            end
        end
        
        % Aggiorno la posizione del follower i
        pos_followers(i,:) = pos_followers(i,:) + forza_interazione_i + repulsion_force + leader_attraction_force + visual_cone_force;
    end

    % Aggiorno la posizione del leader
    pos_leader = pos_leader + leader_velocity;

    % Visualizzazione delle posizioni
    fill(pos_leader(1)+[-0.1, 0.1, 0.1, -0.1], pos_leader(2)+[-0.1, -0.1, 0.1, 0.1], 'red'); % Area colorata per il leader
    fill(pos_followers(:,1)+[-0.1, 0.1, 0.1, -0.1], pos_followers(:,2)+[-0.1, -0.1, 0.1, 0.1], 'blue'); % Area colorata per i followers
    
    % Imposto gli assi cartesiani
    xlim([0, 3]);
    ylim([0, 3]);
    
    xlabel('X');
    ylabel('Y');
    title(['Interazione ', num2str(t)]);
    legend('Leader', 'Follower');
    pause(0.5);
end
hold off;

% Visualizzo le traiettorie di leader e follower
figure;
hold on;
% Indico il leader con una linea rossa
plot3(leader_trajectory(:, 1), leader_trajectory(:, 2), 1:numel(leader_trajectory(:, 1)), 'r-', 'LineWidth', 2);
% Indico il leader con una linea blu
for i = 1:F
    plot3(follower_trajectory(:, i, 1), follower_trajectory(:, i, 2), 1:numel(follower_trajectory(:, i, 1)), 'b--', 'LineWidth', 1);
end
xlabel('X');
ylabel('Y');
zlabel('Time');
title('Traiettorie di Leader e Follower');
legend('Leader', 'Follower 1', 'Follower 2', 'Follower 3');
view(3);
hold off;

% Funzione H
function force = H(distance, K, delta, gamma)
    % Calcolo la forza di interazione in base alla distanza
    force = K ./ ((delta^2 + distance.^2).^gamma);
end