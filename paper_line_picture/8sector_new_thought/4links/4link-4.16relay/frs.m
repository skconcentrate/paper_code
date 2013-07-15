clear all;
clc;
% ѭ������
simulateno=100;
channel_times=100;
%sumsta������ڵ㣬����2*linkno����ΪS��D������sumr����ΪR
ui_pt=10;   %���͹���
ui_human_radius=0.5;
ui_linkno=4;%��·��Ŀ
ui_sumsta=24;%STA��Ŀ
ui_sumr=ui_sumsta-2*ui_linkno;%����ΪR����Ŀ
ui_bandwith=2000000000;%����2GHz
NL=-174 + 10*log10(ui_bandwith);%�������ʣ���λdBm
ui_sumsector=8;%��������Ϊ8
ui_theta_l=360/ui_sumsector;%�����Ƕ�ֵ
vec_frs_bestrid=zeros(ui_linkno,simulateno);
vec_ars_bestrid4all_af=zeros(ui_linkno,simulateno);
vec_ars_bestrid4all_df=zeros(ui_linkno,simulateno);
vec_FRS_AF_RESULT=zeros(ui_linkno,simulateno);
vec_FRS_DF_RESULT=zeros(ui_linkno,simulateno);
vec_ARS_AF_RESULT=zeros(ui_linkno,simulateno);
vec_ARS_DF_RESULT=zeros(ui_linkno,simulateno);

for caltimes=1:simulateno
%source����
vec_source=1:ui_linkno;

%destination����
vec_destination=(ui_linkno+1):(2*ui_linkno);

%STA�������
locate_node=zeros(2,ui_sumsta);
locate_node(1,:)=rand(1,ui_sumsta)*10;
locate_node(2,:)=rand(1,ui_sumsta)*10;

%�������
vec_stadistance=zeros(ui_sumsta);
for i_temp=1:ui_sumsta
    for j_temp=1:ui_sumsta
        if (i_temp==j_temp)
            vec_stadistance(i_temp,j_temp)=0;
        else
            vec_stadistance(i_temp,j_temp)=caldistance(locate_node,i_temp,j_temp);
        end
    end
end
clear i_temp;
clear j_temp;

%�ж�����S-D�����Ҫ>1���Ա�human_block�����赲S-D����Ϊhuman_block��ֱ����1m
ui_biggerthan1=0;
for i_temp=1:ui_linkno
   if (vec_stadistance(i_temp,i_temp+ui_linkno) < 1)
       ui_biggerthan1=ui_biggerthan1+1;
   end
end
if (ui_biggerthan1 > 0)
    continue;
end

%Block��S��D�ľ������:1��linkno��2��d2s��3:d2d
vec_block_location=zeros(3,ui_linkno);
vec_block_location(1,:)=1:ui_linkno;
for i_temp=1:ui_linkno
    ui_block_d2s=unifrnd(0,1)*(vec_stadistance(i_temp,ui_linkno+i_temp)-2*ui_human_radius)+ui_human_radius;
    ui_block_d2d=vec_stadistance(i_temp,ui_linkno+i_temp)-ui_block_d2s;
    if ((ui_block_d2s<0.5) || (ui_block_d2d<0.5))
        disp(sprintf('error!==>ui_block_d2s=%d\tui_block_d2d=%d\n',ui_block_d2s,ui_block_d2d));
    end
    vec_block_location(2,i_temp)=ui_block_d2s;
    vec_block_location(3,i_temp)=ui_block_d2d;
end
clear ui_block_d2s;
clear ui_block_d2d;
clear i_temp;

%Block�赲S��D�ĽǶȴ�С����1��linkno��2��r_half_angle_2_s��3:r_half_angle_2_d
vec_block_half_angle=zeros(3,ui_linkno);
vec_block_half_angle(1,:)=1:ui_linkno;
for i_temp=1:ui_linkno
    ui_block_s_half_angle=asin(0.5/vec_block_location(2,i_temp))*180/pi;
    if (ui_block_s_half_angle<0)
        ui_block_s_half_angle=ui_block_s_half_angle+180;
    end
    ui_block_d_half_angle=asin(0.5/vec_block_location(3,i_temp))*180/pi;
    if (ui_block_d_half_angle<0)
        ui_block_d_half_angle=ui_block_d_half_angle+180;
    end
    vec_block_half_angle(2,i_temp)=ui_block_s_half_angle;
    vec_block_half_angle(3,i_temp)=ui_block_d_half_angle;    
