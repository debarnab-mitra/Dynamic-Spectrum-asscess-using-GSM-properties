%Calculation of average number of active users in network
rho = 10*[0.4,0.8,1.2];
y_arr = zeros(3,21);
SU = 20;
for j = 1:3
    x_arr = zeros(21,1);
    for W = 0:20
        MS = 160;
        Np = 0;
        alpha = (exp(rho(j))*igamma(W+1,rho(j))/gamma(W+1))-1;
        for i = 1:W
            Np = Np + (i*(rho(j)^i))/(alpha*factorial(i)); 
        end
        qi = Np/MS;
        T = 8*(1-qi);
        x_arr(W+1) = W;
        y_arr(j,W+1) = T;
    end
end
plot(x_arr,y_arr(1,:),'-o',x_arr,y_arr(2,:),'-s',x_arr,y_arr(3,:),'-*');