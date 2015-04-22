 function [Sn,Rnew] = cordpi(u,y,t,a,i,Rold); 
  
% cordpi  Delivers information about the order of the LTI continuous time 
%         state space model and acts as a pre-processor for cestac. The 
%         latter actually estimates the system matrices A and C. 
%         Model structure: 
%                  . 
%                  x(t) = Ax(t) + Bu(t) 
%                  y(t) = Cx(t) + Du(t) + v(t) 
%         where v(t) is a a finite variance disturbance on the output 
%         and is independent of the noise-free input u(t). 
%         This function uses the past input instrumental variable and is 
%         comparable to dordpi for the discrete time case. 
% 
% Syntax 
%         [Sn,Rnew]=cordpi(u,y,t,a,i); 
%         [Sn,Rnew]=cordpi(u,y,t,a,i,Rold); 
% 
% Input: 
%   u,y   The input and output data of the system to be identified. 
%   t     Sampling time or time-vector for the sampled data u and y. 
%   a     Filter coeficient of the laguerre filters used in the algorithm. 
%         When a is negative, the anti-causal instrumental variable 
%         method is used. Otherwise the causal instrumental variable 
%         method is chosen. 
%   i     The dimension parameter that determines the number 
%         of block rows in the processed Hankel matrices. 
%         This parameter should be chosen larger than the expected 
%         system order. The optimal value has to be found by trial 
%         and error. Generally twice as large is a good starting value. 
%   Rold  Data structure obtained from processing a previous  databatch 
%         with cordpi, containing the triangular factor, estimated 
%         column-space and additional information (i/o dimension etc.). 
% 
% Output: 
%   Sn    Singular values bearing information on the order of the system. 
%   Rnew  Data structure used by cestac for the estimation of A 
%         and C or by a next call to cordom. This matrix contains the 
%         same items as Rold. 
% 
% See also: cordom, cordpo, cestac, cestbd 
 
%  --- This file is generated from the MWEB source cmoesp.web --- 
% 
% Bert Haverkamp, 16-10-1997 
% Copyright(c) 1997 Bert Haverkamp 
 
 
 
 if nargin==0 
  help cordpi 
  return 
end 
argmin = 5;lmin = 1;mmin = 1; 
 if nargin<argmin 
  error('There are not enough arguments.') 
end 
 
 
 if size(y,2)>size(y,1) 
  y = y'; 
end 
if size(u,2)>size(u,1) 
  u = u'; 
end 
Ns = size(y,1); 
l = size(y,2); 
m = size(u,2); 
if (l<lmin), 
  error('It is required to have at least one output.') 
end 
if (m<mmin), 
  error('It is required to have at least one output.') 
elseif  (~(size(u,1)==Ns)) 
  error('The input and output must have same length.') 
end 
 
 
 
 if length(t)==1 
  Ts = t; 
  t = (0:Ns-1)' * Ts; 
else 
  Ts = t(2)-t(1); 
end 
 
 
 
Hheight = 2 * i+i * (2 * m+l);Hwidth = Ns; 
 if i<1, 
  error('The blockmatrix parameter must be a positive number.') 
end 
 
if Hheight>Hwidth; 
  error('The block matrix parameter ''i'' is too large for this data length.') 
end 
 
 
if (nargin > argmin) 
   if isstruct(Rold) 
  if isfield(Rold,'L') 
    L = Rold.L; 
    if ~(all(size(L)==[Hheight,Hheight])) 
      Hheight 
      error('R.L has unexpected size.') 
    end 
  else 
    error('The field Rold.L does not exist.') 
  end 
else 
  error('Rold should be a structure, generated by cordxx.') 
end 
 
 
 
 
else 
  L = []; 
