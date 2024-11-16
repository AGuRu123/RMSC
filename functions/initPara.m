% RMSC:
% Parameters          : Cp, Cn, C1, C2, num

function [optmParameter,modelparameter] = initPara(name)

    optmParameter.Cp = 2^0; 
    optmParameter.Cn = 2^-5; 
    optmParameter.C1 = 0*2^0; 
    optmParameter.C2 = 2^1; 
    optmParameter.num = 200;
  
    if nargin == 1
        switch name
            case 'enron' 
                optmParameter.C1 = 2^0;optmParameter.C2 = 2^-1;
            case 'mediamill' 
                optmParameter.C1 = 2^1;optmParameter.C2 = 2^4;
            case 'imdb' 
                optmParameter.C1 = 2^3;optmParameter.C2 = 2^0;
            case 'corel16k001' 
                optmParameter.C1 = 2^3;optmParameter.C2 = 2^2;
            case 'TMC2007' 
                optmParameter.C1 = 2^1;optmParameter.C2 = 2^0;
            case 'nus-wide' 
                optmParameter.C1 = 2^2;optmParameter.C2 = 2^1;
            case 'arts' 
                optmParameter.C1 = 2^1;optmParameter.C2 = 2^-2;
            case 'mirflickr' 
                optmParameter.C1 = 2^3;optmParameter.C2 = 2^0;
            case 'genbase' 
                optmParameter.C1 = 0*2^3;optmParameter.C2 = 2^0;
            case 'medical' 
                optmParameter.C1 = 0*2^3;optmParameter.C2 = 2^0;
            case 'languagelog' 
                optmParameter.C1 = 2^2;optmParameter.C2 = 2^-4;optmParameter.Cn = 2^-1;
            case 'core15k'
                optmParameter.C1 = 2^2;optmParameter.C2 = 2^1;
            case 'bibtex'
                optmParameter.C1 = 0*2^2;optmParameter.C2 = 0*2^1;
            case 'eurlex-sm'
                optmParameter.C1 = 2^-3;optmParameter.C2 = 2^1;
            case 'CAL500'
                optmParameter.C1 = 2^2;optmParameter.C2 = 2^1;
            case 'recreation'
                optmParameter.C1 = 2^1;optmParameter.C2 = 2^-5;optmParameter.Cn = 2^-1;
            otherwise
                optmParameter.C1 = 2^1;optmParameter.C2 = 2^-2;
        end
    end

end
