clear; clc; close all;

%% Launcher and bus sizing
launcher.fairingID     = 4.60;
launcher.radialMargin  = 0.25;
launcher.usableID      = launcher.fairingID - 2*launcher.radialMargin;
launcher.maxSquareSide = launcher.usableID / sqrt(2);

scale  = 0.90;
bus.W  = scale * launcher.maxSquareSide;
bus.H  = scale * launcher.maxSquareSide;
bus.L  = 4.20;
bus.wallMargin = 0.05;

fprintf("Bus dims [L W H] = [%.2f %.2f %.2f] m\n", bus.L, bus.W, bus.H);

%% Structure mass model
bus.structMass = 350;
bus.structPos  = [0 0 0];

structureItem.name = "STRUCTURE";
structureItem.type = "STRUCTURE";
structureItem.shape= "BOX";
structureItem.dims = [0 0 0];
structureItem.mass = bus.structMass;
structureItem.pos  = bus.structPos;
structureItem.massDry = NaN;
structureItem.propMass = NaN;

%% Discrete grid for non-tank items
grid.dx = 0.25;
grid.dy = 0.25;
grid.dz = 0.20;

xMin = -bus.L/2 + bus.wallMargin;
xMax =  bus.L/2 - bus.wallMargin;
bus.xStations = xMin:grid.dx:xMax;

%% Wall bands and zoning
bus.payloadWallBand = 0.55;
bus.yPayloadMin =  bus.W/2 - bus.wallMargin - bus.payloadWallBand;

bus.elecWallBand = 0.70;
bus.yElecMax = -bus.W/2 + bus.wallMargin + bus.elecWallBand;

bus.zone.payloadXmin = +0.10;
bus.zone.serviceXmax = -0.10;
bus.zone.propXmax    = -0.40;

%% EGG constraints
bus.gg.coreHalfSize  = [0.55 0.45 0.45];
bus.gg.tankClearR    = 0.40;
bus.gg.hotClearR     = 0.90;
bus.gg.vaultHalfSize = [0.85 0.70 0.70];
bus.gg.jitterClearR  = 1.75;

%% Fill states
fillStates = [1.00 0.50 0.10];

%% Components
components = struct([]);
k = 1;

chemDims = [1.1 0.9 0.9];
epDims   = [1.1 0.9 0.9];

components(k).name     = "Chem Tank +X";
components(k).type     = "TANK_CHEM";
components(k).shape    = "ELLIPSOID";
components(k).dims     = chemDims;
components(k).massDry  = 120;
components(k).propMass = 5000/2;
components(k).mass     = components(k).massDry + fillStates(1)*components(k).propMass;
k = k + 1;

components(k).name     = "Chem Tank -X";
components(k).type     = "TANK_CHEM";
components(k).shape    = "ELLIPSOID";
components(k).dims     = chemDims;
components(k).massDry  = 120;
components(k).propMass = 5000/2;
components(k).mass     = components(k).massDry + fillStates(1)*components(k).propMass;
k = k + 1;

components(k).name     = "EP Tank +X";
components(k).type     = "TANK_EP";
components(k).shape    = "ELLIPSOID";
components(k).dims     = epDims;
components(k).massDry  = 55;
components(k).propMass = 500/2;
components(k).mass     = components(k).massDry + fillStates(1)*components(k).propMass;
k = k + 1;

components(k).name     = "EP Tank -X";
components(k).type     = "TANK_EP";
components(k).shape    = "ELLIPSOID";
components(k).dims     = epDims;
components(k).massDry  = 55;
components(k).propMass = 500/2;
components(k).mass     = components(k).massDry + fillStates(1)*components(k).propMass;
k = k + 1;

