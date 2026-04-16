
% Thin-walled torsion-box study of spacecraft bus

clc; clear; close all;
format long;

fprintf('=== Thin-Walled Torsion Box Study ===\n\n');

%% Global parameters
H_bus  = 2.5;        % [m] bus height
t_wall = 0.02;       % [m] wall thickness
FOS    = 1.5;        % safety factor
theta_max_deg = 0.1; % [deg] allowable twist 
T_worst = 2000;      % [N*m] worst-case torque at top deck

fprintf('worst-case torque at top deck: T = %.1f N·m\n', T_worst);
fprintf('Allowable twist: theta_max = %.3f deg\n\n', theta_max_deg);

%% 1. Materials
materials(1).name    = 'Al honeycomb / Al facesheets';
materials(1).E       = 70e9;
materials(1).rho     = 260;
materials(1).sigma_y = 250e6;
materials(1).nu      = 0.33;

materials(2).name    = 'CFRP facesheets + core';
materials(2).E       = 130e9;
materials(2).rho     = 220;
materials(2).sigma_y = 500e6;
materials(2).nu      = 0.25;

materials(3).name    = 'Titanium facesheets + core';
materials(3).E       = 110e9;
materials(3).rho     = 350;
materials(3).sigma_y = 800e6;
materials(3).nu      = 0.34;

nMat = numel(materials);

%% 2. Geometries
geoms(1).name = 'Cube';
geoms(1).type = 'rect';
geoms(1).w    = 1.8;
geoms(1).d    = 1.8;

geoms(2).name = 'Rectangular';
geoms(2).type = 'rect';
geoms(2).w    = 2.2;
geoms(2).d    = 1.4;

geoms(3).name = 'Cylinder';
geoms(3).type = 'cyl';
geoms(3).R    = 1.1;

geoms(4).name = 'Hexagonal';
geoms(4).type = 'hex';
geoms(4).s    = 1.0;

nGeom = numel(geoms);

%% 3. Loop over all combinations

designs = [];
idx = 0;

for ig = 1:nGeom
    gdat = geoms(ig);

    % Enclosed area and perimeter (plan view)
    [Am, P] = torsion_geom(gdat);

    % Torsion constant for thin-walled closed section
    J_closed_geom = 4 * Am^2 * t_wall / P;

    % Thin-wall area for mass estimate
    A_wall = P * t_wall;

    for im = 1:nMat
        idx = idx + 1;
        mdat = materials(im);

        nameCombo = sprintf('%s + %s', gdat.name, mdat.name);
        fprintf('--- Design %d: %s ---\n', idx, nameCombo);

        % Shear modulus
        G = mdat.E / (2*(1 + mdat.nu));

        % Mass
        Vol  = A_wall * H_bus;
        mass = Vol * mdat.rho;

        % Shear flow & stress (Bredt–Batho)
        q   = T_worst / (2 * Am);     % [N/m]
        tau = q / t_wall;             % [Pa]

        tau_allow = 0.6 * mdat.sigma_y / FOS;
        RF_tau    = tau_allow / tau;

        % Twist
        theta_rad = T_worst * H_bus / (G * J_closed_geom);
        theta_deg = theta_rad * 180/pi;

        fprintf('  Am = %.3f m^2, P = %.3f m\n', Am, P);
        fprintf('  J_closed = %.3e m^4\n', J_closed_geom);
        fprintf('  Mass = %.1f kg\n', mass);
        fprintf('  tau = %.2f MPa, RF_tau = %.2f\n', tau/1e6, RF_tau);
        fprintf('  theta = %.3f deg\n\n', theta_deg);

        des = struct();
        des.name      = nameCombo;
        des.geomName  = gdat.name;
        des.matName   = mdat.name;
        des.mass      = mass;
        des.Am        = Am;
        des.P         = P;
        des.J_closed  = J_closed_geom;
        des.tau       = tau;
        des.RF_tau    = RF_tau;
        des.theta_deg = theta_deg;

        designs = [designs; des]; 
    end
end

nDes = numel(designs);

