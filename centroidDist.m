function [ ch ] = centroidDist( cenOne,cenTwo )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

ch=sqrt((cenOne(1)-cenTwo(1))^2 +(cenOne(2)-cenTwo(2))^2);

end

