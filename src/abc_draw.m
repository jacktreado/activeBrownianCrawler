%% ABC model

clear;
close all;
clc;

% packing fraction of single particle
phi0 = 0.05;

% number of vertices
NV = 32;

% minimum calA
calAv = NV*tan(pi/NV)/pi;

% mechanical
Kb = 0;
Kl = 1.0;
Ka = 1.0;
NFRAMES = 200;

% simulation parameters
NT      = 1e6;                  % number of time steps
dt      = 0.005;                % time step magnitude in units of fundamental timescale
calA0   = 1.3;                 % preferred shape parameter
v0      = 0.05;                 % velocity scale
vmin    = 1e-2*v0;              % basal velocity
Dr      = 0.01;                  % diffusivity in time
Ds      = 0.2;                  % diffusivity in driving contour of cell
b       = 1.0;                  % damping

% frames to skip for plotting
plotskip = NT/NFRAMES;

% seed random number generator
rng('shuffle');

% initial coordinates of deformable polygon
x = zeros(NV,1);
y = zeros(NV,1);

% scale calA0 by NV
calA0 = calA0*(NV*tan(pi/NV)/pi);

% polygon length scales radii
a0 = 1.0;
r0 = sqrt((2.0*a0)/(NV*sin((2.0*pi)/NV)));
l0 = 2.0*sqrt(pi*calA0*a0)/NV;

% determine length of box
L = sqrt(a0/phi0);

% vertex positions
for vv = 1:NV
    x(vv) = r0*cos(2.0*pi*vv/NV) + 0.5*L;
    y(vv) = r0*sin(2.0*pi*vv/NV) + 0.5*L;
end

% indexing
im1 = [NV 1:NV-1];
ip1 = [2:NV 1];

% force parameters
rho0            = sqrt(a0);                 % units: length
fa              = Ka/rho0;                   % units: inv length, because of grad a
fl              = Kl*(rho0/l0);             % units: dim. less
fb              = Kb*(rho0/(l0*l0));        % units: inv length, because of length in force expression

% plot skipping
pskip = NT/NFRAMES;
ff = 1;

% time
timeVals = (0:(NT-1))*dt;

%% Loop over time

% either make a movie or no
makeAMovie = 1;
if makeAMovie == 1
    mvstr = ['abc_NV' num2str(NV) '_ca' num2str(calA0) '_kb' num2str(Kb) '_v0' num2str(v0) '_Dr' num2str(Dr) '.gif'];
%     vobj = VideoWriter(mvstr,'MPEG-4');
%     open(vobj);
    nf = 1;
end

% velocities
vx = zeros(NV,1);
vy = zeros(NV,1);

fx = zeros(NV,1);
fy = zeros(NV,1);

% director
psi = 0.0;

% random numbers
randList = randn(NT,1);

% quantities to save
frameList   = zeros(NFRAMES,1);
cList       = zeros(NFRAMES,2);
fList       = zeros(NFRAMES,2);
UList       = zeros(NFRAMES,3);
calAList    = zeros(NFRAMES,1);
tvals       = zeros(NFRAMES,1);

% drawing
figure(1), clf, hold on, box on;
Flist = [1:NV, 1];

for tt = 1:NT
    
    % do first verlet update for vertices (assume unit mass)
    x = x + dt*vx + 0.5*fx*dt*dt;
    y = y + dt*vy + 0.5*fy*dt*dt;
    
    % update old forces
    fxold = fx;
    fyold = fy;
    
    % * * * * * * * * * * * * * * * * * *
    % calculate forces based on positions
    % * * * * * * * * * * * * * * * * * *
    
    % reset forces
    fx = zeros(NV,1);
    fy = zeros(NV,1);
    
    % -- perimeter force
    
    % segment vectors
    lvx = x(ip1) - x;
    lvy = y(ip1) - y;
    
    % update perimeter segment lengths
    l = sqrt(lvx.^2 + lvy.^2);
    
    % segment unit vectos
    ulvx = lvx./l;
    ulvy = lvy./l;
    
    % segment strains
    dli = (l./l0) - 1.0;
    dlim1 = (l(im1)./l0) - 1.0;
    
    % perimeter force at this iteration
    flx = fl*(dli.*ulvx - dlim1.*ulvx(im1));
    fly = fl*(dli.*ulvy - dlim1.*ulvy(im1));
    
    % add to total force
    fx = fx + flx;
    fy = fy + fly;
    
    
    % -- area force
    
    % update area
    a = polyarea(x, y);
    
    % area strain
    areaStrain = (a/a0) - 1.0;
    
    % area force at this iteration
    fax = fa*0.5*areaStrain.*(y(im1) - y(ip1));
    fay = fa*0.5*areaStrain.*(x(ip1) - x(im1));
    
    % add to total force
    fx = fx + fax;
    fy = fy + fay;
    
    % -- bending force
    
    % s vectors
    six = lvx - lvx(im1);
    siy = lvy - lvy(im1);
    
    % bending force at this iteration
    fbx = fb*(2.0*six - six(im1) - six(ip1));
    fby = fb*(2.0*siy - siy(im1) - siy(ip1));
    
    % add to force
    fx = fx + fbx;
    fy = fy + fby;
    
    
    % -- active force from driving
    
    cx = mean(x);
    cy = mean(y);
    
    rx = x - cx;
    ry = y - cy;
    
    % get angular position of each vertex relative to director
    psiVi = atan2(ry,rx);
    dpsi = psiVi - psi;
    dpsi = dpsi - 2.0*pi*round(dpsi/(2.0*pi));
    
    % get velocity scales for each 
    v0tmp = v0*exp(-(dpsi.^2)./(2.0*Ds*Ds)) + vmin;
    
    % add to forces
    rscales = sqrt(rx.^2 + ry.^2);
    urx = rx./rscales;
    ury = ry./rscales;
    fx = fx + v0tmp.*urx;
    fy = fy + v0tmp.*ury;
    
    % print to console
    if mod(tt,pskip) == 0
        % draw
        f = figure(1);
        clf, hold on, box off;
        Vs = [x, y];
