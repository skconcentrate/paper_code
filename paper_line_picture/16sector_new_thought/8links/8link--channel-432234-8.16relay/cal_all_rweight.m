%���Ǽ���ȫ��R��Ȩ�ص�code




%ui_rlosΪֱ����·LOS�����ź�������ui_rriΪS-R-D��·�źŽ�������
    %���͹���Ϊ10dbm
    %RȨ��
    vec_rweight=zeros(1,ui_validrno);
    ui_rlos=-22.5-20*log10(vec_stadistance(ui_linkno,2*ui_linkno)/1000)-20*log10(60000);
    for stano=(2*ui_linkno+1):ui_sumsta
        ui_rri=-22.5-20*log10((vec_stadistance(ui_linkno,stano)+vec_stadistance(2*ui_linkno,stano))/1000)-20*log10(60000);
        vec_rweight(1,stano-2*ui_linkno)=(1-abs(ui_rri/ui_rlos-1))*sin(vec_alpha(1,stano-2*ui_linkno)*pi/360)*sin(vec_beta(1,stano-2*ui_linkno)*pi/360);
    end
    clear rri;
    clear rlos;
    clear stano;
    clear ui_rri;
    clear ui_rlos;