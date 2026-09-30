function [model, yFit, gof] = fitSeasonalTrend(x, y)
%FITSEASONALTREND Fit a 2-term Fourier series to a yearly solar trend.
%
%   [model, yFit, gof] = fitSeasonalTrend(x, y)
%
%   Uses the Curve Fitting Toolbox ('fourier2') when available. Otherwise it
%   falls back to an equivalent linear least-squares fit with a fixed
%   yearly frequency, so the project still runs on base MATLAB.
%
%   gof contains rsquare and rmse in both cases.

    x = x(:);
    y = y(:);

    if exist('fit', 'file') == 2 && license('test', 'Curve_Fitting_Toolbox')
        [model, gof] = fit(x, y, 'fourier2');
        yFit = model(x);
    else
        w = 2*pi/365;
        A = [ones(size(x)) cos(w*x) sin(w*x) cos(2*w*x) sin(2*w*x)];
        c = A \ y;
        yFit = A * c;

        model = struct('type', 'fourier2 (least-squares fallback, w = 2*pi/365)', ...
                       'a0', c(1), 'a1', c(2), 'b1', c(3), 'a2', c(4), 'b2', c(5), 'w', w);

        ssRes = sum((y - yFit).^2);
        ssTot = sum((y - mean(y)).^2);
        gof = struct('rsquare', 1 - ssRes/ssTot, 'rmse', sqrt(mean((y - yFit).^2)));
    end
end
