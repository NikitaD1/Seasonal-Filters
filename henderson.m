[A B C]=xlsread('finaldata2.xlsx');
ya = A(:,1);
y=diff(ya,1);
T = length(y);
figure
plot(y)
figure
plot(y)
h1 = gca;
h1.XLim = [0,T];
h1.XTick = 1:12:T;
h1.XTickLabel = datestr(dates(1:12:T),10);
title 'GDP Deflator series';
hold on
sW7 = [1/12;repmat(1/6,5,1);1/12];
yS = conv(y,sW7,'same');
yS(1:3) = yS(4); yS(T-2:T) = yS(T-3);

xt = y./yS;

h = plot(yS,'r','LineWidth',2);
legend(h,'5-Term Moving Average')
hold off
s = 4;
sidx = cell(s,1); % Preallocation

for i = 1:s
 sidx{i,1} = i:s:T;
end
sW3 = [1/9;2/9;1/3;2/9;1/9];
% Asymmetric weights for end of series
aW3 = [.259 .407;.37 .407;.259 .185;.111 0];

% Apply filter to each month
shat = NaN*y;
for i = 1:s
    ns = length(sidx{i});
    first = 1:4;
    last = ns - 3:ns;
    dat = xt(sidx{i});

    sd = conv(dat,sW3,'same');
    sd(1:2) = conv2(dat(first),1,rot90(aW3,2),'valid');
    sd(ns  -1:ns) = conv2(dat(last),1,aW3,'valid');
    shat(sidx{i}) = sd;
end

% 13-term moving average of filtered series
%sW13 = [1/24;repmat(1/12,11,1);1/24];
sb = conv(shat,sW7,'same');
sb(1:3) = sb(s+1:s+3);
sb(T-2:T) = sb(T-s-2:T-s);

% Center to get final estimate
s33 = shat./sb;

figure
plot(s33)
h2 = gca;
h2.XLim = [0,T];
h2.XTick = 1:12:T;
h2.XTickLabel = datestr(dates(1:12:T),10);
title 'Estimated Seasonal Component';
dt = y./s33;
%sWH = [-0.059, 0.059, 0.294, 0.412, 0.294, 0.059, -0.059];
% Asymmetric weights for end of series
sWH=[-0.073, 0.294, 0.558, 0.294, -0.073];
% Apply 13-term Henderson filter

h13 = conv(dt,sWH,'same');

% New detrended series
xt = y./h13;

figure
plot(y)
h3 = gca;
h3.XLim = [0,T];
h3.XTick = 1:12:T;
h3.XTickLabel = datestr(dates(1:12:T),10);
title ' After henderson filter ' ;
hold on
plot(h13,'r','LineWidth',2);
legend('5-Term Henderson Filter')
hold off