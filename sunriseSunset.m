function [sunrise, sunset, solarNoon, dayLength] = sunriseSunset(dayOfYear, latitude, longitude, utcOffset)
%SUNRISESUNSET Local sunrise, sunset and solar noon times (decimal hours).
%
%   [sunrise, sunset, solarNoon, dayLength] = sunriseSunset(dayOfYear, latitude, longitude, utcOffset)
%
%   Uses the NOAA sunrise equation with a zenith of 90.833 deg, which
%   accounts for atmospheric refraction and the size of the solar disc.
%   Times are in local standard time (no daylight saving).
%   Returns NaN for sunrise/sunset on days with polar day or polar night.

    dayOfYear = dayOfYear(:);
    g = 2*pi/365 .* (dayOfYear - 1);                       % fractional year at 00:00

    eqTime = 229.18 .* (0.000075 + 0.001868.*cos(g) - 0.032077.*sin(g) ...
                      - 0.014615.*cos(2*g) - 0.040849.*sin(2*g));
    decl = 0.006918 - 0.399912.*cos(g) + 0.070257.*sin(g) ...
         - 0.006758.*cos(2*g) + 0.000907.*sin(2*g) ...
         - 0.002697.*cos(3*g) + 0.00148.*sin(3*g);

    lat = deg2rad(latitude);
    cosH = cosd(90.833) ./ (cos(lat).*cos(decl)) - tan(lat).*tan(decl);

    H = acosd(min(max(cosH, -1), 1));                      % sunrise hour angle (deg)
    H(cosH > 1 | cosH < -1) = NaN;                         % polar night / polar day

    solarNoon = (720 - 4*longitude - eqTime + 60*utcOffset) / 60;
    sunrise   = solarNoon - 4*H/60;
    sunset    = solarNoon + 4*H/60;
    dayLength = sunset - sunrise;
end
