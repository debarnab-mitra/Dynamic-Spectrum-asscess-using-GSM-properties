%Calculation of average number of active users in network
rho = [2,4,6];
y_arr = zeros(3,21);
SU = 20;
for j = 1:3
    x_arr = zeros(21,1);
    for W = 0:20
        MS = 20;
        Np = 0;
        alpha = (exp(rho(j))*igamma(W+1,rho(j))/gamma(W+1))-1;
        for i = 1:W
            Pa = exp(-(4*W)/25)*((0.16*W)^i)/factorial(i);
            sum = 0;
            for k = i:W
                sum = sum + (rho(j)^k)/(alpha*factorial(k));
            end
            Np = Np + (i*sum)*Pa; 
        end
        qi = Np/MS;
        T = 8*(1-qi);
        x_arr(W+1) = W;
        y_arr(j,W+1) = T;
    end
end
plot(x_arr,y_arr(1,:),'-o',x_arr,y_arr(2,:),'-o',x_arr,y_arr(3,:),'-o');