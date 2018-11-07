function [ImageArray, Metadata] = LoadTIFF_SI5(FileStr)
% This function loads ScanImage5 TIFFs.  The structure InfoImage contains
% all of the header information.  ImageArray contains the movie data
% (Row,Col,NumberImages).  RowPixels,  ColPixels, NumberImages are scalars.

   %  FileTif='/Users/Dan/Documents/MATLAB/test_00004.tif';
    FileTif=FileStr;
    InfoImage=imfinfo(FileTif);
    RowPixels=InfoImage(1).Width;
    ColPixels=InfoImage(1).Height;
    NumberImages=length(InfoImage);
    ImageArray=zeros(ColPixels,RowPixels,NumberImages,'uint16');
 
    TifLink = Tiff(FileTif, 'r');
   for i=1:NumberImages
      TifLink.setDirectory(i);
      ImageArray(:,:,i)=TifLink.read();
    end
    TifLink.close();

    Metadata = struct('RowPixels',RowPixels,'ColPixels',ColPixels,'NumFrames',NumberImages,'InfoImage',InfoImage);
end


