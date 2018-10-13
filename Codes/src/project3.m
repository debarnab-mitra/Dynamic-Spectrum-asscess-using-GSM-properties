u = zeros(1,16);
for w = 1:50
    y = [];
    for z = 5:20
        r_gsm = 500;
        r_su = 200;
        K = z;
        SU = 20;
        nc = 20; %No of Channels
        ts = 8; %No of time slots
        PU_positions = [r_gsm*rand(1,K); 2*pi*rand(1,K)];
        PU_positions = PU_positions.';
        SU_positions = [r_gsm*rand(1,SU); 2*pi*rand(1,SU)];
        SU_positions = SU_positions.';
        uplink_mat = zeros(nc/2,ts,3);
        downlink_mat = zeros(nc/2,ts,3);
        pkt_loss_SU_time = zeros(SU,1);
        pkt_success_SU_time = zeros(SU,1);
        pkt_success_SU = zeros(SU,1);
        lambda = 1000;
        mu = 125;
        st = 0; %Simulation time
        sl = 577e-6; %Time slot length
        %Find PU in SU range for each SU
        SU_PU_mat = zeros(SU,K); %each row corresponds to 1 SU
        SU_BS_mat = zeros(SU,1);
        for i = 1:SU
            for j = 1:K
                distance = PU_positions(j,1)^2 + SU_positions(i,1)^2 - (2*PU_positions(j,1)*SU_positions(i,1)*cos(PU_positions(j,2)-SU_positions(i,2)));
                if distance < r_su
                    SU_PU_mat(i,j) = 1;
                end
            end
            if SU_positions(i,1) < r_su
                SU_BS_mat(i) = 1;
            end
        end
        PU_up_depart = zeros(K,1);
        PU_down_depart = zeros(K,1);
        SU_up_depart = zeros(SU,1);
        SU_down_depart = zeros(SU,1);

        for st = 1:100
            %Generate random channel and timeslot allocation
            PU_up_c_ts = [randi([1,nc/2],1,K);randi([1,ts],1,K)];
            PU_up_c_ts = PU_up_c_ts.';
            PU_down_c_ts = [randi([1,nc/2],1,K);randi([1,ts],1,K)];
            PU_down_c_ts = PU_down_c_ts.';

            PU_up_arrive = PU_up_depart + exprnd(1/lambda,K,1);
            PU_down_arrive = PU_down_depart + exprnd(1/lambda,K,1);
            PU_up_depart = PU_up_arrive + ts*exprnd(1/mu,K,1);
            PU_down_depart = PU_down_arrive + ts*exprnd(1/mu,K,1);

            %Assign generated time limits to channel-timeslot resource
            for k = 1:K
                uplink_mat(PU_up_c_ts(k,1),PU_up_c_ts(k,2),:) = [PU_up_arrive(k),PU_up_depart(k),1];
                downlink_mat(PU_down_c_ts(k,1),PU_down_c_ts(k,2),:) = [PU_down_arrive(k),PU_down_depart(k),1];
            end

            SU_up_arrive = SU_up_depart + exprnd(1/lambda,SU,1);
            SU_down_arrive = SU_down_depart + exprnd(1/lambda,SU,1);
            SU_up_depart = SU_up_arrive + ts*exprnd(1/mu,SU,1);
            SU_down_depart = SU_down_arrive + ts*exprnd(1/mu,SU,1);

            %For each SU
            for i = 1:SU
                %Uplink transmit
                while 1==1
                    c_ts = [randi([1,nc]),randi([1,ts])];
                    if c_ts(1) <= nc/2
                        %If in BS's range
                        if SU_BS_mat(i) == 1
                            %Check corr. value in uplink_mat
                            arv_time = uplink_mat(c_ts(1),c_ts(2),1);
                            dept_time = uplink_mat(c_ts(1),c_ts(2),2);
                            if (arv_time < SU_up_arrive(i)) && (dept_time > SU_up_arrive(i)) && (arv_time ~= 0)
                                continue;
                            else
                                break;
                            end
                        else 
                            break;
                        end
                    else
                        %If in PU's range
                        PU_no = find(PU_down_c_ts(:,1) == c_ts(1)-nc/2 & PU_down_c_ts(:,2) == c_ts(2),1);
                        if (length(PU_no(:)) == 1)
                            if SU_PU_mat(i,PU_no) == 1
                                %Check corr. value in uplink_mat
                                arv_time = downlink_mat(c_ts(1)-nc/2,c_ts(2),1);
                                dept_time = downlink_mat(c_ts(1)-nc/2,c_ts(2),2);
                                if (arv_time < SU_down_arrive(i)) && (dept_time > SU_down_arrive(i)) && (arv_time ~= 0)
                                    continue;
                                else
                                    break;
                                end
                            else
                                break;
                            end
                        else
                            break;
                        end
                    end
                end
                if c_ts(1) <= nc/2
                    %Uplink transmit
                    if SU_BS_mat(i) == 1 && SU_up_depart(i) > arv_time && arv_time ~= 0
                        pkt_loss_SU_time(i) = pkt_loss_SU_time(i) + (arv_time-SU_up_arrive(i));
                        SU_up_depart(i) = arv_time;
                    else
                        pkt_success_SU_time(i) = pkt_success_SU_time(i) + (SU_up_depart(i)-SU_up_arrive(i));
                        pkt_success_SU(i) = pkt_success_SU(i) + 1;
                    end
                else
                    %Downlink transmit
                    if (length(PU_no(:)) == 1) && SU_PU_mat(i,PU_no) == 1 && SU_down_depart(i) > arv_time && arv_time ~= 0
                        pkt_loss_SU_time(i) = pkt_loss_SU_time(i) + (arv_time-SU_down_arrive(i));
                        SU_down_depart(i) = arv_time;   
                    else
                        pkt_success_SU_time(i) = pkt_success_SU_time(i) + (SU_down_depart(i)-SU_down_arrive(i));
                        pkt_success_SU(i) = pkt_success_SU(i) + 1;
                    end
                end
            end
        end
        throughput = zeros(SU,1);
        pkt_size = 8000;
        for i = 1:SU
            throughput(i) = pkt_success_SU(i)*pkt_size/(pkt_loss_SU_time(i) + pkt_success_SU_time(i));
        end
        avg_throughput = mean(throughput);
        y = [y,avg_throughput]; %#ok<*AGROW>
    end
    u = u + y;
end
plot(5:20,u/50,'-o');