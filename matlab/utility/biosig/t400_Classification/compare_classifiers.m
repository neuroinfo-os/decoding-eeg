%These are tests to compar


%	

CLASSIFIER={'REG','REG2','MDA','MD2','QDA','QDA2','LD2','LD3','LD4','LD5','LD6','NBC','aNBC','WienerHopf','LDA/GSVD','MDA/GSVD', 'LDA/sparse','MDA/sparse','RDA','GDBC','SVM','RBF'};

N=1e2;
c=[1:N]'*2>N;

W3 = [ones(1,N/2)/5,ones(1,N/10)];
for l=1:11,CLASSIFIER{l},
for k=1:1000,

x=randn(N,2);
x=x+[c,c];

ix = 1:0.6*N;

CC = train_sc(x(ix,:),c(ix)+1,CLASSIFIER{l});
R1 = test_sc(CC,x,[],c+1);

CC = train_sc(x,c+1,CLASSIFIER{l});
R2 = test_sc(CC,x,[],c+1);

CC = train_sc(x(ix,:),c(ix)+1,CLASSIFIER{l},W3);
R3 = test_sc(CC,x,[],c+1);

acc1(k,l)=[R1.ACC];
kap1(k,l)=[R1.kappa];
acc2(k,l)=[R2.ACC];
kap2(k,l)=[R2.kappa];
acc3(k,l)=[R3.ACC];
kap3(k,l)=[R3.kappa];

end;
end; 
 
[se,m]=sem(acc1);m
[se,m]=sem(acc2);m
[se,m]=sem(acc3);m

%[diff(m),diff(m)/sqrt(sum(se.^2))]
%[se,m]=sem(kap);[diff(m),diff(m)/sqrt(sum(se.^2))]

%These are tests to compare varios classiers

return 


N=1e2;
c=[1:N]'*2>N;

for k=1:1000,k

x=randn(N,2);
x=x+[c,c];

ix = 1:0.6*N;
[R1,CC]=xval(x(ix,:),c(ix)+1,'REG');
[R2,CC]=xval(x,c+1,'REG');
[R3,CC]=xval(x(ix,:),c(ix)+1,'LDA');
[R4,CC]=xval(x,c+1,'LDA');

acc(k,1:4)=[R1.ACC,R2.ACC,R3.ACC,R4.ACC];
kap(k,1:4)=[R1.kappa,R2.kappa,R3.kappa,R4.kappa];

end;
 
[se,m]=sem(acc),%[diff(m),diff(m)/sqrt(sum(se.^2))]
%[se,m]=sem(kap);[diff(m),diff(m)/sqrt(sum(se.^2))]

