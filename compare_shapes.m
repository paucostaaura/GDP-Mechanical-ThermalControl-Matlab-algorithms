function results = compare_shapes()

    fairing.Dint = 4.6;
    fairing.Huse = 11.0;
    keepout = 0.10;

    A_rad_min = 1.0;
    A_payload_min = 0.4;

    eggEnv = [0.6 0.6 0.8];
    coreFill = 0.80;

    w.V     = 0.25;
    w.Arad  = 0.25;
    w.Ap    = 0.10;
    w.f1    = 0.15;
    w.scale = 0.10;
    w.egg   = 0.15;

    cands = struct('type', {}, 'dims', {});
    cands(end+1) = makeCand("box",           struct("L",1.8,"W",1.8,"H",1.8));
    cands(end+1) = makeCand("rectangle-box", struct("L",1.8,"W",1.8,"H",2.2));
    cands(end+1) = makeCand("hex",           struct("R",1.0,"H",1.8));
    cands(end+1) = makeCand("cyl",           struct("R",0.65,"H",1.8));
    cands(end+1) = makeCand("frustum",       struct("R1",0.75,"R2",0.55,"H",1.8));
    cands(end+1) = makeCand("slab",          struct("L",4,"W",1.2,"H",0.8));

    M = repmat(evalCandEasy(cands(1), fairing, keepout, eggEnv, coreFill), numel(cands), 1);
    for i = 2:numel(cands)
        M(i) = evalCandEasy(cands(i), fairing, keepout, eggEnv, coreFill);
    end

    feasible = true(numel(cands),1);
    for i=1:numel(cands)
        if ~M(i).fitsFairing, feasible(i)=false; end
        if A_rad_min > 0 && (M(i).A_rad_valid < A_rad_min), feasible(i)=false; end
        if A_payload_min > 0 && (M(i).A_payload < A_payload_min), feasible(i)=false; end
    end

    idx = find(feasible);
    if isempty(idx)
        error("No feasible candidates.");
    end

    nV    = norm01([M(idx).V_usable]);
    nArad = norm01([M(idx).A_rad_valid]);
    nAp   = norm01([M(idx).A_payload]);
    nf1   = norm01([M(idx).f1_proxy]);
    nSc   = norm01([M(idx).scaleScore]);
    nEgg  = norm01([M(idx).eggScore]);

    scores = zeros(numel(cands),1);
    for k=1:numel(idx)
        i = idx(k);
        scores(i) = w.V*nV(k) + w.Arad*nArad(k) + w.Ap*nAp(k) + ...
                    w.f1*nf1(k) + w.scale*nSc(k) + w.egg*nEgg(k);
    end

    results = table( ...
        string({cands.type})', scores, feasible, ...
        [M.V_usable]', [M.A_rad_valid]', [M.A_payload]', [M.f1_proxy]', ...
        [M.scaleScore]', [M.s_max]', [M.eggScore]', [M.eggMargin]', ...
        'VariableNames', {'Shape','Score','Feasible','Vusable_m3','AradValid_m2','Apayload_m2', ...
                          'f1proxy','ScaleScore','s_max','EGGscore','EGGmargin'} );

    results = sortrows(results, "Score", "descend");

    topN = min(3, height(results));
    top3 = results(1:topN, :);

    disp(results);

    for i = 1:topN
        fprintf("%d) %s | Score = %.3f\n", i, top3.Shape(i), top3.Score(i));
    end

    results_disp = results;
    results_disp.Score        = round(results_disp.Score, 3);
    results_disp.Vusable_m3   = round(results_disp.Vusable_m3, 2);
    results_disp.AradValid_m2 = round(results_disp.AradValid_m2, 2);
    results_disp.Apayload_m2  = round(results_disp.Apayload_m2, 2);
    results_disp.f1proxy      = round(results_disp.f1proxy, 3);
    results_disp.ScaleScore   = round(results_disp.ScaleScore, 2);
    results_disp.EGGscore     = round(results_disp.EGGscore, 2);
    results_disp.EGGmargin    = round(results_disp.EGGmargin, 2);

    disp(results_disp);

    for i = 1:height(results_disp)
        fprintf('%d) %-15s | Score = %.3f\n', ...
            i, results_disp.Shape(i), results_disp.Score(i));
    end

end

function c = makeCand(type, dims)
    c = struct("type", type, "dims", dims);
end