end
clear ui_block_s_half_angle;
clear ui_block_d_half_angle;
clear i_temp;
    
%�ǶȾ���
vec_angle=zeros(ui_sumsta);
for i_temp=1:ui_sumsta
    for j_temp=1:ui_sumsta
        if (i_temp==j_temp)
            vec_angle(i_temp,j_temp)=0;
        else
            vec_angle(i_temp,j_temp)=calangle(locate_node,i_temp,j_temp);
        end
    end
end
clear i_temp;
clear j_temp;

%�����ž���
%vec_sectorid=zeros(ui_sumsta);
vec_sectorid=floor(vec_angle/ui_theta_l)+1;
for i_temp=1:ui_sumsta
    vec_sectorid(i_temp,i_temp)=0;
end
clear i_temp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      FRS(fast relay selection)                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for link_temp=1:ui_linkno
    vec_sectorweight=zeros(1,ui_sumsta);
    
    ui_d_sectorid=vec_sectorid(vec_source(link_temp),vec_destination(link_temp));
    %�ȿ�D����S������idɸѡ������R���ϣ�+/-1,2��
    ui_right1=ui_d_sectorid+1;
    ui_left1=ui_d_sectorid-1;
    ui_right2=ui_d_sectorid+2;
    ui_left2=ui_d_sectorid-2;
    if (ui_left1<=0)
        ui_left1=ui_left1+ui_sumsector;
    end
    if (ui_left2<=0)
        ui_left2=ui_left2+ui_sumsector;
    end
    if (ui_right1>8)
        ui_right1=rem(ui_right1,ui_sumsector);
    end
    if (ui_right2>8)
        ui_right2=rem(ui_right2,ui_sumsector);
    end
    clear ui_d_sectorid;
    
    %����1����Ȩ��0.3������2����Ȩ��0.2����������Ȩ��0
    for stano=(2*ui_linkno+1):ui_sumsta
        if (vec_sectorid(link_temp,stano)==ui_left1 || vec_sectorid(link_temp,stano)==ui_right1)
            vec_sectorweight(1,stano)=1;
        elseif (vec_sectorid(link_temp,stano)==ui_left2 || vec_sectorid(link_temp,stano)==ui_right2)
            vec_sectorweight(1,stano)=0;
        else
            vec_sectorweight(1,stano)=0;
        end
    end
    clear stano;
    clear ui_left1;
    clear ui_left2;
    clear ui_right1;
    clear ui_right2;
    
    %ȡ������Ȩ�ط�0���±�,��R��id
    vec_validsectorno=zeros(1,ui_sumr);
    vec_validsectorno=find(vec_sectorweight);
    
    ui_validrno=nnz(vec_validsectorno);%����Ȩ�ط�0��R�ĸ���
    if (ui_validrno == 0)
        continue;
    end
    
    %ui_rlosΪֱ����·LOS�����ź�������ui_rriΪS-R-D��·�źŽ�������
    %��·Ȩ��
    
    %LOS��·���źŽ�������in dB
    vec_rlos=zeros(1,channel_times);
    for channel_temp=1:channel_times
        vec_rlos(1,channel_temp)=ui_pt+path_los_simu(vec_stadistance(link_temp,2*link_temp),vec_angle(link_temp,2*link_temp)-vec_sectorid(link_temp,2*link_temp)*ui_theta_l,ui_theta_l);
    end
    vec_rlos_sort=sort(vec_rlos);
    vec_rlos_top90=vec_rlos_sort(1,(channel_times*0.1+1):channel_times);
    ui_rlos=mean(vec_rlos_top90)-20-NL;
    clear channel_temp;
    
    %NLOS��·��S-R��R-D��path_loss���Լ�S-R-D��·�Ľ����ź�����in dB�����ռ�����·Ȩ��r_weight
    vec_rri=zeros(1,ui_validrno);
    vec_rweight=zeros(1,ui_validrno);
    % %     vec_rri_pw=zeros(1,ui_validrno);
    for stano=1:ui_validrno
        %S-R��·path_loss
        vec_rri_sr_los=zeros(1,channel_times);
        for channel_temp=1:channel_times
            vec_rri_sr_los(1,channel_temp)=path_los_simu(vec_stadistance(link_temp,vec_validsectorno(stano)),abs(vec_angle(link_temp,vec_validsectorno(stano))-vec_sectorid(link_temp,vec_validsectorno(stano))*ui_theta_l),ui_theta_l);
            if ((vec_angle(link_temp,vec_validsectorno(stano))>vec_angle(link_temp,ui_linkno+link_temp)-vec_block_half_angle(2,link_temp)) && (vec_angle(link_temp,vec_validsectorno(stano))<vec_angle(link_temp,ui_linkno+link_temp)+vec_block_half_angle(2,link_temp)))
                vec_rri_sr_los(1,channel_temp)=vec_rri_sr_los(1,channel_temp)-20;
            end
        end
        vec_rri_sr_los_sort=sort(vec_rri_sr_los);
        vec_rri_sr_los_top90=vec_rri_sr_los_sort(1,(channel_times*0.1+1):channel_times);
        ui_rri_sr_los=mean(vec_rri_sr_los_top90);
        clear channel_temp; 
        
        %R-D��·path_loss
        vec_rri_rd_los=zeros(1,channel_times);
        for channel_temp=1:channel_times
            vec_rri_rd_los(1,channel_temp)=path_los_simu(vec_stadistance(link_temp+ui_linkno,vec_validsectorno(stano)),abs(vec_angle(vec_validsectorno(stano),link_temp+ui_linkno)-vec_sectorid(vec_validsectorno(stano),link_temp+ui_linkno)*ui_theta_l),ui_theta_l);
            if ((vec_angle(ui_linkno+link_temp,vec_validsectorno(stano))>vec_angle(ui_linkno+link_temp,link_temp)-vec_block_half_angle(3,link_temp)) && (vec_angle(ui_linkno+link_temp,vec_validsectorno(stano))<vec_angle(ui_linkno+link_temp,link_temp)+vec_block_half_angle(3,link_temp)))
                vec_rri_rd_los(1,channel_temp)=vec_rri_rd_los(1,channel_temp)-20;
            end
        end
        vec_rri_rd_los_sort=sort(vec_rri_rd_los);
        vec_rri_rd_los_top90=vec_rri_rd_los_sort(1,(channel_times*0.1+1):channel_times);
        ui_rri_rd_los=mean(vec_rri_rd_los_top90);
        clear channel_temp;
        
        %S-R-D��·�Ľ����ź�����in dB
        vec_rri(1,stano)=ui_pt+ui_rri_sr_los+ui_rri_rd_los-NL;
        
        %��·Ȩ�ؼ���
