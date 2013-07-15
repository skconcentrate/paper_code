% /*************************************************************************************
%    Intel Corp.
%
%    Project Name:  60 GHz Channel Model
%    File Name:     polarization.m
%    Authors:       A. Lomayev, R. Maslennikov
%    Version:       5.0
%    History:       May 2010 created
%
%  *************************************************************************************
%    Description:
% 
%    function returns Jones vector describing antenna polarization in
%    accordance with polarization type parameter
%
%    [pol_vec] = polarization(pol)
%
%    Outputs:
%
%       1. pol_vec - Jones vector describing antenna polarization
%
%    Inputs:
%
%       1. pol - parameter selects polarization type
%
%  *************************************************************************************/
function [pol_vec] = polarization(pol)

switch (pol)
    case 0, % linear in theta direction
        pol_vec = [1;0];
    case 1, % linear in thi direction
        pol_vec = [0;1];
    case 2, % LHCP
        pol_vec = [1;j]./sqrt(2);
    case 3, % RHCP
        pol_vec = [1;-j]./sqrt(2);
end