components(k).name     = "EGG";
components(k).type     = "EGG";
components(k).shape    = "BOX";
components(k).dims     = [0.80 1.00 0.80];
components(k).mass     = 150;
components(k).massDry  = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "Nav Camera (W/N)";
components(k).type = "PAYLOAD_FOV";
components(k).shape= "BOX";
components(k).dims = [0.45 0.30 0.30];
components(k).mass = 35;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "Scanning LiDAR";
components(k).type = "PAYLOAD_FOV";
components(k).shape= "BOX";
components(k).dims = [0.55 0.45 0.35];
components(k).mass = 25;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "REXIS (X-ray Spectrometer)";
components(k).type = "PAYLOAD_FOV";
components(k).shape= "BOX";
components(k).dims = [0.37 0.20 0.20];
components(k).mass = 6.5;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "OTES (Thermal IR Spectrometer)";
components(k).type = "PAYLOAD_FOV";
components(k).shape= "BOX";
components(k).dims = [0.375 0.289 0.522];
components(k).mass = 6.27;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "Reaction Wheels (4x in one deck)";
components(k).type = "JITTER";
components(k).shape= "BOX";
components(k).dims = [0.60 0.50 0.30];
components(k).mass = 48;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "PPU (EP Power Proc Unit)";
components(k).type = "HOT_ELEC";
components(k).shape= "BOX";
components(k).dims = [0.60 0.45 0.25];
components(k).mass = 60;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "PCDU (Power Control/Dist)";
components(k).type = "HOT_ELEC";
components(k).shape= "BOX";
components(k).dims = [0.60 0.40 0.25];
components(k).mass = 55;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "Battery";
components(k).type = "HOT_ELEC";
components(k).shape= "BOX";
components(k).dims = [0.80 0.50 0.25];
components(k).mass = 80;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "TWTA/SSPA (RF Power Amp)";
components(k).type = "HOT_ELEC";
components(k).shape= "BOX";
components(k).dims = [0.40 0.25 0.15];
components(k).mass = 18;
components(k).massDry = NaN;
components(k).propMass = NaN;
k = k + 1;

components(k).name = "OBC + Mass Memory";
components(k).type = "AVIONICS";
components(k).shape= "BOX";
components(k).dims = [0.40 0.30 0.20];
components(k).mass = 24;
components(k).massDry = NaN;
components(k).propMass = NaN;

%% Candidate grid points
candidates = make_candidate_points_grid_only(bus, grid);

%% Placement
layout.items = [];
layout.items = [layout.items structureItem];
eggPos = [NaN NaN NaN];

idxChem = find(strcmp([components.type], "TANK_CHEM"), 1);
idxEP   = find(strcmp([components.type], "TANK_EP"), 1);
idxEGG  = find(strcmp([components.type], "EGG"), 1);

bus.tankEndBand  = 0.90;
bus.xTankPlusMin =  bus.L/2 - bus.wallMargin - bus.tankEndBand;
bus.xTankMinusMax= -bus.L/2 + bus.wallMargin + bus.tankEndBand;

bus.tankPairGap = 0.10;
bus.tankPairAxis = "Z";
bus.tankPairTolY  = 1e-6;

bus.tankZFixedPlus  = +0.5;
bus.tankZFixedMinus = -0.5;
bus.tankZAssignChem = "PLUS";

bus.thrustLineY0 = 0.0;
bus.thrustLineZ0 = 0.0;
bus.thrustLineYZmax = 0.60;

idxChemAll = find(strcmp([components.type], "TANK_CHEM"));
idxEPAll   = find(strcmp([components.type], "TANK_EP"));

idxChemP = idxChemAll(contains(string({components(idxChemAll).name}), "+X"));
idxChemM = idxChemAll(contains(string({components(idxChemAll).name}), "-X"));
idxEPP   = idxEPAll(contains(string({components(idxEPAll).name}), "+X"));
idxEPM   = idxEPAll(contains(string({components(idxEPAll).name}), "-X"));

[pcPlus, pcMinus, pePlus, peMinus, ok4] = place_4tanks_symmetric_x( ...
    components(idxChemP), components(idxChemM), ...
    components(idxEPP),   components(idxEPM), ...
    bus, fillStates, layout);

if ~ok4
    error("Could not place all 4 tanks.");
end

itCP = components(idxChemP); itCP.pos = pcPlus;
itCM = components(idxChemM); itCM.pos = pcMinus;
itEP = components(idxEPP);   itEP.pos = pePlus;
itEM = components(idxEPM);   itEM.pos = peMinus;

layout.items = [layout.items itCP itCM itEP itEM];

fillForEgg = 0.50;
cmRef = compute_cm(layout, fillForEgg);

[eggBest, okEgg] = place_egg_on_grid_near_cm(components(idxEGG), layout, candidates, bus, cmRef);

if ~okEgg
    error("Could not place EGG near CM.");