% %         vec_rri_pw(1,stano)=(10^(vec_rri(1,stano)/10))/(10^(NL/10));
        vec_rweight(1,stano)=(10^(vec_rri(1,stano)/10)); 
    end
    %��������S-R-D��·����·Ȩ�ؽ���
    clear stano;
    
    %��һ����·Ȩ��r_weight
    vec_rweight_unit=zeros(1,ui_validrno);
    ui_sum_rweight=sum(vec_rweight(1,:));
    for stano=1:ui_validrno
% %         vec_rweight(1,stano)=vec_rri_pw(1,stano)/sum(vec_rri_pw(1,:));
        vec_rweight_unit(1,stano)=vec_rweight(1,stano)/ui_sum_rweight;
    end    
    clear stano;
        
    %vec_sumweight:��Ȩ�ؾ�������Ȩ��
    vec_sumweight=zeros(2,ui_validrno);
    for stano=1:ui_validrno
        vec_sumweight(1,stano)=vec_validsectorno(stano);
        vec_sumweight(2,stano)=vec_rweight_unit(1,stano)*vec_sectorweight(1,vec_validsectorno(stano));
    end
    clear stano;
    
    %��vec_sumweight��2����Ȩ��Ϊ��׼�Ծ�������������Ȩ�������������
    vec_sortweight=zeros(2,ui_validrno);
    [temp,index]=sort(vec_sumweight(2,:));%�Ե�2�д�С��Ϊ�����׼
    for i_temp=1:ui_validrno
        vec_sortweight(:,i_temp)=vec_sumweight(:,index(i_temp));
    end
    clear temp;
    clear i_temp;
    clear index;
    
    %��ʱѡȡ���ŵ�R��ΪΨһ��R
    vec_frs_bestrid(link_temp,caltimes)=vec_sortweight(1,ui_validrno);
   
