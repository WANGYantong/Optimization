clear
clc

%%Access Point and Boundary
n = 6;
alpha = linspace(0,2*pi,n+1);
r=10;
x=r*cos(alpha);
y=r*sin(alpha);
axis equal
axis([-3*r-5 3*r+5 -3*r-5 3*r+5]);
axis off
hold on
plot(x,y,'linewidth',2);
theta = linspace(pi/2,5*pi/2,n+1);
x0=sqrt(3)*r*cos(theta);
y0=sqrt(3)*r*sin(theta);
for ii=1:n
    x=x0(ii)+r*cos(alpha);
    y=y0(ii)+r*sin(alpha);
    plot(x,y,'k','linewidth',2);
end

for ii=1:n+1
    if ii<4
        text(x0(ii),y0(ii)+2,num2str(ii));
        plot(x0(ii),y0(ii),'r.','MarkerSize',10);
    else
        if ii==4
            text(0,2,num2str(ii));
            AP=plot(0,0,'r.','MarkerSize',10);
        else
            text(x0(ii-1),y0(ii-1)+2,num2str(ii));
            plot(x0(ii-1),y0(ii-1),'r.','MarkerSize',10);
        end
    end
end

%%User Equipment
% X1
MU=plot(-6,6,'bx','MarkerSize',6);

for ii=1:19
    x1=x0(2)+(x0(6)-x0(2))*rand();
    y1=y0(4)+(y0(1)-y0(4))*rand();
    plot(x1,y1,'bx','MarkerSize',6);
end

legend([AP,MU],'Access Point','Mobile User');

hold off