%         patch('Faces',Flist,'Vertices',Vs,'FaceColor',[0.2222 0.6111 0.4000],'EdgeColor','k');
        patch('Faces',Flist,'Vertices',Vs,'FaceColor','b','EdgeColor','k');
        axis equal;
        axis([-0.25*L 1.25*L -0.25*L 1.25*L]);
        ax = gca;
        ax.XTick = [];
        ax.YTick = [];
        ax.XColor = 'none';
        ax.YColor = 'none';
        
        if makeAMovie == 1
            f.Color = 'w';
%             currframe = getframe(f);
%             writeVideo(vobj,currframe);
            frame = getframe(f);
            im = frame2im(frame);
            [imind,cm] = rgb2ind(im,256);
            
            if nf == 1
                imwrite(imind,cm,mvstr,'gif','DelayTime',0.1,'Loopcount',inf);
            else 
                imwrite(imind,cm,mvstr,'gif','DelayTime',0.1,'WriteMode','append'); 
            end 
            nf = nf + 1;
        end
        
        % get net force, energy
        Fx = sum(fx);
        Fy = sum(fy);
        
        Ua = 0.5*areaStrain^2;
        Ul = 0.5*Kl*sum(dli.^2);
        Ub = 0.5*Kb*sum(six.^2 + siy.^2);
        
        % print to console
        fprintf('\n\n');
        fprintf('***************************\n');
        fprintf('   A C T I V E             \n');
        fprintf('     B R O W N I A N       \n');
        fprintf('       C R A W L E R       \n');
        fprintf('***************************\n\n');
        fprintf('tt         = %d / %d\n',tt,NT);
        fprintf('time       = %0.4g\n',timeVals(tt));
        fprintf('psi        = %0.4g\n\n',psi);
        fprintf('Fx         = %0.4g\n',Fx);
        fprintf('Fy         = %0.4g\n',Fy);
        fprintf('Ua         = %0.4g\n',Ua);
        fprintf('Ul         = %0.4g\n',Ul);
        fprintf('Ub         = %0.4g\n\n',Ub);
        
        % save quantities for later
        frameList(ff) = tt;
        cList(ff,1) = cx;
        cList(ff,2) = cy;
        
        fList(ff,1) = Fx;
        fList(ff,2) = Fy;
        
        UList(ff,1) = Ua;
        UList(ff,2) = Ul;
        UList(ff,3) = Ub;
        
        calAList(ff) = (sum(l)^2)/(4.0*pi*a);
        
        tvals(ff) = (ff-1)*dt;
        
        % update frame index
        ff = ff + 1;
    end
    
    % include damping
    dampingNumX = b*(vx - 0.5*fxold*dt);
    dampingNumY = b*(vy - 0.5*fyold*dt);
    dampingDenom = 1.0 - 0.5*b*dt;
    
    fx = (fx - dampingNumX)./dampingDenom;
    fy = (fy - dampingNumY)./dampingDenom;
    
    % do second verlet update for vertices
    vx = vx + dt*0.5*(fx + fxold);
    vy = vy + dt*0.5*(fy + fyold);

%     % Euler update
%     x = x + dt*fx;
%     y = y + dt*fy;
    
    % update directors
    psi = psi + sqrt(dt*2.0*Dr)*randList(tt);
end

if makeAMovie == 1
%     close(vobj);
end

%% Plot forces over sim

Fnrm = sqrt(fList(:,1).^2 + fList(:,2).^2);

figure(10), clf, hold on, box on;
plot(tvals,Fnrm,'k-','linewidth',2);
xlabel('$t$','Interpreter','latex');
ylabel('$F$','Interpreter','latex');
ax = gca;
ax.FontSize = 22;