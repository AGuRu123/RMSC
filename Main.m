clear;clc;

ratio = [0.3,0.4,0.5];

NameList = {'enron'};
if(~exist('Ex','dir'))
    mkdir('Ex');
end

for i = 1:length(NameList)
name = NameList{i};
load ([name '.mat']);
if exist('train_data','var')==1
    data=[train_data;test_data];
    G=[train_target,test_target];
    clear train_data test_data train_target test_target
end
if exist('dataset','var')==1
    data=dataset;
    G=class;
    clear dataset class
end  
G(G==0) = -1;
%normalization
data = data./(sqrt(sum((data.*data),2))*ones(1,size(data,2)));%
data(isnan(data))=0;X = data';

for k = ratio
	G_temp = G';G_temp(G_temp==-1)=0;
    Y = getIncompleteTarget(transfer_v1(G,0,1),k,0);
    Y = Y'; Y(Y==0)=-1;
    %% evaluation of RMSC
	[ResultAll,Time] = RMSC(X,Y,G,initPara(name));%
    save([pwd '\\' 'Ex' '\\' name  '_' num2str(k) '.mat'],'ResultAll','Time');
end   

end