end

itG = components(idxEGG); itG.pos = eggBest;
layout.items = [layout.items itG];
eggPos = eggBest;

fprintf("EGG placed near CM(%.0f%%): CM=[%+.2f %+.2f %+.2f], EGG=[%+.2f %+.2f %+.2f], dist=%.2f\n", ...
    100*fillForEgg, cmRef(1), cmRef(2), cmRef(3), eggPos(1), eggPos(2), eggPos(3), norm(cmRef-eggPos));

orderTypes = ["JITTER","HOT_ELEC","AVIONICS","PAYLOAD_FOV"];
idxChemAll = find(strcmp([components.type], "TANK_CHEM"));
idxEPAll   = find(strcmp([components.type], "TANK_EP"));
idxTanksAll = [idxChemAll idxEPAll];

idxRest = setdiff(1:numel(components), [idxTanksAll idxEGG], 'stable');

payloadBandList = [bus.payloadWallBand 0.70 0.85 1.05];
elecBandList    = [bus.elecWallBand    0.85 1.05 1.25];

placedAll = false;
for rr = 1:numel(payloadBandList)
    bus.payloadWallBand = payloadBandList(rr);
    bus.yPayloadMin =  bus.W/2 - bus.wallMargin - bus.payloadWallBand;

    bus.elecWallBand = elecBandList(rr);
    bus.yElecMax = -bus.W/2 + bus.wallMargin + bus.elecWallBand;

    layoutTry = layout;
    okAll = true;

    for t = 1:numel(orderTypes)
        tname = orderTypes(t);
        ids = idxRest(strcmp([components(idxRest).type], tname));

        for j = 1:numel(ids)
            comp = components(ids(j));

            [bestPos, ok] = find_best_position_grid(comp, layoutTry, candidates, bus, eggPos, fillStates);
            if ~ok
                okAll = false;
                break;
            end

            item = comp; item.pos = bestPos;
            layoutTry.items = [layoutTry.items item];

            rCM50 = compute_cm(layoutTry, 0.50);
            fprintf("Placed %-24s | CM50=[%+.2f %+.2f %+.2f] | dist(CM50-EGG)=%.2f\n", ...
                item.name, rCM50(1), rCM50(2), rCM50(3), norm(rCM50-eggPos));
        end

        if ~okAll, break; end
    end

    if okAll
        layout = layoutTry;
        placedAll = true;
        fprintf("Placed all components with wall bands: payloadBand=%.2f, elecBand=%.2f\n", ...
            bus.payloadWallBand, bus.elecWallBand);
        break;
    end
end

if ~placedAll
    error("Could not place all components even after relaxing wall bands.");
end

layout = local_improve(layout, candidates, bus, eggPos, fillStates);

%% Report
disp("==== FIRST-LEVEL LAYOUT RESULT ====");
for i = 1:numel(layout.items)
    it = layout.items(i);
    fprintf("%2d) %-28s type=%-11s pos=[%+.2f %+.2f %+.2f] dims=[%.2f %.2f %.2f]\n", ...
        i, it.name, it.type, it.pos(1), it.pos(2), it.pos(3), it.dims(1), it.dims(2), it.dims(3));
end

fprintf("\n==== CM vs tank fill states (100%% / 50%% / 10%%) ====\n");
for s = 1:numel(fillStates)
    fs = fillStates(s);
    rCM = compute_cm(layout, fs);
    fprintf("Fill=%.0f%% -> CM = [%.2f %.2f %.2f] m | dist(CM-EGG)=%.2f m\n", ...
        100*fs, rCM(1), rCM(2), rCM(3), norm(rCM-eggPos));
end

rCM50 = compute_cm(layout, 0.50);
plot_layout(layout, bus, rCM50);

function candidates = make_candidate_points_grid_only(bus, grid)
yMin = -bus.W/2 + bus.wallMargin; yMax = bus.W/2 - bus.wallMargin;
zMin = -bus.H/2 + bus.wallMargin; zMax = bus.H/2 - bus.wallMargin;

ys = yMin:grid.dy:yMax;
zs = zMin:grid.dz:zMax;
xs = bus.xStations;

