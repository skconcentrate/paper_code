% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Conference Room Channel Model
%    File Name:     cr_ch_model.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
%
%    function returns channel impulse response for Conference Room (CR) environment
%
%    [imp_res] = cr_ch_model()
%
%    Inputs:
%
%       no inputs, parameters are set in cr_ch_cfg.m configuration file
%
%    Outputs:
%
%       1. imp_res - channel impulse response
%
%  *************************************************************************************/
% ����������������������Ӧ��·����ģ���������Ǿ��룬�ǶȺͲ�����ȣ�
function [imp_res,path_db_] = cr_ch_model(dis,angle_,beamwidth)

% ���ݾ���Ͳ�����������г���������
% load configuration structure <- cr_ch_cfg.m
cfg = cr_ch_cfg(dis,beamwidth);

% ��֪����cfg.cr�����úͲ������͵ļ���
% generate space-time channel impulse response realization
ch = gen_cr_ch(cfg.cr,cfg.bf.ps,cfg.bf.pol);

% apply beamforming algorithm
[imp_res,toa,path_db_] = beamforming(cfg.bf,ch,angle_);

% continuous time to descrete time conversion
imp_res = ct2dt(imp_res,toa,cfg.sample_rate);

% normalization according to Pnorm parameter
if (cfg.Pnorm)
    imp_res = imp_res./norm(imp_res);
end