end 
 
 
 
 nf = i; 
   Af = -2 * a * tril(ones(nf,nf))+a * eye(nf); 
  Bf = ones(nf,1) * 2 * a; 
  Cf = eye(nf); 
  Df = zeros(nf,1); 
 
 
 
   A = kron(Af,eye(l)); 
  B = kron(Bf,eye(l)); 
  C = kron(Cf,eye(l)); 
  D = kron(Df,eye(l)); 
      I  =  eye(length(A)); 
   [Lt,Ut,Pt]  =  lu(I - A * Ts/2); 
   Ad  =  (((I + A * Ts/2)/Ut)/Lt) * Pt;  % (I + a*T/2)/(I - a*T/2) 
   Bd  =  Ut \(Lt \(Pt * B));             % (I - a*T/2)\b 
   Cd  =  Ts * ((C/Ut)/Lt) * Pt;           % T*c/(I - a*T/2) 
   Dd  =  Cd * B/2 + D;              % (T/2)*c/(I - a*T/2)*b 
 
 
  if a>0 
    x  =  ltitr(Ad,Bd,y,zeros(nf * l,1)); 
    Yf  =  x  *  Cd' +y * Dd'; 
  else 
    Aac = inv(Ad); 
    Bac = -Aac * Bd; 
    Cac = Cd * Aac; 
    Dac = Dd+Cd * Bac; 
    x = ltitr(Aac,Bac,flipud(y),zeros(nf * l,1)); 
    Yf  =  flipud(x  *  Cac'+ flipud(y) * Dac') ; 
end 
 
 
 
nf = 2 * i; 
   Af = -2 * a * tril(ones(nf,nf))+a * eye(nf); 
  Bf = ones(nf,1) * 2 * a; 
  Cf = eye(nf); 
  Df = zeros(nf,1); 
 
 
 
   A = kron(Af,eye(m)); 
  B = kron(Bf,eye(m)); 
  C = kron(Cf,eye(m)); 
  D = kron(Df,eye(m)); 
      I  =  eye(length(A)); 
   [Lt,Ut,Pt]  =  lu(I - A * Ts/2); 
   Ad  =  (((I + A * Ts/2)/Ut)/Lt) * Pt;  % (I + a*T/2)/(I - a*T/2) 
   Bd  =  Ut \(Lt \(Pt * B));             % (I - a*T/2)\b 
   Cd  =  Ts * ((C/Ut)/Lt) * Pt;           % T*c/(I - a*T/2) 
   Dd  =  Cd * B/2 + D;              % (T/2)*c/(I - a*T/2)*b 
 
 
  if a>0 
    x  =  ltitr(Ad,Bd,u,zeros(size(Ad,1),1)); 
    Uf  =  x  *  Cd' +u * Dd'; 
  else 
    Aac = inv(Ad); 
    Bac = -Aac * Bd; 
    Cac = Cd * Aac; 
    Dac = Dd+Cd * Bac; 
    x = ltitr(Aac,Bac,flipud(u),zeros(nf * m,1)); 
    Uf  =  flipud(x  *  Cac'+ flipud(u) * Dac') ; 
  end 
 
 
 
Up = Uf(:,1:i * m); 
Uf = Uf(:,i * m+1:2 * i * m); 
   A = Af;B = Bf;C = Cf;D = Df; 
      I  =  eye(length(A)); 
   [Lt,Ut,Pt]  =  lu(I - A * Ts/2); 
   Ad  =  (((I + A * Ts/2)/Ut)/Lt) * Pt;  % (I + a*T/2)/(I - a*T/2) 
   Bd  =  Ut \(Lt \(Pt * B));             % (I - a*T/2)\b 
   Cd  =  Ts * ((C/Ut)/Lt) * Pt;           % T*c/(I - a*T/2) 
   Dd  =  Cd * B/2 + D;              % (T/2)*c/(I - a*T/2)*b 
 
 
  if a>0 
    x  =  ltitr(Ad,Bd,zeros(size(y,1),1),ones(nf,1)); 
    X0  =  x  *  Cd'; 
  else 
    Aac = inv(Ad); 
    Bac = -Aac * Bd; 
    Cac = Cd * Aac; 
    Dac = Dd+Cd * Bac; 
    x = ltitr(Aac,Bac,zeros(size(y,1),1),ones(nf,1)); 
    X0  =  flipud(x  *  Cac'); 
  end 
 
 
 
L = triu(qr([L';[X0,Uf,Up,Yf]]))'; 
L = L(1:nf+(2 * m+l) * i,1:nf+(2 * m+l) * i); 
Lb = L(nf+(2 * m) * i+1:nf+(2 * m+l) * i,nf+m * i+1:nf+(2 * m) * i); 
 
 
 %% SVD 
[Un,Sn,Vn] = svd(Lb); 
Sn = diag(Sn); 
Sn = Sn(1:i); 
 
Rnew = struct('L',L,'Un',Un,'m',m,'l',l,'i',i,'a',a); 
 
 
 