candidates = zeros(numel(xs)*numel(ys)*numel(zs),3);
k = 1;
for ix = 1:numel(xs)
    for iy = 1:numel(ys)
        for iz = 1:numel(zs)
            candidates(k,:) = [xs(ix), ys(iy), zs(iz)];
            k = k + 1;
        end
    end
end
end

function [chemPos, epPos, ok] = place_tank_pair_continuous_to_egg(chemTank, epTank, bus, fillStates, layoutBase, eggPos)
ok = false;
chemPos = [NaN NaN NaN];
epPos   = [NaN NaN NaN];

N = 20000;
bestScore = inf;

[chemMin, chemMax] = center_bounds(bus, chemTank.dims);
[epMin,   epMax]   = center_bounds(bus, epTank.dims);

for i = 1:N
    pc = rand_in_box(chemMin, chemMax);
    pe = rand_in_box(epMin,   epMax);

    if aabb_overlap(pc, chemTank.dims, pe, epTank.dims), continue; end
    if norm(pc - eggPos) < bus.gg.tankClearR, continue; end
    if norm(pe - eggPos) < bus.gg.tankClearR, continue; end

    if overlaps_any_aabb(pc, chemTank.dims, layoutBase), continue; end
    if overlaps_any_aabb(pe, epTank.dims, layoutBase), continue; end

    trial = layoutBase;
    cIt = chemTank; cIt.pos = pc;
    eIt = epTank;   eIt.pos = pe;
    trial.items = [trial.items cIt eIt];

    worstEgg = 0;
    worstYZ  = 0;
    for s = 1:numel(fillStates)
        fs = fillStates(s);
        rCM = compute_cm(trial, fs);
        worstEgg = max(worstEgg, norm(rCM - eggPos));
        worstYZ  = max(worstYZ, abs(rCM(2)) + abs(rCM(3)));
    end

    score = 600*worstEgg ...
          +  8*(abs(pc(2))+abs(pc(3))+abs(pe(2))+abs(pe(3))) ...
          +  2*max(0, pc(1) + 0.40) + 2*max(0, pe(1) + 0.40) ...
          + 10*worstYZ;

    if score < bestScore
        bestScore = score;
        chemPos = pc;
        epPos   = pe;
        ok = true;
    end
end
end

function [bestPos, ok] = find_best_position_grid(comp, layout, candidates, bus, eggPos, fillStates)
ok = false;
bestPos = [NaN NaN NaN];
bestScore = inf;

elecCenter = compute_cluster_center(layout, ["HOT_ELEC","AVIONICS"]);

for k = 1:size(candidates,1)
    p = candidates(k,:);

    if ~fits_inside_bus(p, comp.dims, bus), continue; end
    if overlaps_any_aabb(p, comp.dims, layout), continue; end
    if ~passes_hard_constraints(p, comp, bus, eggPos, layout), continue; end

    trial = layout;
    it = comp; it.pos = p;
    trial.items = [trial.items it];

    score = score_position(comp, p, trial, bus, eggPos, fillStates, elecCenter);

    if score < bestScore
        bestScore = score;
        bestPos = p;
        ok = true;
    end
end
end

function tf = passes_hard_constraints(p, comp, bus, eggPos, layout)
tf = true;

if comp.type == "EGG"
    if any(abs(p - [0 0 0]) > bus.gg.coreHalfSize)
        tf = false; return;
    end
end

if comp.type == "PAYLOAD_FOV"
    if p(2) < bus.yPayloadMin
        tf = false; return;
    end
end

if comp.type == "HOT_ELEC" || comp.type == "AVIONICS"
    if p(2) > bus.yElecMax
        tf = false; return;
    end
end

if all(isfinite(eggPos))
    if comp.type == "HOT_ELEC"
        if norm(p - eggPos) < bus.gg.hotClearR
            tf = false; return;
        end
        if all(abs(p - eggPos) < bus.gg.vaultHalfSize)
            tf = false; return;
        end
    end

    if comp.type == "JITTER"
        if norm(p - eggPos) < bus.gg.jitterClearR
            tf = false; return;
        end
    end

    if comp.type == "PAYLOAD_FOV"
        if norm(p - eggPos) < 0.55
            tf = false; return;
        end
    end
end
end

