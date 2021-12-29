  gauss = @(x,mu,sig,amp,vo)amp*exp(-(((x-mu).^2)/(2*sig.^2)))+vo;

x = floor(-256/2):1:floor(256/2)-1;
y1 = gauss(x,0,100,9,0);
y2 = gauss(x,0,150,9,0);

% We take the Gaussian difference (and transpose for
% correctness)
y3 = y2-y1;
y3 = transpose(y3);

plot(x,y3)