end
clear link_temp;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                      ARS(all relay selection)                          %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for link_temp=1:ui_linkno
    
    %��������ÿ��R��·���ŵ�����C
    vec_rsnr4all=zeros(5,ui_sumr);
    
    %LOS��·���źŽ�������in dB
    vec_rlos=zeros(1,channel_times);
    for channel_temp=1:channel_times
        vec_rlos(1,channel_temp)=ui_pt+path_los_simu(vec_stadistance(link_temp,2*link_temp),vec_angle(link_temp,2*link_temp)-vec_sectorid(link_temp,2*link_temp)*ui_theta_l,ui_theta_l);
    end
    vec_rlos_sort=sort(vec_rlos);
    vec_rlos_top90=vec_rlos_sort(1,(channel_times*0.1+1):channel_times);
    ui_rlos=mean(vec_rlos_top90)-20-NL;
    clear channel_temp;
    
    %vec_rsnr4all����5��ui_sumr�У�1.R-ID��2.S-R���źŽ�������in dB����10dBm����3.R-D���źŽ�������in
    %dB����10dBm����4.C_AF��5.C_DF
    for stano=1:ui_sumr
        %��1�У�R-ID
        vec_rsnr4all(1,stano)=stano+2*ui_linkno;
        
        %��2�У�S-R��·SNR
        vec_srdbsnr4all=zeros(1,channel_times);
        for channel_temp=1:channel_times
            vec_srdbsnr4all(1,channel_temp)=ui_pt+path_los_simu(vec_stadistance(link_temp,stano+2*ui_linkno),abs(vec_angle(link_temp,stano+2*ui_linkno)-vec_sectorid(link_temp,stano+2*ui_linkno)*ui_theta_l),ui_theta_l);
            if ((vec_angle(link_temp,stano+2*ui_linkno)>vec_angle(link_temp,2*link_temp)-vec_block_half_angle(2,link_temp)) && (vec_angle(link_temp,stano+2*ui_linkno)<vec_angle(link_temp,2*link_temp)+vec_block_half_angle(2,link_temp)))
                vec_srdbsnr4all(1,channel_temp)=vec_srdbsnr4all(1,channel_temp)-20;
            end
        end
        vec_srdbsnr4all_sort=sort(vec_srdbsnr4all);
        vec_srdbsnr4all_top90=vec_srdbsnr4all_sort(1,(channel_times*0.1+1):channel_times);
        ui_srdbsnr4all=mean(vec_srdbsnr4all_top90)-NL;
        clear channel_temp;
        vec_rsnr4all(2,stano)=ui_srdbsnr4all;
        
        %��3�У�R-D��·SNR
        vec_rddbsnr4all=zeros(1,channel_times);
        for channel_temp=1:channel_times
            vec_rddbsnr4all(1,channel_temp)=ui_pt+path_los_simu(vec_stadistance(2*link_temp,stano+2*ui_linkno),abs(vec_angle(stano+2*ui_linkno,2*link_temp)-vec_sectorid(stano+2*ui_linkno,2*link_temp)*ui_theta_l),ui_theta_l);
            if ((vec_angle(2*link_temp,stano+2*ui_linkno)>vec_angle(2*link_temp,link_temp)-vec_block_half_angle(3,link_temp)) && (vec_angle(2*link_temp,stano+2*ui_linkno)<vec_angle(2*link_temp,link_temp)+vec_block_half_angle(3,link_temp)))
                vec_rddbsnr4all(1,channel_temp)=vec_rddbsnr4all(1,channel_temp)-20;
            end
        end
        vec_rddbsnr4all_sort=sort(vec_rddbsnr4all);
        vec_rddbsnr4all_top90=vec_rddbsnr4all_sort(1,(channel_times*0.1+1):channel_times);
        ui_rddbsnr4all=mean(vec_rddbsnr4all_top90)-NL;
        clear channel_temp;
        vec_rsnr4all(3,stano)=ui_rddbsnr4all;
        
        ui_SNRsd4all=(10^(ui_rlos/10))/(10^(NL/10));
        ui_SNRsr4all=(10^(ui_srdbsnr4all/10))/(10^(NL/10));
        ui_SNRrd4all=(10^(ui_rddbsnr4all/10))/(10^(NL/10));
        ui_caf_ars=0.5*ui_bandwith*log2(1+ui_SNRsd4all+ui_SNRsr4all*ui_SNRrd4all/(ui_SNRsr4all+ui_SNRrd4all+1));
        ui_cdf_ars=0.5*ui_bandwith*min(log2(1+ui_SNRsr4all),log2(1+ui_SNRsd4all+ui_SNRrd4all));
        vec_rsnr4all(4,stano)=ui_caf_ars;
        vec_rsnr4all(5,stano)=ui_cdf_ars;
    end
    clear stano;
    clear ui_rri4all;
    %clear ui_rlos;

    %��vec_sumweight��4��C_AFΪ��׼�Ծ�������������C_AF�����������
    vec_sortrsnr4all_af=zeros(5,ui_sumr);
    [temp,index]=sort(vec_rsnr4all(4,:));%��4�д�С��Ϊ�����׼
    for i_temp=1:ui_sumr
        vec_sortrsnr4all_af(:,i_temp)=vec_rsnr4all(:,index(i_temp));
    end
    clear temp;
    clear i_temp;
    clear index;
    
    %��vec_sumweight��5��C_DFΪ��׼�Ծ�������������C_DF�����������
    vec_sortrsnr4all_df=zeros(5,ui_sumr);
    [temp,index]=sort(vec_rsnr4all(5,:));%��5�д�С��Ϊ�����׼
    for i_temp=1:ui_sumr
        vec_sortrsnr4all_df(:,i_temp)=vec_rsnr4all(:,index(i_temp));
    end
    clear temp;
    clear i_temp;
    clear index;
    
    %��ʱѡȡ���ŵ�R��ΪΨһ��R
    vec_ars_bestrid4all_af(link_temp,caltimes)=vec_sortrsnr4all_af(1,ui_sumr);
    vec_ars_bestrid4all_df(link_temp,caltimes)=vec_sortrsnr4all_df(1,ui_sumr);
    vec_ARS_AF_RESULT(link_temp,caltimes)=vec_sortrsnr4all_af(4,ui_sumr);
    vec_ARS_DF_RESULT(link_temp,caltimes)=vec_sortrsnr4all_df(5,ui_sumr);
    
    if (0 ~= vec_frs_bestrid(link_temp,caltimes))
        if ((vec_sortrsnr4all_af(4,ui_sumr) < vec_rsnr4all(4,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno)) || (vec_sortrsnr4all_df(5,ui_sumr) < vec_rsnr4all(5,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno)))
            disp(sprintf('wrong no:af=%d\tdf=%d\tfrs=%d\t%d\n',vec_sortrsnr4all_af(4,ui_sumr),vec_sortrsnr4all_df(5,ui_sumr),vec_rsnr4all(4,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno),vec_rsnr4all(5,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno)));
        end

        %FRS��ʽ��ѡ��R���ŵ�����������ARS�����е�R���ŵ������������������FRS���ŵ���������Ҫ�ظ����㣬ֻ��Ҫ����Ӧ��ID��R���ŵ�����ֵȡ������
        vec_FRS_AF_RESULT(link_temp,caltimes)=vec_rsnr4all(4,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno);
        vec_FRS_DF_RESULT(link_temp,caltimes)=vec_rsnr4all(5,vec_frs_bestrid(link_temp,caltimes)-2*ui_linkno);
    end
    
end

clear link_temp;

end

ui_mean_frs_caf=mean(vec_FRS_AF_RESULT);
ui_mean_frs_cdf=mean(vec_FRS_DF_RESULT);
ui_mean_ars_caf=mean(vec_ARS_AF_RESULT);
ui_mean_ars_cdf=mean(vec_ARS_DF_RESULT);
ui_caf_percent=ui_mean_frs_caf/ui_mean_ars_caf;
ui_cdf_percent=ui_mean_frs_cdf/ui_mean_ars_cdf;
ui_mean_frs_af=mean(ui_mean_frs_caf);
ui_mean_frs_df=mean(ui_mean_frs_cdf);
ui_mean_ars_af=mean(ui_mean_ars_caf);
ui_mean_ars_df=mean(ui_mean_ars_cdf);
disp(sprintf('FRS:\t%d\t%d\n',ui_mean_frs_af,ui_mean_frs_df));
disp(sprintf('ERS:\t%d\t%d\n',ui_mean_ars_af,ui_mean_ars_df));
disp(sprintf('%d\t%d\n',ui_caf_percent,ui_cdf_percent));
