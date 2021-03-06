 function [Sn,R] = dordpi(u,y,i,R); 
  
% dordpi  is a preprocessor function that extracts the column-space of 
%         the extended observability matrix from input/output data. Data from 
%         different experiments can be concatenated using the extra input 
%         argument R. The estimated column-space is used in the function 
%         destac to extract the matrices A and C. This function implements the 
%         past input moesp algorithm which can be used for the output error 
%         identification problem. 
%         Model structure: 
%                x(k+1) = Ax(k) + Bu(k) 
%                y(k)   = Cx(k) + Du(k) + v(k) 
%         where v(k) is zero-mean noise of arbitary color, 
%         independent of the noise-free input u(k). 
% 
% Syntax: 
%         [Sn,R]=dordpi(u,y,i); 
%         [Sn,R]=dordpi(u,y,i,R); 
% 
% Input: 
%  u,y   The input and output data of the system to be identified. 
%  i     The dimension parameter that determines the number 
%        of block rows in the processed Hankel matrices. 
%        This parameter should be chosen larger than the expected 
%        system order. The optimal value has to be found by trial 
%        and error. Generally twice as large is a good starting value. 
% Rold   Data structure obtained from processing a previous 
%        data-batch with dordpi, containing the same items as R. 
% 
% Output: 
%  Sn    Singular values bearing information on the order of the system. 
%  R     Data structure used by destac for the estimation of A 
%        and C or by a next call to dordpi. This matrix contains the 
%        triangular factor,  estimated column-space and additional 
%        information (such as i/o dimension etc.). 
% 
% See also: dordom, dordpo, destac 
 
%  --- This file is generated from the MWEB source dmoesp.web --- 
% 
% The dordpi routine corresponds to the PI scheme 
% derived and analyzed in VERHAEGEN: 'Subspace Model 
% Identification. Part 3' Int. J. Control, Vol. 57. 
% 
% Michel Verhaegen 11-01-1990 
% copyright (c) 1990 Verhaegen Michel 
% Last modification: concatenation data sets 
% December 1994 
 
 
 
 if nargin==0 
  help dordpi 
  return 
end 
argmin = 3;lmin = 1;mmin = 1; 
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
  error('It is required to have at least one input.') 
elseif  (~(size(u,1)==Ns)&(m>0)) 
  error('The input and output must have same length.') 
end 
 
 
 
Hheight = i * (2 * m+l);Hwidth = Ns-2 * i+1; 
 if i<1, 
  error('The blockmatrix parameter must be a positive number.') 
end 
if Hheight>Hwidth; 
  error('The block matrix parameter ''i'' is too large for this data length.') 
end 
 
 
if (nargin > argmin) 
   if isstruct(R) 
  if isfield(R,'L') 
    L = R.L; 
    if ~(all(size(L)==[Hheight,Hheight])) 
      error('R.L has unexpected size.') 
    end 
  else 
      error('The field R.L does not exist.') 
  end 
else 
  error('R should be a structure, generated by dordxx.') 
end 
 
 
else 
  L = []; 
end 
 
 
 
 % Hankel matrices 
N = Ns-2 * i+1; 
Uf = zeros(N,m * i); 
Up = zeros(N,m * i); 
Yf = zeros(N,l * i); 
for k = (1:i), 
  Up(:,(k-1) * m+1:k * m) = u(k:N+k-1,:); 
  Uf(:,(k-1) * m+1:k * m) = u(i+k:N+i+k-1,:); 
  Yf(:,(k-1) * l+1:k * l) = y(i+k:N+i+k-1,:); 
end 
L = triu(qr([L';[Uf Up Yf]])); 
L = L(1:(2 * m+l) * i,1:(2 * m+l) * i)'; 
Lb = L(2 * m * i+1:(2 * m+l) * i,m * i+1:2 * m * i); 
 
 
 
 % SVD 
[Un,Sn,Vn] = svd(Lb); 
Sn = diag(Sn); 
Sn = Sn(1:i); 
R = struct('L',L,'Un',Un,'m',m,'l',l,'i',i); 
 
 
 
 

