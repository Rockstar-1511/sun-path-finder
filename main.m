%% Sun Path Finder
% Simulates solar altitude and azimuth for 365 days at 1-hour intervals,
% analyses seasonal trends with curve fitting, and estimates the best fixed
% tilt for a photovoltaic panel. Edit the site configuration and run.

clear; clc; close all;
addpath(fullfile(fileparts(mfilename('fullpath')), 'src'));

%% Site configuration
site.name      = 'New York, NY';
site.latitude  = 40.7128;    % deg, +N
site.longitude = -74.0060;   % deg, +E
site.utcOffset = -5;         % hours from UTC, standard time (no DST)

stepHours = 1;               % simulation time step (hours)
days      = (1:365)';
hours     = 0:stepHours:(24 - stepHours);
outDir    = 'results';
dataDir   = 'data';
if ~exist(outDir, 'dir'),  mkdir(outDir);  end
if ~exist(dataDir, 'dir'), mkdir(dataDir); end

%% 1) Solar position over the year (365 x 24 = 8,760 points)
[H, D] = meshgrid(hours, days);            % rows = days, columns = hours
[altitude, azimuth] = sunPosition(D, H, site.latitude, site.longitude, site.utcOffset);

%% 2) Daily metrics
[~, ~, decl] = sunPosition(days, 12*ones(size(days)), site.latitude, site.longitude, site.utcOffset);
noonAltitude = 90 - abs(site.latitude - decl);
[sunrise, sunset, solarNoon, dayLength] = sunriseSunset(days, site.latitude, site.longitude, site.utcOffset);

%% 3) Curve fitting of seasonal trends
[noonModel, noonFit, noonGof] = fitSeasonalTrend(days, noonAltitude);
[lenModel,  lenFit,  lenGof]  = fitSeasonalTrend(days, dayLength);

f = figure('Name', 'Seasonal Trends', 'Color', 'w');
subplot(2,1,1);
plot(days, noonAltitude, '.', days, noonFit, '-', 'LineWidth', 1.5); grid on;
ylabel('Noon altitude (deg)');
title(sprintf('Solar noon altitude  (R^2 = %.4f, RMSE = %.3f deg)', noonGof.rsquare, noonGof.rmse));
legend('Simulated', 'Fourier fit', 'Location', 'best');
subplot(2,1,2);
plot(days, dayLength, '.', days, lenFit, '-', 'LineWidth', 1.5); grid on;
xlabel('Day of year'); ylabel('Day length (h)');
title(sprintf('Day length  (R^2 = %.4f, RMSE = %.3f h)', lenGof.rsquare, lenGof.rmse));
legend('Simulated', 'Fourier fit', 'Location', 'best');
saveas(f, fullfile(outDir, 'seasonal_trends.png'));

%% 4) Sunrise, sunset and solar noon
f = figure('Name', 'Sunrise and Sunset', 'Color', 'w');
plot(days, sunrise, days, solarNoon, '--', days, sunset, 'LineWidth', 1.8); grid on;
xlabel('Day of year'); ylabel('Local standard time (h)'); ylim([0 24]);
legend('Sunrise', 'Solar noon', 'Sunset', 'Location', 'best');
title(sprintf('Sunrise, solar noon and sunset - %s', site.name));
saveas(f, fullfile(outDir, 'sunrise_sunset.png'));

%% 5) Sun path plots (diagram, polar chart, heatmap)
plotSunPath(site, days, hours, altitude, azimuth, outDir);

%% 6) PV placement: optimal fixed tilt
[bestTilt, tilts, energy] = optimalTilt(altitude, azimuth, site.latitude, stepHours);

f = figure('Name', 'Tilt Optimisation', 'Color', 'w');
plot(tilts, energy, 'LineWidth', 2); hold on; grid on;
plot(bestTilt, max(energy), 'ro', 'MarkerFaceColor', 'r');
xlabel('Panel tilt (deg)'); ylabel('Annual beam energy (kWh/m^2)');
title(sprintf('Optimal fixed tilt = %d deg (equator-facing)', bestTilt));
saveas(f, fullfile(outDir, 'tilt_optimisation.png'));

%% 7) Data export
T = table(D(:), H(:), altitude(:), azimuth(:), ...
          'VariableNames', {'DayOfYear', 'LocalHour', 'Altitude_deg', 'Azimuth_deg'});
writetable(T, fullfile(dataDir, 'sun_positions.csv'));

S = table(days, decl, noonAltitude, sunrise, solarNoon, sunset, dayLength, ...
          'VariableNames', {'DayOfYear', 'Declination_deg', 'NoonAltitude_deg', ...
                            'Sunrise_h', 'SolarNoon_h', 'Sunset_h', 'DayLength_h'});
writetable(S, fullfile(dataDir, 'daily_summary.csv'));

%% Summary
[maxAlt, iMax] = max(noonAltitude);
[minAlt, iMin] = min(noonAltitude);
fprintf('\n=== Sun Path Finder: %s ===\n', site.name);
fprintf('Data points        : %d (365 days x %d steps)\n', numel(altitude), numel(hours));
fprintf('Max noon altitude  : %.1f deg (day %d)\n', maxAlt, days(iMax));
fprintf('Min noon altitude  : %.1f deg (day %d)\n', minAlt, days(iMin));
fprintf('Longest day        : %.2f h\n', max(dayLength));
fprintf('Shortest day       : %.2f h\n', min(dayLength));
fprintf('Trend fit (R^2)    : noon altitude %.4f, day length %.4f\n', noonGof.rsquare, lenGof.rsquare);
fprintf('Optimal tilt       : %d deg, %.0f kWh/m^2/yr beam (clear-sky)\n', bestTilt, max(energy));
fprintf('Plots saved to ./%s, data saved to ./%s\n\n', outDir, dataDir);
