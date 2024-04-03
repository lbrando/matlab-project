% Inizializzazione delle variabili
L = 10; % Numero di leader
T = 30; % Numero di targets
K = 1; % Maggiore di 0
delta = 0.1;
gamma = 0.5;
num_iterations = 10;
epsilon = 0.1; % Parametro epsilon

% Posizione dei targets
pos_followers = rand(T, 2); % Posizioni casuali per i targets
pos_leader = rand(L, 2); % Posizione casuale per i leader
leader_velocity = repmat([0.1, 0.05], L, 1); % Velocità costante del leader

% Parametri aggiuntivi
attraction_strength = 0.3; % Riduco la forza di attrazione tra il leader e i targets
repulsion_strength = 0.1; % Introduco una forza di repulsione tra il leader e i targets per evitare che si avvicinino troppo
leader_attraction_strength = 0.1; % Forza di attrazione del leader

% Parametri del cono di percezione
p1 = 0.9; % Peso per forte percezione
p2 = 0.1; % Peso per debole percezione
theta = pi/2; % Angolo del cono visivo

% Inizializzazione delle traiettorie
leader_trajectory = zeros(num_iterations, L, 2);
follower_trajectory = zeros(num_iterations, T, 2);

% Simulazione del movimento nel tempo
figure;
hold on;
for n = 0:num_iterations-1
    % Memorizza le posizioni attuali di leader e targets
    for l = 1:L
        leader_trajectory(n+1, l, :) = pos_leader(l, :);
    end
    for t = 1:T
        follower_trajectory(n+1, t, :) = pos_followers(t, :);
    end

    % Visualizza il numero di interazione corrente
    disp(['Interazione ', num2str(n+1)]);

    % Calcola il passo temporale
    delta_tc = 2*epsilon/size(pos_followers, 1);
    
    for k = 1:size(pos_followers, 1)
        % Seleziona casualmente una coppia (i, j)
        i = randi(T);
        j = randi(T);

        % Valuta Hα per la coppia (i, j)
        H_ij = H(norm(pos_followers(i,:) - pos_followers(j,:)), K, delta, gamma);

        % Calcola le variazioni di velocità
        delta_vi = delta_tc * H_ij * (pos_followers(j,:) - pos_followers(i,:)) / norm(pos_followers(j,:) - pos_followers(i,:));
        delta_vj = delta_tc * H_ij * (pos_followers(i,:) - pos_followers(j,:)) / norm(pos_followers(i,:) - pos_followers(j,:));

        % Aggiorna le velocità
        pos_followers(i,:) = pos_followers(i,:) + delta_vi;
        pos_followers(j,:) = pos_followers(j,:) + delta_vj;
    end

    % Aggiorno la posizione del leader
    pos_leader = pos_leader + leader_velocity;

    % Visualizzazione delle posizioni aggiornate
    for l = 1:L
        plot(pos_leader(l,1), pos_leader(l,2), 'r-', 'LineWidth', 2);
    end
    for t = 1:T
        plot(pos_followers(t,1), pos_followers(t,2), 'b-', 'LineWidth', 1); % Modifica del colore della linea per i target
    end
    
    % Pausa per visualizzare l'aggiornamento
    pause(0.5);
end
hold off;

% Aggiungi legenda
legend('Leader', 'Target');

% Visualizzo le traiettorie di leader e targets
figure;
hold on;
for l = 1:L
    plot3(leader_trajectory(:, l, 1), leader_trajectory(:, l, 2), 1:numel(leader_trajectory(:, l, 1)), 'r-', 'LineWidth', 2);
end
for t = 1:T
    plot3(follower_trajectory(:, t, 1), follower_trajectory(:, t, 2), 1:numel(follower_trajectory(:, t, 1)), 'b--', 'LineWidth', 1); % Modifica dello stile della linea per i target
end
xlabel('X');
ylabel('Y');
zlabel('Time');
title('Traiettorie di Leader e Targets');
view(3);
hold off;

% Aggiungi legenda
legend('Leader', 'Target');

% Funzione H
function force = H(distance, K, delta, gamma)
    % Calcolo la forza di interazione in base alla distanza
    force = K ./ ((delta^2 + distance.^2).^gamma);
end