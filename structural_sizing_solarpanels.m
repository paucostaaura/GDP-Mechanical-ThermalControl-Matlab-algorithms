clc; clear; close all;

fprintf('=== Solar Panel Structural Sizing: Stowed and Deployed Configurations ===\n\n');

L = 7.0;
b = 1.7;
h = 0.028;
c = h/2;
A_face = L * b;

g = 9.81;

a_launch_axial = 6.0 * g; % CHANGED
a_launch_lat   = 2.0 * g;

H_stack = 2.0;

muE = 3.986e14;
RE  = 6378e3;

hp = [300e3, 300e3, 1000e3];
ha = [35786e3, 70000e3, 100000e3];

a_lat_factor = 0.02;
a_orbit_list = zeros(numel(hp),1);

for i = 1:numel(hp)
    rp = RE + hp(i);
    ra = RE + ha(i);
    a_orbit = (rp + ra)/2;
    e_orbit = (ra - rp)/(ra + rp);
    a_c_perigee = muE / rp^2;
    a_orbit_list(i) = a_lat_factor * a_c_perigee;
end

a_orbit_design = max(a_orbit_list);
fprintf('On-orbit design lateral acceleration: %.4f m/s^2\n\n', a_orbit_design);

req.defl_max = 3e-3;
req.f1_min   = 2.0;
req.RF_min   = 1.0;

FOS = 2.0;

n_bolts        = 4;
tau_allow_bolt = 80e6;

materials(1).name        = 'Al honeycomb / Al facesheets';
materials(1).E           = 70e9;
materials(1).sigma_yield = 300e6;
materials(1).rho         = 260;

materials(2).name        = 'CFRP facesheets + core';
materials(2).E           = 140e9;
materials(2).sigma_yield = 600e6;
materials(2).rho         = 225;

materials(3).name        = 'Titanium panel (concept)';
materials(3).E           = 110e9;
materials(3).sigma_yield = 900e6;
materials(3).rho         = 320;

materials(4).name        = 'High-Modulus CFRP';
materials(4).E           = 180e9;
materials(4).sigma_yield = 800e6;
materials(4).rho         = 240;

materials(5).name        = 'GFRP facesheets + core';
materials(5).E           = 45e9;
materials(5).sigma_yield = 300e6;
materials(5).rho         = 280;

materials(6).name        = 'Kevlar facesheets + core';
materials(6).E           = 70e9;
materials(6).sigma_yield = 350e6;
materials(6).rho         = 210;

materials(7).name        = 'Deep-Space CFRP Sandwich (ultra-stiff)';
materials(7).E           = 200e9;
materials(7).sigma_yield = 700e6;
materials(7).rho         = 235;

results = [];

