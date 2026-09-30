function [bestTilt, tilts, annualEnergy] = optimalTilt(altitude, azimuth, latitude, stepHours)
%OPTIMALTILT Estimate the fixed panel tilt that maximizes annual clear-sky beam energy.
%
%   [bestTilt, tilts, annualEnergy] = optimalTilt(altitude, azimuth, latitude, stepHours)
%
%   The panel faces the equator (south in the northern hemisphere, north in
%   the southern hemisphere). Direct normal irradiance is estimated with the
%   Meinel clear-sky model and Kasten-Young air mass.
%
%   annualEnergy is in kWh/m^2 per year (beam component only).
%
%   Limitations: ignores diffuse and ground-reflected light, weather,
%   shading and temperature. Treat the result as a geometric first estimate,
%   not a replacement for tools like NREL PVWatts or SAM.

    tilts = 0:1:90;
    if latitude >= 0
        panelAzimuth = 180;
    else
        panelAzimuth = 0;
    end

    up   = altitude > 0;                       % only hours with the sun above the horizon
    zen  = 90 - altitude(up);                  % degrees
    zenR = deg2rad(zen);
    azR  = deg2rad(azimuth(up));

    airMass = 1 ./ (cos(zenR) + 0.50572 .* (96.07995 - zen).^(-1.6364));  % Kasten-Young (1989)
    dni     = 1353 .* 0.7 .^ (airMass .^ 0.678);                          % Meinel (1976), W/m^2

    annualEnergy = zeros(size(tilts));
    for k = 1:numel(tilts)
        b = deg2rad(tilts(k));
        cosInc = cos(zenR).*cos(b) + sin(zenR).*sin(b).*cos(azR - deg2rad(panelAzimuth));
        annualEnergy(k) = sum(dni .* max(cosInc, 0)) * stepHours / 1000;  % kWh/m^2
    end

    [~, idx] = max(annualEnergy);
    bestTilt = tilts(idx);
end