function sc = score_position(comp, p, trial, bus, eggPos, fillStates, elecCenter)
worstToEgg = 0;
sumYZ = 0;
for s = 1:numel(fillStates)
    fs = fillStates(s);
    rCM = compute_cm(trial, fs);
    worstToEgg = max(worstToEgg, norm(rCM - eggPos));
    sumYZ = sumYZ + abs(rCM(2)) + abs(rCM(3));
end

zonePenalty = 0;
if comp.type == "PAYLOAD_FOV"
    if p(1) < bus.zone.payloadXmin
        zonePenalty = zonePenalty + 50*(bus.zone.payloadXmin - p(1));
    end
elseif comp.type == "HOT_ELEC" || comp.type == "AVIONICS"
    if p(1) > bus.zone.serviceXmax
        zonePenalty = zonePenalty + 40*(p(1) - bus.zone.serviceXmax);
    end
end

clusterPenalty = 0;
if comp.type == "HOT_ELEC" || comp.type == "AVIONICS"
    if all(isfinite(elecCenter))
        clusterPenalty = 25 * norm(p - elecCenter);
    end
    yWall = -bus.W/2 + bus.wallMargin;
    clusterPenalty = clusterPenalty + 20 * abs(p(2) - (yWall + 0.15));
end

payloadWallPenalty = 0;
if comp.type == "PAYLOAD_FOV"
    yWall = bus.W/2 - bus.wallMargin;
    payloadWallPenalty = 20 * abs(p(2) - (yWall - 0.15));
end

if comp.type == "JITTER"
    sc = 80*worstToEgg + 8*abs(p(2)) + 8*abs(p(3));
elseif comp.type == "HOT_ELEC"
    sc = 65*worstToEgg + 3*sumYZ + clusterPenalty;
elseif comp.type == "AVIONICS"
    sc = 55*worstToEgg + 2*sumYZ + clusterPenalty;
else
    sc = 45*worstToEgg + 6*sumYZ + payloadWallPenalty + 10*(bus.L/2 - p(1));
end

sc = sc + zonePenalty;
end

function yes = fits_inside_bus(p, dims, bus)
h = dims/2;
yes = true;
if p(1)-h(1) < -bus.L/2 + bus.wallMargin, yes=false; return; end
if p(1)+h(1) >  bus.L/2 - bus.wallMargin, yes=false; return; end
if p(2)-h(2) < -bus.W/2 + bus.wallMargin, yes=false; return; end
if p(2)+h(2) >  bus.W/2 - bus.wallMargin, yes=false; return; end
if p(3)-h(3) < -bus.H/2 + bus.wallMargin, yes=false; return; end
if p(3)+h(3) >  bus.H/2 - bus.wallMargin, yes=false; return; end
end

function ov = overlaps_any_aabb(p, dims, layout)
ov = false;
for i = 1:numel(layout.items)
    if layout.items(i).type == "STRUCTURE"
        continue;
    end
    if aabb_overlap(p, dims, layout.items(i).pos, layout.items(i).dims)
        ov = true; return;
    end
end
end

function yes = aabb_overlap(pA, dA, pB, dB)
[aMin,aMax] = aabb(pA,dA);
[bMin,bMax] = aabb(pB,dB);
yes = all(aMin < bMax & aMax > bMin);
end

function [mn,mx] = aabb(p,d)
h = d/2;
mn = p - h;
mx = p + h;
end

function m = comp_mass_at_fill(it, fill)
if startsWith(string(it.type),"TANK")
    m = it.massDry + fill * it.propMass;
else
    m = it.mass;
end
end

function rCM = compute_cm(layout, fill)
M = 0; Mr = [0 0 0];
for i = 1:numel(layout.items)
    it = layout.items(i);
    m = comp_mass_at_fill(it, fill);
    M = M + m;
    Mr = Mr + m * it.pos;
end
rCM = Mr / max(M, eps);
end

function c = compute_cluster_center(layout, types)
pts = [];
for i = 1:numel(layout.items)
    if any(layout.items(i).type == types)
        pts = [pts; layout.items(i).pos]; %#ok<AGROW>
    end
end
if isempty(pts)
    c = [NaN NaN NaN];
else
    c = mean(pts, 1);
end
end