for k = 1:numel(materials)

    mat = materials(k);
    fprintf('--- Material under evaluation: %s ---\n', mat.name);

    E           = mat.E;
    sigma_yield = mat.sigma_yield;
    sigma_allow = sigma_yield / FOS;

    rho     = mat.rho;
    volume  = L * b * h;
    m_total = rho * volume;
    m_per_L = m_total / L;

    F_axial_launch  = m_total * a_launch_axial;
    q_launch_stowed = m_total * a_launch_lat / H_stack;

    I  = (b * h^3) / 12;
    Z  = I / c;
    EI = E * I;

    A_proj = A_face;
    sigma_axial_launch = F_axial_launch / A_proj;
    RF_axial_launch    = sigma_allow / sigma_axial_launch;

    M_max_stowed     = q_launch_stowed * H_stack^2 / 8;
    sigma_lat_launch = M_max_stowed / Z;
    RF_lat_launch    = sigma_allow / sigma_lat_launch;

    q_orbit = m_per_L * a_orbit_design;

    delta_tip = q_orbit * L^4 / (8 * EI);

    omega1 = (1.875^2) * sqrt(EI / (m_per_L * L^4));
    f1     = omega1 / (2*pi);

    M_orbit     = q_orbit * L^2 / 2;
    sigma_orbit = M_orbit / Z;
    RF_orbit    = sigma_allow / sigma_orbit;

    V_orbit    = q_orbit * L;
    V_per_bolt = V_orbit / n_bolts;
    A_bolt_req = V_per_bolt / tau_allow_bolt;
    d_bolt_req = sqrt(4*A_bolt_req/pi);

    delta_L = 5e-6 * 60 * L;

    defl_ok     = (delta_tip <= req.defl_max);
    freq_ok     = (f1 >= req.f1_min);
    RF_axial_ok = (RF_axial_launch >= req.RF_min);
    RF_lat_ok   = (RF_lat_launch >= req.RF_min);
    RF_orbit_ok = (RF_orbit >= req.RF_min);

    all_ok = defl_ok && freq_ok && RF_axial_ok && RF_lat_ok && RF_orbit_ok ...
             && (sigma_axial_launch < sigma_yield) ...
             && (sigma_lat_launch < sigma_yield) ...
             && (sigma_orbit < sigma_yield);

    res = struct();
    res.name               = mat.name;
    res.E                  = E;
    res.sigma_yield        = sigma_yield;
    res.sigma_allow        = sigma_allow;
    res.I                  = I;
    res.Z                  = Z;
    res.EI                 = EI;
    res.rho                = rho;
    res.m_total            = m_total;
    res.m_per_L            = m_per_L;
    res.q_launch_stowed    = q_launch_stowed;
    res.F_axial_launch     = F_axial_launch;
    res.sigma_axial_launch = sigma_axial_launch;
    res.RF_axial_launch    = RF_axial_launch;
    res.sigma_lat_launch   = sigma_lat_launch;
    res.RF_lat_launch      = RF_lat_launch;
    res.q_orbit            = q_orbit;
    res.delta_tip          = delta_tip;
    res.f1                 = f1;
    res.M_orbit            = M_orbit;
    res.sigma_orbit        = sigma_orbit;
    res.RF_orbit           = RF_orbit;
    res.V_orbit            = V_orbit;
    res.V_per_bolt         = V_per_bolt;
    res.d_bolt_req         = d_bolt_req;
    res.delta_L            = delta_L;
    res.defl_ok            = defl_ok;
    res.freq_ok            = freq_ok;
    res.RF_axial_ok        = RF_axial_ok;
    res.RF_lat_ok          = RF_lat_ok;
    res.RF_orbit_ok        = RF_orbit_ok;
    res.all_ok             = all_ok;

    results = [results; res]; %#ok<AGROW>

    fprintf('  Elastic modulus            = %.1f GPa\n', E/1e9);
    fprintf('  Yield stress               = %.1f MPa\n', sigma_yield/1e6);
    fprintf('  Allowable stress           = %.1f MPa\n', sigma_allow/1e6);
    fprintf('  Mass per wing              = %.1f kg\n', m_total);

    fprintf('  Launch case (stowed):\n');
    fprintf('    Axial load               = %.1f N\n', F_axial_launch);
    fprintf('    Axial stress             = %.3f MPa\n', sigma_axial_launch/1e6);
    fprintf('    Axial reserve factor     = %.2f --> %s\n', RF_axial_launch, ternary(RF_axial_ok,'OK','FAIL'));
    fprintf('    Lateral bending stress   = %.3f MPa\n', sigma_lat_launch/1e6);
    fprintf('    Lateral reserve factor   = %.2f --> %s\n', RF_lat_launch, ternary(RF_lat_ok,'OK','FAIL'));

    fprintf('  On-orbit case (deployed):\n');
    fprintf('    Tip deflection           = %.3f mm --> %s\n', delta_tip*1e3, ternary(defl_ok,'OK','FAIL'));
    fprintf('    First bending frequency  = %.2f Hz --> %s\n', f1, ternary(freq_ok,'OK','FAIL'));
    fprintf('    Root bending stress      = %.3f MPa\n', sigma_orbit/1e6);
    fprintf('    On-orbit reserve factor  = %.2f --> %s\n', RF_orbit, ternary(RF_orbit_ok,'OK','FAIL'));
    fprintf('    Root shear               = %.2f N\n', V_orbit);
    fprintf('    Shear per bolt           = %.2f N\n', V_per_bolt);
    fprintf('    Required bolt diameter   = %.2f mm\n', d_bolt_req*1e3);
    fprintf('    Free thermal expansion   = %.3f mm\n', delta_L*1e3);

    if all_ok
        fprintf('>>> All requirements are satisfied for this material.\n\n');
    else
        fprintf('>>> At least one requirement is not satisfied for this material.\n\n');
    end

end

nMat = numel(results);
names = strings(nMat,1);
f1_all = zeros(nMat,1);
delta_all = zeros(nMat,1);
RF_axial_all = zeros(nMat,1);
RF_lat_all   = zeros(nMat,1);
RF_orbit_all = zeros(nMat,1);

for i = 1:nMat
    names(i)        = results(i).name;
    f1_all(i)       = results(i).f1;
    delta_all(i)    = results(i).delta_tip * 1e3;
    RF_axial_all(i) = results(i).RF_axial_launch;
    RF_lat_all(i)   = results(i).RF_lat_launch;
    RF_orbit_all(i) = results(i).RF_orbit;
end

