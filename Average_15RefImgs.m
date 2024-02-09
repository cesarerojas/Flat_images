function [vectors_Icero_and_PRNU_averageRef] = Average_15RefImgs(numCaptDevice, width, height) 
%FUNCTION OBTAINING AVERAGE OF 15 REFERENCE IMAGES
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

% Contact: ruvazquez@ipn.mx | February 2024
%
% -------------------------------------------------------------------------
% DESCRIPTION:
% This function reads 15 flat reference images from a capture device, gets 
% their green layer and crops them to the specified width and height. Then 
% it gets the i_{0} and the PRNU of each image and takes the average of the 
% 15 images.

% INPUTS:
%     numCaptDevice      - Number of capture devices to be used
%     width              - Width of the image clipping extracted from reference flat images,
%                          considering as reference point the image centroid.
%     height             - Heigth of the image clipping extracted from reference flat images,
%                          considering as reference point the image centroid.
%     path_Im_References - Full path to where the 15 reference images will be read.
%                          This variable is requested 8 times, once for each capture device.
%                          Example:
%                           iPhone_SE2020_1_flat_01.JPG
%                           iPhone_SE2020_1_flat_02.JPG
%                           iPhone_SE2020_1_flat_03.JPG
%                           iPhone_SE2020_1_flat_04.JPG
%                           iPhone_SE2020_1_flat_05.JPG
%                           iPhone_SE2020_1_flat_06.JPG
%                           iPhone_SE2020_1_flat_07.JPG
%                           iPhone_SE2020_1_flat_08.JPG
%                           iPhone_SE2020_1_flat_09.JPG
%                           iPhone_SE2020_1_flat_10.JPG
%                           iPhone_SE2020_1_flat_11.JPG
%                           iPhone_SE2020_1_flat_12.JPG
%                           iPhone_SE2020_1_flat_13.JPG
%                           iPhone_SE2020_1_flat_14.JPG
%                           iPhone_SE2020_1_flat_15.JPG


% OUTPUTS:
%     vectors_Icero_and_PRNU_averageRef - Contains the i_{0} and PRNU averaged from 15 clipped reference images.

% REQUIRED FUNCTION:
%    cropImageParameters.m - Crop the image according to its parameters, using the center as a reference.

    counter = 1;
    for i = 3 : (numCaptDevice+2)
        fprintf('Full path 15 REFERENCE FLAT files of the Capture Device %d: ', i-2)
        path_Im_References = input ('', 's');
        cd (path_Im_References);
        ReferenceFiles = ls(path_Im_References); 
        numberReferenceFiles = size(ReferenceFiles,1);
        cd (path_Im_References);

        for j = 3 : numberReferenceFiles
            filenameReference = (ReferenceFiles(j,:));
            referenceImage = imreadort(filenameReference); 
            I = uint8(double(referenceImage(:,:,2))); 
            I = cropImageParameters(I, width, height);

            eta = NoiseExtractFromImage(I,2);
            Icero = double(I)-eta;
            PRNU = WienerInDFT(eta,std2(eta ));

            vector_Icero(:,j-2)= Icero(:);
            vector_PRNU(:,j-2) = PRNU(:);
        end
        if i == 3
            vectors_Icero_and_PRNU_averageRef = zeros (length(vector_Icero),numCaptDevice*2);
        end
        for j = 1 : size(vector_Icero,1)
            vectors_Icero_and_PRNU_averageRef(j,counter) =  sum(vector_Icero(j,:))/15;
            vectors_Icero_and_PRNU_averageRef(j,counter+1) =  sum(vector_PRNU(j,:))/15;
        end
        counter = counter + 2;
    end
end
