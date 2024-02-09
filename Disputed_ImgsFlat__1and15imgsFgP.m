function [] = Disputed_ImgsFlat__1and15imgsFgP(RESULTS_folder, numCaptDevice, numInitialImg, numRefImgs, width, height) 
%Function that analyses flat images. Option Resume
% -------------------------------------------------------------------------
% Copyright (c) 2024 Instituto Politécnico Nacional, México.
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
% This function estimates the Mahalanobis distance between the intrisic signal left by the capture device 
% in flat digital images and different camera fingerprints. 
% Resume option. It means to get the results of the disputed flat image 
% without checking all options, just assuming your own fingerprint. 
%
% INPUTS:
%     RESULTS_folder     - Full path where the results will be stored
%     path_DisputedImg   - Full path to where the disputed images will be read.
%                          This variable will be requested 10 times since 10 disputed images 
%                          will be analyzed for each capture device. It is
%                          assumed that each folder of disputed image will store the d_k images of all the capture devices.
%                          Example:
%                             01 iPhone_SE2020_1_flat_41.JPG
%                             02 iPhone_XR_flat_41.JPG
%                             03 Motorola_G4Plus_flat_41.jpg
%                             04 Samsung_GalaxyA01_flat_41.jpg
%                             05 Samsung_GalaxyNote9_flat_41.jpg
%                             06 Motorola_G20_flat_41.jpg
%                             07 iPhone_SE2020_2_flat_41.JPG
%                             08 Huawei_Y9-2019_flat_41.jpg
%     numCaptDevice      - Number of capture devices considered in the analysis
%     numInitialImg      - Consecutive number from which the disputed images 
%                          will be considered in each capture device folder
%     numRefImgs         - Must be 1 or 15, corresponds to the number of flat 
%                          reference images used to build the smartphone camera fingerprint.
%     width              - Width of the image clipping considering as reference point the image centroid.
%     height             - Heigth of the image clipping considering as reference point the image centroid.
%
% OUTPUTS:
%     AverageImgs        - Matrix with a number of rows equal to width x height and a number 
%                          of columns equal to 16. The odd columns contain the pixel intensity 
%                          of the green layer of disputed image and the even columns contain the PRNU.
%     total              - mat file with an 8 x 16 matrix. In each pair of columns, the first columnn refers 
%                          to the number of times the inequality DM(T_{i,j},H_{01-15,k}) ≤ DM(T_{i,j},H_{01-15,l}
%                          was satisfied, and the second column refers to when it was not satisfied, where T_{i,j}
%                          is the intrinsic signal left by the j-th capture device on the disputed image number i, 
%                          and H_{01-15,l} is the fingerprint for l-th capture device using fifteen reference flat image. 
%                          l is the first index, which varies by affecting the rows 
%                          in the tables, and k is the second index, which varies by affecting each pair of columns
%                          Thus, this file shows the 8 results of a disputed image when it is assumed 
%                          to belong to a different capture device.
%                           
%
% REQUIRED FUNCTION:
%    Average_15RefImgs.m - It calculates the camera fingerprint using fifteen reference flat images.
%
%
% PROCEDURE:
% With the function "Average_15RefImgs" 15 reference images of each capture device 
%    are read to obtain their average of the icero and PRNU. (if necessary)
%    The number of the capture device is sent, as well as the width and height required.
% The first disputed image is read and with the function "cropImageParameters" 
%    a crop is obtained and the vectors of icero and PRNU are obtained, T.
% If numRefImgs == 15
%   The pixel icero and PRNU of the averaged reference images are read, R. (see 1)
%   T and H are made the same size.
%   The Mahalanobis Distance, DM, is obtained for each capture device. 
% else
%   Read the reference images and get the icero and PRNU
%   T and H are made the same size.
%   The Mahalanobis Distance, DM, is obtained for each capture device. 
% The Mahalanobis distance is calculated step by step. 
% The results are saved.

   close all 
   clc
   path = 0; DC_References_Limits = 1;
   if numRefImgs == 15
       AverageImgs = Average_15RefImgs(numCaptDevice, width, height);
   end
   
   while numInitialImg <= 50
      fprintf('Full path to the disputed image number %d from the eight capture devices: ', numInitialImg)
      path_DisputedImg = input ('', 's');
      %***DISPUTED IMAGES***
      cd (path_DisputedImg);
      disputedFile = ls(path_DisputedImg);
      numberDisputesFiles = size(disputedFile,1);
      column_counts = 1;
      for i = 3 : numberDisputesFiles
         cd (path_DisputedImg); 
         filenameCurrentDisputed = (disputedFile(i,:));
         disputedImage = imreadort(filenameCurrentDisputed);
         I = uint8(double(disputedImage(:,:,2)));
         I = cropImageParameters(I, width, height);
 
         CV_eta  = NoiseExtractFromImage(I,2);
         Icero_D = double(I)-CV_eta;
         PRNU_D  = WienerInDFT(CV_eta,std2(CV_eta ));
 
         vector_Icero_D = Icero_D(:);
         vector_PRNU_D  = PRNU_D(:);

         T = [vector_Icero_D, vector_PRNU_D];
         if numRefImgs == 15
             k = 1;
             icero_y_PRNU = 1;
             while (k <= numCaptDevice)
                %Average 15 Reference image as statistical fingerprint
                vector_Icero_Ref (:,1) = AverageImgs(:,icero_y_PRNU);
                vector_PRNU_Ref  (:,1) = AverageImgs(:,icero_y_PRNU+1);
                H = [vector_Icero_Ref, vector_PRNU_Ref];

                % CROP VECTOR OF SELECTED PIX OF REFERENCE IMAGE TO VECTOR SIZE OF SELECTED PIX OF THE DISPUTED IMAGE
                if length(vector_Icero_D) < length(vector_Icero_Ref)
                    vector_Icero_Ref2 = vector_Icero_Ref(1:length(vector_Icero_D),:);
                    vector_PRNU_Ref2  = vector_PRNU_Ref (1:length(vector_Icero_D),:);
                    H = [vector_Icero_Ref2, vector_PRNU_Ref2];
                    T = [vector_Icero_D,    vector_PRNU_D];
                else
                    vector_Icero_D2 = vector_Icero_D(1:length(vector_Icero_Ref),:);
                    vector_PRNU_D2  = vector_PRNU_D (1:length(vector_Icero_Ref),:);
                    T = [vector_Icero_D2, vector_PRNU_D2];
                end

                if (k == 1)
                    DM  = zeros (length(T),size(disputedFile,1)-2);
                end
                dif = T-H; COVARIANCE = cov(T-H); COV_INVERSE = inv(COVARIANCE);

                for n = 1 : size(T,1)
                    DM(n,k) = sqrt((dif(n,:) * COV_INVERSE) * dif(n,:)');
                end                

                k=k+1; icero_y_PRNU = icero_y_PRNU + 2;
                clear H
             end
         else
            k = 1;
            if path == 0
               fprintf('Full path 8 Reference Flat files of all Capture Device: ');
               path_Im_References = input ('', 's');
               path = 1;
            end
            %Reference Images
            cd (path_Im_References);
            referenceFiles = ls(path_Im_References);
            numberReferenceFiles = size(referenceFiles,1);
            for j = 3 : numberReferenceFiles
               filenameCurrentReferences = (referenceFiles(j,:));
               referenceImage = imreadort(filenameCurrentReferences);
               IRef = uint8(double(referenceImage(:,:,2)));
               IRef = cropImageParameters(IRef, width, height);

               CV_etaRef  = NoiseExtractFromImage(IRef,2);
               Icero_R = double(IRef)-CV_etaRef;
               PRNU_R  = WienerInDFT(CV_etaRef,std2(CV_etaRef ));

               vector_Icero_Ref = Icero_R(:);
               vector_PRNU_Ref  = PRNU_R(:);

               H = [vector_Icero_Ref, vector_PRNU_Ref];
               % CROP VECTOR OF SELECTED PIX OF REFERENCE IMAGE TO VECTOR SIZE OF SELECTED PIX OF THE DISPUTED IMAGE
               if length(vector_Icero_D) < length(vector_Icero_Ref)
                   vector_Icero_Ref2 = vector_Icero_Ref(1:length(vector_Icero_D),:);
                   vector_PRNU_Ref2  = vector_PRNU_Ref (1:length(vector_Icero_D),:);
                   H = [vector_Icero_Ref2, vector_PRNU_Ref2];
                   T = [vector_Icero_D, vector_PRNU_D];
               else
                   vector_Icero_D2 = vector_Icero_D(1:length(vector_Icero_Ref),:);
                   vector_PRNU_D2  = vector_PRNU_D(1:length(vector_Icero_Ref),:);
                   T = [vector_Icero_D2, vector_PRNU_D2];
               end

               if (k == 1)
                   DM  = zeros (length(T),size(disputedFile,1)-2);
               end
               dif = T-H; COVARIANCE = cov(T-H); COV_INVERSE = inv(COVARIANCE);

               for n = 1 : size(T,1)
                   DM(n,k) = sqrt((dif(n,:) * COV_INVERSE) * dif(n,:)');
               end                
               k=k+1;
               clear H
            end
         end
         
         if column_counts == 1
            total = zeros ((numCaptDevice),(numCaptDevice*2));
         end
         
         C = zeros (size(DM,1),size(DM,2)*3);
         fil = 1;
         for column = 1 : size(DM,2)
             for row = 1 : size(DM,1)
                 if (DM(row,i-2)<DM(row,column))
                     C(row,fil)=1;
                 else
                     if (DM(row,i-2)>DM(row,column))
                         C(row,fil+1)=1;
                     else
                         C(row,fil+2)=1;
                     end
                 end
             end
             fil = fil + 3;
         end


         %GETS COMPARISON TOTALS
         col = 1;
 
         for h = 1 : size(C,2)/3
             total(h,column_counts) = sum(C(:,col))+sum(C(:,col+2));
             total(h,column_counts+1) = sum(C(:,col+1));
             col = col +3;
         end
         column_counts = column_counts + 2; 
         clear DM        
     end
     if numRefImgs == 15
        filename  = sprintf('%s.mat', [RESULTS_folder,'\RESUME D',int2str(numInitialImg),', - Average_15ImgRef 1000x1000 assuming belonging DC0',int2str(DC_References_Limits),', - DM 1 a 1 ']);
     else
        filename  = sprintf('%s.mat', [RESULTS_folder,'\RESUME D',int2str(numInitialImg),', - 1RefImg 1000x1000 assuming belonging DC0',int2str(DC_References_Limits),', - DM 1 a 1 ']); 
     end
     save (filename, 'total');
     column_counts = 1;
     clear total 
     DC_References_Limits = DC_References_Limits + 1;
     numInitialImg = numInitialImg + 1;
   end
end