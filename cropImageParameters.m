function [crop_Image] = cropImageParameters(Image, width, heigth) 
%FUNCTION CLIPPING IMAGE ACCORDING TO ITS PARAMETERS 
% -------------------------------------------------------------------------
% Copyright (c) 2024 Instituto Politécnico Nacional (IPN), México.
% All Rights Reserved.
% -------------------------------------------------------------------------
% -------------------------------------------------------------------------
% Permission to use, copy, modify, and distribute this software for
% educational, research, and non-profit purposes is hereby granted, without 
% fee or written agreement is hereby granted, provided that this copyright 
% notice appears in all copies. IPN does not warrant that the operation of the 
% program will be uninterrupted or error-free. The end user understands that 
% the program has been developed for research purposes and is advised not to
% rely exclusively on the program for any reason. In no even shall IPN be 
% liable to any party for any direct, indirect, special, incidental, or 
% consequential damages, including lost profits, arising out of the use of this
% software. IPN disclaims all warranties, and has no obligation to provide
% maintenance, support, updates, improvements, or modifications.
% -------------------------------------------------------------------------
% Version: 20240208
% -------------------------------------------------------------------------
% Authors:
%      César Enrique Rojas-López,     IPN-ESIME Culhuacan.
%      Omar Jiménez-Ramírez,          IPN-ESIME Culhuacan.
%      Luis Niño-de-Rivera-Oyarzabal, IPN-ESIME Culhuacan.
%      Leonardo Palacios-Luengas,     UAM-Iztapalapa.   
%      Rubén Vázquez-Medina,          IPN-CICATA Querétaro.

% Contact: rvazquez@ipn.mx | February 2024
%
% -------------------------------------------------------------------------
% DESCRIPTION:
% This function crop the image according to its parameters, using the center as a reference.

% INPUTS:
%     Image              - Green layer image.
%     width              - Width of the image clipping extracted from reference flat images,
%                          considering as reference point the image centroid.
%     height             - Heigth of the image clipping extracted from reference flat images,
%                          considering as reference point the image centroid.

% OUTPUTS:
%     crop_Image         - Cropped image.

targetSize = [width heigth];
    r = centerCropWindow2d(size(Image),targetSize);
    crop_Image = imcrop(Image,r);
end