function m = evalCandEasy(c, fairing, keepout, eggEnv, coreFill)

    [Vgeom, Aext, Apayload, Arad, Deq, Htot, I, Lchar, coreDims] = geom(c);

    Dmax = fairing.Dint - 2*keepout;
    Hmax = fairing.Huse - 2*keepout;
    fitsFairing = (Deq <= Dmax) && (Htot <= Hmax);

    Vusable = 0.65 * Vgeom;
    f1_proxy = sqrt( I / (Vgeom * Lchar^3) );

    s_max = min(Dmax/max(Deq,1e-9), Hmax/max(Htot,1e-9));
    s_max = max(0, s_max);
    scaleScore = s_max;

    coreInternal = coreFill * coreDims;
    ratios = coreInternal ./ eggEnv;
    minRatio = min(ratios);
    eggMargin = minRatio - 1;
    eggScore = clamp01( 0.6 + 2.0*eggMargin );
    eggScore = clamp01( 0.9*eggScore + 0.1*symmetryBonus(c) );

    m = struct( ...
        "fitsFairing", fitsFairing, ...
        "V_usable", Vusable, ...
        "A_payload", Apayload, ...
        "A_rad_valid", Arad, ...
        "A_ext", Aext, ...
        "f1_proxy", f1_proxy, ...
        "s_max", s_max, ...
        "scaleScore", scaleScore, ...
        "eggScore", eggScore, ...
        "eggMargin", eggMargin);

end

function [V, Aext, Ap, Arad, Deq, Htot, I, Lchar, coreDims] = geom(c)

    switch string(c.type)

        case "box"
            L=c.dims.L; W=c.dims.W; H=c.dims.H;
            Deq = max([L,W]); Htot = H;
            V = L*W*H;
            Aext = 2*(L*W + L*H + W*H);
            Ap = L*W;
            Arad = (L*W) + 0.6*(W*H);
            I = min((L*H^3)/12, (W*H^3)/12);
            Lchar = H;
            coreDims = 0.60 * [L W H];

        case "rectangle-box"
            L=c.dims.L; W=c.dims.W; H=c.dims.H;
            Deq = max([L,W]); Htot = H;
            V = L*W*H;
            Aext = 2*(L*W + L*H + W*H);
            Ap = L*W;
            Arad = (L*W) + 0.6*(W*H);
            I = min((L*H^3)/12, (W*H^3)/12);
            Lchar = H;
            coreDims = 0.60 * [L W H];

        case "hex"
            R = c.dims.R; H = c.dims.H;
            s = R;
            Ahex = (3*sqrt(3)/2) * s^2;
            Phex = 6*s;
            Deq = 2*R;
            Htot = H;
            V = Ahex * H;
            Aext = 2*Ahex + Phex*H;
            Ap = Ahex;
            Arad = 2*(s*H);
            Arad = Arad + 0.2*(Phex*H);
            Req = sqrt(Ahex/pi);
            I = (pi/4)*Req^4;
            Lchar = H;
            coreDims = 0.60 * [2*Req 2*Req H];

        case "cyl"
            R=c.dims.R; H=c.dims.H;
            Deq = 2*R; Htot = H;
            V = pi*R^2*H;
            Aext = 2*pi*R*H + 2*pi*R^2;
            Ap = pi*R^2;
            curvedPenalty = 0.70;
            Arad = curvedPenalty * 0.5*(2*pi*R*H);
            I = (pi/4)*R^4;
            Lchar = H;
            coreDims = 0.60 * [2*R 2*R H];

        case "frustum"
            R1=c.dims.R1; R2=c.dims.R2; H=c.dims.H;
            Deq = 2*max(R1,R2); Htot = H;
            V = (pi*H/3)*(R1^2 + R1*R2 + R2^2);
            slant = sqrt((R1-R2)^2 + H^2);
            Aext = pi*(R1+R2)*slant + pi*(R1^2 + R2^2);
            Ap = pi*R2^2;
            Arad = 0.4*pi*(R1+R2)*slant;
            Rm = (R1+R2)/2;
            I = (pi/4)*Rm^4;
            Lchar = H;
            coreDims = 0.55 * [2*min(R1,R2) 2*min(R1,R2) H];

        case "slab"
            L=c.dims.L; W=c.dims.W; H=c.dims.H;
            Deq = max([L,W]); Htot = H;
            V = L*W*H;
            Aext = 2*(L*W + L*H + W*H);
            Ap = L*W;
            Arad = 0.9*(L*W) + 0.4*(L*H);
            I = min((L*H^3)/12, (W*H^3)/12);
            Lchar = max(L,W);
            coreDims = 0.55 * [L W H];

    end
end

function s = symmetryBonus(c)
    switch string(c.type)
        case "cyl"
            s = 1.0;
        case "hex"
            s = 0.95;
        case {"box","rectangle-box"}
            L=c.dims.L; W=c.dims.W;
            r = max(L/W, W/L);
            s = clamp01(1.0 - 0.25*(r-1));
        case "slab"
            s = 0.8;
        case "frustum"
            s = 0.75;
        otherwise
            s = 0.75;
    end
end

function y = norm01(x)
    x = x(:);
    xmin = min(x); xmax = max(x);
    if abs(xmax-xmin) < 1e-12
        y = ones(size(x));
    else
        y = (x - xmin) / (xmax - xmin);
    end
end

function y = clamp01(x)
    y = min(1, max(0, x));
end