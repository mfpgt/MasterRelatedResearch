p = 1/7;N = 10;A = (1-p)*eye(N) + (-p)*(ones(N,N)-eye(N));[di,offdi] = compmat1(1-p,-p,N)Ai = inv(A)m = 4;k = 10;p= 1/(m+1);A0 = (1-p)*eye(m) + (-p)*(ones(m,m)-eye(m));B = kron(A0,eye(k));B0 = B;Bi = inv(B);[di,offdi] = compmat2(1-p,-p,0,k,m)alpha =(1-p)/50;A1 = (1-p)*eye(m) + (-p)*(ones(m,m)-eye(m));B1 = kron(A1,eye(k));B1 = B1 + alpha*(1 - (abs(B1)>0));B10 = B1;B1i = inv(B1);[di,offdi] = compmat2(1-p,-p,alpha,k,m)% it works!!!alpha = (1-p)./(2:50);[di,offdi] = compmat2(1-p,-p,alpha,k,m);plot(alpha,di)% check on some stuffalpha1 = alpha(1);A1 = (1-p)*eye(m) + (-p)*(ones(m,m)-eye(m));B1 = kron(A1,eye(k));B1a = B1 + alpha1*(1 - (abs(B1)>0));B1ia = inv(B1a);