function [mn, mx] = center_bounds(bus, dims)
h = dims/2;
mn = [-bus.L/2 + bus.wallMargin + h(1), -bus.W/2 + bus.wallMargin + h(2), -bus.H/2 + bus.wallMargin + h(3)];
mx = [ bus.L/2 - bus.wallMargin - h(1),  bus.W/2 - bus.wallMargin - h(2),  bus.H/2 - bus.wallMargin - h(3)];
end

function p = rand_in_box(mn, mx)
p = mn + rand(1,3).*(mx - mn);
end

function layout = local_improve(layout, candidates, bus, eggPos, fillStates)
maxPass = 2;
for pass = 1:maxPass
    improved = false;

    for i = 1:numel(layout.items)
        if any(layout.items(i).type == ["STRUCTURE","EGG","TANK_CHEM","TANK_EP"])
            continue;
        end

        comp = layout.items(i);
        bestPos = comp.pos;
        bestScore = inf;

        layoutMinus = layout;
        layoutMinus.items(i) = [];

        elecCenter = compute_cluster_center(layoutMinus, ["HOT_ELEC","AVIONICS"]);

        d = sqrt(sum((candidates - comp.pos).^2,2));
        [~, ord] = sort(d, 'ascend');
        tryN = min(150, numel(ord));

        for k = 1:tryN
            p = candidates(ord(k),:);
            if ~fits_inside_bus(p, comp.dims, bus), continue; end
            if overlaps_any_aabb(p, comp.dims, layoutMinus), continue; end
            if ~passes_hard_constraints(p, comp, bus, eggPos, layoutMinus), continue; end

            trial = layoutMinus;
            it = comp; it.pos = p;
            trial.items = [trial.items it];

            sc = score_position(comp, p, trial, bus, eggPos, fillStates, elecCenter);

            if sc < bestScore
                bestScore = sc;
                bestPos = p;
            end
        end

        if norm(bestPos - comp.pos) > 1e-6
            layout.items(i).pos = bestPos;
            improved = true;
        end
    end

    if ~improved
        break;
    end
end
end

function plot_layout(layout, bus, rCM)
figure; hold on; grid on; axis equal;
xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]');
title('First-Level Layout');

plot_box_solid([0 0 0], [bus.L bus.W bus.H], 0.05);

eggPos = [NaN NaN NaN];
for i = 1:numel(layout.items)
    if layout.items(i).type == "EGG"
        eggPos = layout.items(i).pos;
    end
end

for i = 1:numel(layout.items)
    it = layout.items(i);
    if it.type == "STRUCTURE", continue; end

    if isfield(it,'shape') && it.shape == "ELLIPSOID"
        plot_ellipsoid(it.pos, it.dims/2, 0.25);
        text(it.pos(1),it.pos(2),it.pos(3), " " + it.name, 'FontSize',8);
    else
        plot_box_solid(it.pos, it.dims, 0.25);
        text(it.pos(1),it.pos(2),it.pos(3), " " + it.name, 'FontSize',8);
    end
end

plot3(rCM(1), rCM(2), rCM(3), 'ko', 'MarkerFaceColor','k');
text(rCM(1), rCM(2), rCM(3), sprintf("  CM(50%%) | dist to EGG=%.2f m", norm(rCM-eggPos)), 'FontSize',9);

view(35,25);
end

function plot_box_solid(c,d,alphaVal)
hx=d(1)/2; hy=d(2)/2; hz=d(3)/2;
x=c(1); y=c(2); z=c(3);

V = [ ...
    x-hx y-hy z-hz;
    x+hx y-hy z-hz;
    x+hx y+hy z-hz;
    x-hx y+hy z-hz;
    x-hx y-hy z+hz;
    x+hx y-hy z+hz;
    x+hx y+hy z+hz;
    x-hx y+hy z+hz];

F = [ ...
    1 2 3 4;
    5 6 7 8;
    1 2 6 5;
    2 3 7 6;
    3 4 8 7;
    4 1 5 8];

patch('Vertices',V,'Faces',F,'FaceAlpha',alphaVal,'EdgeColor','k');
end

function plot_ellipsoid(c, a, alphaVal)
n = 18;
[ux,uy,uz] = sphere(n);
X = c(1) + a(1)*ux;
Y = c(2) + a(2)*uy;
Z = c(3) + a(3)*uz;
surf(X,Y,Z,'FaceAlpha',alphaVal,'EdgeColor','none');
mesh(X,Y,Z,'EdgeAlpha',0.15,'FaceAlpha',0);
end