%% 4. Arrays for plotting

theta_vec = [designs.theta_deg]';
RF_tauVec = [designs.RF_tau]';
mass_vec  = [designs.mass]';

names   = strings(nDes,1);
geomStr = strings(nDes,1);
for i = 1:nDes
    names(i)   = designs(i).name;
    geomStr(i) = designs(i).geomName;
end

geomList   = {'Cube','Rectangular','Cylinder','Hexagonal'};
geomColors = lines(numel(geomList));

Cgeom = zeros(nDes,3);
for i = 1:nDes
    gi = find(strcmp(geomStr(i), geomList), 1);
    if isempty(gi), gi = 1; end
    Cgeom(i,:) = geomColors(gi,:);
end

%% 5. Plot 1: Twist angle per design

figure('Name','Twist Angle per Design');
b1 = bar(theta_vec);
b1.FaceColor = 'flat';
b1.CData     = Cgeom;

grid on;
hold on;


for gidx = 1:numel(geomList)
    plot(NaN,NaN,'s','MarkerFaceColor',geomColors(gidx,:), ...
        'MarkerEdgeColor','k','DisplayName',geomList{gidx});
end
hold off;

set(gca,'XTick',1:nDes,'XTickLabel',names,'XTickLabelRotation',25, ...
    'FontSize',10);
ylabel('Twist \theta [deg]','FontSize',12,'FontWeight','bold');
title('Thin-Walled Torsion: Base–Top Twist', ...
      'FontSize',14,'FontWeight','bold');
legend('Location','northwest');

%% 6. Plot 2: Shear Reserve Factor per design

figure('Name','Shear RF per Design');
b2 = bar(RF_tauVec);
b2.FaceColor = 'flat';
b2.CData     = Cgeom;

grid on;
hold on;
for gidx = 1:numel(geomList)
    plot(NaN,NaN,'s','MarkerFaceColor',geomColors(gidx,:), ...
        'MarkerEdgeColor','k','DisplayName',geomList{gidx});
end
hold off;

set(gca,'XTick',1:nDes,'XTickLabel',names,'XTickLabelRotation',25, ...
    'FontSize',10);
ylabel('Shear Reserve Factor RF_\tau','FontSize',12,'FontWeight','bold');
title('Thin-Walled Torsion: Shear Strength Margin', ...
      'FontSize',14,'FontWeight','bold');
legend('Location','northwest');

%% 7. Plot 3: Mass vs Twist (trade-off)

figure('Name','Mass vs Twist Trade-off');
hold on;

for gidx = 1:numel(geomList)
    idxGeom = strcmp(geomStr, geomList{gidx});

    % Scatter points
    scatter(mass_vec(idxGeom), theta_vec(idxGeom), 90, ...
        geomColors(gidx,:), 'filled', 'MarkerEdgeColor','k', ...
        'DisplayName', geomList{gidx});

    % ---- Add labels next to each point ----
    idxList = find(idxGeom);
    for k = 1:numel(idxList)
        i = idxList(k);
        text(mass_vec(i) + 2, ...         % small x-offset
             theta_vec(i), ...            % same y
             names(i), ...
             'FontSize', 9, ...
             'HorizontalAlignment','left');
    end
end

hold off;
grid on;
xlabel('Mass [kg]','FontSize',12,'FontWeight','bold');
ylabel('Twist \theta [deg]','FontSize',12,'FontWeight','bold');
title('Torsional Stiffness vs Mass for Bus Designs', ...
      'FontSize',14,'FontWeight','bold');
legend('Location','northeastoutside');



function [Am, P] = torsion_geom(g)


switch g.type
    case 'rect'
        w = g.w; d = g.d;
        Am = w * d;
        P  = 2*(w + d);

    case 'cyl'
        R = g.R;
        Am = pi * R^2;
        P  = 2*pi*R;

    case 'hex'
        s  = g.s;
        Am = (3*sqrt(3)/2) * s^2;
        P  = 6*s;

    otherwise
        error('Unknown geometry type.');
end
end