figure;
bar(f1_all);
set(gca,'XTickLabel',names,'XTick',1:nMat,'XTickLabelRotation',20);
ylabel('First bending frequency f_1 [Hz]');
title('Deployed panel: first bending frequency by material');
grid on;

figure;
bar(delta_all);
set(gca,'XTickLabel',names,'XTick',1:nMat,'XTickLabelRotation',20);
ylabel('Tip deflection on-orbit [mm]');
title('Deployed panel: tip deflection by material');
grid on;

figure;
bar([RF_axial_all RF_lat_all]);
set(gca,'XTickLabel',names,'XTick',1:nMat,'XTickLabelRotation',20);
ylabel('Reserve factor');
legend('Axial (stowed)','Lateral bending (stowed)','Location','NorthWest');
title('Launch reserve factors by material');
grid on;

figure;
bar(RF_orbit_all);
set(gca,'XTickLabel',names,'XTick',1:nMat,'XTickLabelRotation',20);
ylabel('On-orbit bending reserve factor');
title('Deployed panel: on-orbit reserve factor by material');
grid on;

RF_launch_min = min(RF_axial_all, RF_lat_all);
colors = lines(nMat);

figure;
hold on;
for i = 1:nMat
    scatter(f1_all(i), RF_launch_min(i), 120, colors(i,:), 'filled', ...
        'MarkerEdgeColor','k', 'LineWidth',1.2);
end

grid on;
xlabel('First bending frequency f_1 [Hz]', 'FontSize', 14, 'FontWeight', 'bold');
ylabel('Minimum launch reserve factor', 'FontSize', 14, 'FontWeight', 'bold');
title('Material performance map: stiffness versus launch strength', 'FontSize', 16, 'FontWeight', 'bold');
set(gca, 'FontSize', 14, 'LineWidth', 1.5);

for i = 1:nMat
    text(f1_all(i) + 0.05, RF_launch_min(i) + 5, names(i), ...
        'FontSize', 12, 'FontWeight', 'bold', ...
        'Interpreter','none', 'Color', colors(i,:));
end
hold off;

delta_launch_mm = zeros(nMat,1);
delta_orbit_mm  = zeros(nMat,1);

for i = 1:nMat
    EI_i = results(i).EI;
    qL_i = results(i).q_launch_stowed;

    delta_launch = 5 * qL_i * H_stack^4 / (384 * EI_i);
    delta_orbit  = results(i).delta_tip;

    delta_launch_mm(i) = delta_launch * 1e3;
    delta_orbit_mm(i)  = delta_orbit * 1e3;
end

figure;
bar([delta_launch_mm delta_orbit_mm]);
set(gca,'XTick',1:nMat,'XTickLabel',names,'XTickLabelRotation',20);
ylabel('Maximum deflection [mm]','FontSize',14,'FontWeight','bold');
title('Comparison of launch and on-orbit deflection by material', 'FontSize',16,'FontWeight','bold');
legend({'Launch deflection (stowed)', 'On-orbit deflection (deployed)'}, 'Location','northwest');
set(gca,'FontSize',14,'LineWidth',1.5);
grid on;

masses    = zeros(nMat,1);
f1_vals   = zeros(nMat,1);
defl_vals = zeros(nMat,1);

for i = 1:nMat
    masses(i)    = results(i).m_total;
    f1_vals(i)   = results(i).f1;
    defl_vals(i) = results(i).delta_tip * 1e3;
end

figure;
scatter(masses, defl_vals, 120, colors, 'filled', 'MarkerEdgeColor','k');
grid on;
xlabel('Mass per wing [kg]', 'FontSize', 14, 'FontWeight','bold');
ylabel('Tip deflection (on-orbit) [mm]', 'FontSize', 14, 'FontWeight','bold');
title('Deflection versus mass: material trade-off', 'FontSize', 16, 'FontWeight','bold');
set(gca,'FontSize',14,'LineWidth',1.5);
for i = 1:nMat
    text(masses(i)+0.5, defl_vals(i)+0.1, names(i), 'FontSize', 12);
end

figure;
scatter(masses, f1_vals, 120, colors, 'filled', 'MarkerEdgeColor','k');
grid on;
xlabel('Mass per wing [kg]', 'FontSize', 14, 'FontWeight','bold');
ylabel('First bending frequency f_1 [Hz]', 'FontSize', 14, 'FontWeight','bold');
title('Frequency versus mass: material trade-off', 'FontSize', 16, 'FontWeight','bold');
set(gca,'FontSize',14,'LineWidth',1.5);
for i = 1:nMat
    text(masses(i)+0.5, f1_vals(i)+0.05, names(i), 'FontSize', 12);
end

function out = ternary(cond,a,b)
    if cond
        out = a;
    else
        out = b;
    end
end