function [pcPlus, pcMinus, pePlus, peMinus, ok] = place_4tanks_symmetric_x( ...
    chemPlus, chemMinus, epPlus, epMinus, bus, fillStates, layoutBase)

ok = false;

pcPlus  = [NaN NaN NaN];
pcMinus = [NaN NaN NaN];
pePlus  = [NaN NaN NaN];
peMinus = [NaN NaN NaN];

N = 40000;
bestScore = inf;

zA = +0.5;
zB = -0.5;

if abs(zA) > (bus.H/2 - bus.wallMargin) || ...
   abs(zB) > (bus.H/2 - bus.wallMargin)
    return;
end

[chemMinP, chemMaxP] = center_bounds(bus, chemPlus.dims);
[epMinP,   epMaxP]   = center_bounds(bus, epPlus.dims);

mn = max(chemMinP, epMinP);
mx = min(chemMaxP, epMaxP);

mn(1) = max(mn(1), bus.xTankPlusMin);

for i = 1:N

    p0 = rand_in_box(mn, mx);

    if abs(p0(2) - bus.thrustLineY0) > bus.thrustLineYZmax
        continue;
    end

    x0 = p0(1);
    y0 = p0(2);

    pcP = [x0, y0, zA];
    peP = [x0, y0, zB];

    if ~fits_inside_bus(pcP, chemPlus.dims, bus), continue; end
    if ~fits_inside_bus(peP, epPlus.dims,   bus), continue; end

    pcM = [-pcP(1), pcP(2), pcP(3)];
    peM = [-peP(1), peP(2), peP(3)];

    if pcM(1) > bus.xTankMinusMax, continue; end
    if peM(1) > bus.xTankMinusMax, continue; end

    if ~fits_inside_bus(pcM, chemMinus.dims, bus), continue; end
    if ~fits_inside_bus(peM, epMinus.dims,   bus), continue; end

    if aabb_overlap(pcP, chemPlus.dims, peP, epPlus.dims), continue; end
    if aabb_overlap(pcM, chemMinus.dims, peM, epMinus.dims), continue; end

    if overlaps_any_aabb(pcP, chemPlus.dims, layoutBase), continue; end
    if overlaps_any_aabb(peP, epPlus.dims,   layoutBase), continue; end
    if overlaps_any_aabb(pcM, chemMinus.dims, layoutBase), continue; end
    if overlaps_any_aabb(peM, epMinus.dims,   layoutBase), continue; end

    trial = layoutBase;

    cP = chemPlus;  cP.pos = pcP;
    cM = chemMinus; cM.pos = pcM;
    eP = epPlus;    eP.pos = peP;
    eM = epMinus;   eM.pos = peM;

    trial.items = [trial.items cP cM eP eM];

    worstYZ = 0;
    for s = 1:numel(fillStates)
        rCM = compute_cm(trial, fillStates(s));
        worstYZ = max(worstYZ, abs(rCM(2)) + abs(rCM(3)));
    end

    yzPenalty = 5 * (abs(pcP(2)) + abs(peP(2)));
    xTarget   = bus.L/2 - bus.wallMargin - 0.25;
    xPenalty  = 2 * (abs(pcP(1) - xTarget) + abs(peP(1) - xTarget));

    score = 200*worstYZ + yzPenalty + xPenalty;

    if score < bestScore
        bestScore = score;

        pcPlus  = pcP;
        pcMinus = pcM;
        pePlus  = peP;
        peMinus = peM;

        ok = true;
    end
end

end

function [eggPos, ok] = place_egg_on_grid_near_cm(eggComp, layout, candidates, bus, cmTarget)
ok = false;
eggPos = [NaN NaN NaN];

d = sqrt(sum((candidates - cmTarget).^2, 2));
[~, ord] = sort(d, 'ascend');

for ii = 1:numel(ord)
    p = candidates(ord(ii), :);

    if ~fits_inside_bus(p, eggComp.dims, bus), continue; end
    if any(abs(p - [0 0 0]) > bus.gg.coreHalfSize), continue; end
    if overlaps_any_aabb(p, eggComp.dims, layout), continue; end

    eggPos = p;
    ok = true;
    return;
end
end