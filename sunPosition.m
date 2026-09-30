function [altitude, azimuth, declination] = sunPosition(dayOfYear, localHour, latitude, longitude, utcOffset)
%SUNPOSITION Solar altitude and azimuth using the NOAA general solar position equations.
%
%   [altitude, azimuth, declination] = sunPosition(dayOfYear, localHour, latitude, longitude, utcOffset)
%
%   Inputs (scalars or equal-size arrays):
%     dayOfYear  - day number, 1..365
%     localHour  - local standard clock time in decimal hours (0..24)
%     latitude   - site latitude in degrees (+N, -S)
%     longitude  - site longitude in degrees (+E, -W)
%     utcOffset  - time zone offset from UTC in hours (e.g. -5 for EST, no DST)
%
%   Outputs (degrees):
%     altitude    - solar elevation above the horizon (negative = below horizon)
%     azimuth     - measured clockwise from true north (90 = east, 180 = south)
%     declination - solar declination
%
%   Reference: NOAA Global Monitoring Laboratory, "General Solar Position Calculations"
%   (Spencer 1971 Fourier series for declination and equation of time).
%   Typical accuracy is within a fraction of a degree; validate against the
%   NOAA Solar Calculator for your site before relying on results.

    % Fractional year (radians)
    g = 2*pi/365 .* (dayOfYear - 1 + (localHour - 12) ./ 24);

    % Equation of time (minutes)
    eqTime = 229.18 .* (0.000075 + 0.001868.*cos(g) - 0.032077.*sin(g) ...
                      - 0.014615.*cos(2*g) - 0.040849.*sin(2*g));

    % Solar declination (radians)
    decl = 0.006918 - 0.399912.*cos(g) + 0.070257.*sin(g) ...
         - 0.006758.*cos(2*g) + 0.000907.*sin(2*g) ...
         - 0.002697.*cos(3*g) + 0.00148.*sin(3*g);

    % True solar time (minutes) and hour angle (radians)
    timeOffset = eqTime + 4.*longitude - 60.*utcOffset;
    trueSolarTime = localHour.*60 + timeOffset;
    hourAngle = deg2rad(trueSolarTime./4 - 180);

    lat = deg2rad(latitude);

    % Solar zenith angle
    cosZen = sin(lat).*sin(decl) + cos(lat).*cos(decl).*cos(hourAngle);
    cosZen = min(max(cosZen, -1), 1);          % guard against rounding outside [-1, 1]
    altitude = 90 - rad2deg(acos(cosZen));

    % Solar azimuth, clockwise from north
    azimuth = rad2deg(atan2(sin(hourAngle), ...
                            cos(hourAngle).*sin(lat) - tan(decl).*cos(lat))) + 180;
    azimuth = mod(azimuth, 360);

    declination = rad2deg(decl);
end
