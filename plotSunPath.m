function plotSunPath(site, days, hours, altitude, azimuth, outDir)
%PLOTSUNPATH Sun path diagram, polar sky chart and altitude heatmap.

    keyDays   = [80 172 266 355];
    keyLabels = {'Mar equinox', 'Jun solstice', 'Sep equinox', 'Dec solstice'};
    fineHours = 0:1/12:24;                     % 5-minute resolution for smooth curves

    % 1) Cartesian sun path diagram with hourly analemmas
    f1 = figure('Name', 'Sun Path Diagram', 'Color', 'w');
    hold on; grid on;
    for h = 1:numel(hours)
        a = altitude(:, h); z = azimuth(:, h);
        vis = a > 0;
        plot(z(vis), a(vis), '.', 'Color', [0.75 0.75 0.75], 'MarkerSize', 4, ...
             'HandleVisibility', 'off');
    end
    for k = 1:numel(keyDays)
        [a, z] = sunPosition(keyDays(k)*ones(size(fineHours)), fineHours, ...
                             site.latitude, site.longitude, site.utcOffset);
        vis = a > 0;
        plot(z(vis), a(vis), 'LineWidth', 2, 'DisplayName', keyLabels{k});
    end
    xlabel('Azimuth (deg from north)'); ylabel('Altitude (deg)');
    title(sprintf('Sun Path - %s (%.2f, %.2f)', site.name, site.latitude, site.longitude));
    xlim([0 360]); ylim([0 90]); xticks(0:45:360);
    legend('Location', 'northoutside', 'Orientation', 'horizontal');
    saveas(f1, fullfile(outDir, 'sun_path_diagram.png'));

    % 2) Polar sky chart (zenith at centre, horizon at edge)
    f2 = figure('Name', 'Polar Sun Path', 'Color', 'w');
    pax = polaraxes; hold(pax, 'on');
    for k = 1:numel(keyDays)
        [a, z] = sunPosition(keyDays(k)*ones(size(fineHours)), fineHours, ...
                             site.latitude, site.longitude, site.utcOffset);
        vis = a > 0;
        polarplot(pax, deg2rad(z(vis)), 90 - a(vis), 'LineWidth', 2, 'DisplayName', keyLabels{k});
    end
    pax.ThetaZeroLocation = 'top';
    pax.ThetaDir = 'clockwise';
    pax.RLim = [0 90];
    pax.RTick = 0:30:90;
    pax.RTickLabel = {'90', '60', '30', '0'};
    title(pax, 'Polar Sun Path (radius = 90 - altitude)');
    legend(pax, 'Location', 'southoutside');
    saveas(f2, fullfile(outDir, 'sun_path_polar.png'));

    % 3) Altitude heatmap over the year
    f3 = figure('Name', 'Solar Altitude Heatmap', 'Color', 'w');
    imagesc(hours, days, max(altitude, 0));
    set(gca, 'YDir', 'normal');
    colormap(hot); cb = colorbar; cb.Label.String = 'Altitude (deg)';
    xlabel('Local standard time (h)'); ylabel('Day of year');
    title('Solar Altitude - 365 days x 1-hour steps');
    saveas(f3, fullfile(outDir, 'altitude_heatmap.png'));
end
