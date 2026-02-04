clear all
clc
format long;
fprintf('Run started at %s\n', datestr(now));

%% — Load full CSV (skip header + first 3 cols)
data = csvread('temp.csv', 1, 3);

%% — Define slice indices
idx1_start = 1;
idx1_end   = 13880;   % through 2017-12-31
idx2_start = 13881;   % from 2018-01-01
idx2_end   = size(data,2);

%% — Process 1980–2017 slice
sst = data(:, idx1_start:idx1_end);
[G, S] = size(sst);

%% — Only keep first 100 modes
Eig_value_count = min(100, S);

%% — Build covariance-like matrix in one go
Main_matrix = (sst' * sst) / S;

%% — Top-5 eigenpairs
opts = struct('disp',0);
[Eig_vector_full, Eig_value_mat] = eigs(Main_matrix, Eig_value_count, 'largestabs', opts);
Eig_value = diag(Eig_value_mat);
[Eig_value, idx] = sort(Eig_value, 'descend');
Eig_vector = Eig_vector_full(:, idx);

%% — Spatial patterns Φ
Unnormalize_Phi = sst * Eig_vector;                     % G×Eig_value_count
Phi             = Unnormalize_Phi ./ sqrt(Eig_value' * S);

%% — Time coefficients a
a = (Phi' * sst)';    % S×Eig_value_count

%% — Compute average absolute relative error (AARE)
total_aare = zeros(Eig_value_count, S);
for n = 1:Eig_value_count
    fprintf('  Computing AARE for first %d modes (1980–2017)...\n', n);
    for i = 1:S
        u_i    = Phi(:,1:n) * a(i,1:n)';
        relerr = abs(sst(:,i) - u_i) ./ abs(sst(:,i));
        total_aare(n,i) = mean(relerr);
    end
end

%% — Export to CSV under output_1980_2017
outDir = fullfile(pwd,'output_1980_2017');
if ~exist(outDir,'dir'), mkdir(outDir); end

vars = whos;
for k = 1:numel(vars)
    name = vars(k).name;
    if strcmp(name,'data') || strcmp(name,'sst') || strcmp(name,'G') ...
       || strcmp(name,'S') || strcmp(name,'idx1_start') || strcmp(name,'idx1_end') ...
       || strcmp(name,'idx2_start') || strcmp(name,'idx2_end')
        continue;
    end
    val = eval(name);
    fn  = fullfile(outDir,[name,'.csv']);
    if isnumeric(val) || islogical(val)
        writematrix(val, fn);
    elseif istable(val)
        writetable(val, fn);
    elseif iscell(val)
        writecell(val, fn);
    end
end

fprintf('Run 1980–2017 completed at %s\n', datestr(now));


%% — Process 2018–2020 slice
sst = data(:, idx2_start:idx2_end);
[G, S] = size(sst);

%% — Only keep first 100 modes
Eig_value_count = min(100, S);

%% — Build covariance-like matrix in one go
Main_matrix = (sst' * sst) / S;

%% — Top-5 eigenpairs
opts = struct('disp',0);
[Eig_vector_full, Eig_value_mat] = eigs(Main_matrix, Eig_value_count, 'largestabs', opts);
Eig_value = diag(Eig_value_mat);
[Eig_value, idx] = sort(Eig_value, 'descend');
Eig_vector = Eig_vector_full(:, idx);

%% — Spatial patterns Φ
Unnormalize_Phi = sst * Eig_vector;
Phi             = Unnormalize_Phi ./ sqrt(Eig_value' * S);

%% — Time coefficients a
a = (Phi' * sst)';

%% — Compute average absolute relative error (AARE)
total_aare = zeros(Eig_value_count, S);
for n = 1:Eig_value_count
    fprintf('  Computing AARE for first %d modes (2018–2020)...\n', n);
    for i = 1:S
        u_i    = Phi(:,1:n) * a(i,1:n)';
        relerr = abs(sst(:,i) - u_i) ./ abs(sst(:,i));
        total_aare(n,i) = mean(relerr);
    end
end

%% — Export to CSV under output_2018_2020
outDir = fullfile(pwd,'output_2018_2020');
if ~exist(outDir,'dir'), mkdir(outDir); end

vars = whos;
for k = 1:numel(vars)
    name = vars(k).name;
    if strcmp(name,'data') || strcmp(name,'sst') || strcmp(name,'G') ...
       || strcmp(name,'S') || strcmp(name,'idx1_start') || strcmp(name,'idx1_end') ...
       || strcmp(name,'idx2_start') || strcmp(name,'idx2_end')
        continue;
    end
    val = eval(name);
    fn  = fullfile(outDir,[name,'.csv']);
    if isnumeric(val) || islogical(val)
        writematrix(val, fn);
    elseif istable(val)
        writetable(val, fn);
    elseif iscell(val)
        writecell(val, fn);
    end
end

fprintf('Run 2018–2020 completed at %s\n', datestr(now));
