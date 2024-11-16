%After learning from a warm-up block, we start to learning model
%sequentially in a streaming environment, where each instance may be
%associated with several false negative labels.

function [ResultAll,time] = RMSC(X,Y,G,para)
% Inputs:X-d*T 
%        Y-q*T Y-{1,-1} label matrix with false-negative labels
%        G-q*T Y-{1,-1} ground-truth label matrix
%        para-parameters including Cp,Cn,C1,C2,num
% Outputs:ResultAll-classification results
% 			time-running time

    start = tic;
    Cp = para.Cp; Cn = para.Cn; C1 = para.C1; C2 = para.C2; 
    [d,T] = size(X); num = para.num; q = size(Y,1); 
    Y (Y==0) = -1;
    X0 = X(:,1:num);X = X(:,num+1:end);
    Y0 = Y(:,1:num);Y = Y(:,num+1:end);
    
    [~,T] = size(X); 
    Pr = cal_Pr(Y0); 
    yt_hat = zeros(size(G));
    
    theta = zeros(q+1,d);
    
    %% preTrain
    for t = 1:num
       %% observe xt and gt
        xt = X0(:,t); yt = Y0(:,t);NZ_idx = find(xt~=0);
        Outputs(:,t) = theta(:,NZ_idx)*xt(NZ_idx);%?
        thr = ExplicitTuneHJ(Outputs(1:q,t),G(:,t));
       %% update corresponding variables
        a = ones(q,1);b = ones(q,1).*[(1-yt)/2*Cn+(1+yt)/2*Cp];
        try
            a(end+1,:) = thr;b(end+1,:) = Cp; yt(end+1,:) = 1;
        catch exception
       % Code to handle the exception
            fprintf('An exception occurred: %s\n', exception.message);
        end
       %% update lambda_t
        A = xt'*xt*eye(q+1)+0.5*diag(1./b); 
        temp = a-diag(yt)*theta(:,NZ_idx)*xt(NZ_idx); temp(1:q,:) = max(temp(1:q,:),0);
        lambda = A\temp;
       %% update theta_t
        theta(:,NZ_idx) = theta(:,NZ_idx) + diag(yt)*lambda*xt(NZ_idx)';
    end 
    O = cal_O(X0,Y0);Outputs = zeros(q+1,T);     
    %% start the online learning 
    for t = 1:T
       %% observe xt and predict yt_hat
        xt = X(:,t); yt = Y(:,t); NZ_idx = find(xt~=0);
        Outputs(:,t) = theta(:,NZ_idx)*xt(NZ_idx);%?
        thr = Outputs(q+1,t); thr_seq(t) = thr;
        yt_hat(:,t) = sgn(Outputs(1:q,t)-thr);
       %% observe noisy yt and update corresponding variables
        [a,b,yt,~,~] = cal_AB(yt,xt,Y(:,t),Pr,O,theta,Cp,Cn,C1,C2);   
        A = xt'*xt*eye(q+1)+0.5*diag(1./b);
        temp = a-diag(yt)*theta(:,NZ_idx)*xt(NZ_idx); temp(1:q,:) = max(temp(1:q,:),0);
        lambda = A\temp;
       %% update theta_t
        theta(:,NZ_idx) = theta(:,NZ_idx) + diag(yt)*lambda*xt(NZ_idx)';
    end
   
    G(G==-1) = 0; yt_hat(yt_hat==-1) = 0;
    ResultAll = EvaluationAll(yt_hat(:,num+1:end),Outputs(1:q,:),G(:,num+1:end));
    time = toc(start);
end

function [a,b,yt,Pr,O] = cal_AB(yt,xt,gt,Pr,O,theta,Cp,Cn,C1,C2)
       Outputs = theta*xt;
       Outputs(end) = [];%exclude thr
       p_idx = find(yt==1);
       n_idx = find(yt==-1);   

       thr = ExplicitTuneHJ(Outputs,yt);

       q = length(yt);
       b = zeros(q,1); b(end+1,:) = Cn;% 2^-5
       try
            a = ones(q,1);a(end+1,:) = thr; % This will raise an exception
       catch exception
       % Code to handle the exception
            fprintf('An exception occurred: %s\n', exception.message);
       end
       
       %b = zeros(q,1);b(end+1,:) = Cn;     
       for j = 1:length(yt)
           if yt(j)==1
               b(j) = Cp;
           else
               if sum(abs(O(:,j))) == 0
                    b(j) = Cn;
               else
                   if C2 > 0
                        b(j) = Cn*C2*norm(xt-O(:,j),'fro');%%or l_1 norm 
                   else
                        b(j) = Cn;
                   end 
               end
           end      
       end
                 
       yt(end+1,:) = 1;
       
       if length(p_idx)>=1
            %Update the label prototype
            for j = 1:length(p_idx)
               %if Pr(p_idx(j),p_idx(j)) == 0,  O(:,p_idx(j)) = zeros(size(O(:,p_idx(j))));end
               Pr(p_idx(j),p_idx(j)) = Pr(p_idx(j),p_idx(j)) + 1;
               O(:,p_idx(j)) = (O(:,p_idx(j))*(Pr(p_idx(j),p_idx(j))-1)+xt)/Pr(p_idx(j),p_idx(j));
            end
            for j = 1:length(n_idx)
                sigma_j = max(Pr(p_idx,n_idx(j)));
                a(n_idx(j)) = 1 - C1*sigma_j;
            end        
       end
       %ignore negative example
       if length(p_idx)>=2
            for j = 1:length(p_idx)            
                for k = 1:length(p_idx)
                    if j==k 
                        continue;
                    end
                    Pr(p_idx(j),p_idx(k)) = (Pr(p_idx(j),p_idx(k))*(Pr(p_idx(j),p_idx(j))-1)+1)/(Pr(p_idx(j),p_idx(j)));               
                end                
            end     
       end       
end

function Pr = cal_Pr(Y)
    %Pr(i,j) = Pr(y_j=1|y_i=1)
    [q,n] = size(Y);
    Pr = zeros(q,q);card = zeros(q,1);
    for i = 1:n%%not up-triangle
        p_idx = find(Y(:,i)==1);
        for j = 1:length(p_idx)   
            card(p_idx(j)) = card(p_idx(j)) + 1;
            for k = 1:length(p_idx)   
                if j==k 
                    continue;
                end
                Pr(p_idx(j),p_idx(k)) = Pr(p_idx(j),p_idx(k)) + 1;   
            end                
        end      
    end
    div = card*ones(1,q);Pr = Pr./div; Pr = Pr + diag(card);
    Pr(isnan(Pr)) = 0;
end

function O = cal_O(X,Y)
    [d,~] = size(X);[q,~] = size(Y);
    O = zeros(d,q);%label prototype
    for j = 1:q                
        idx = find(Y(j,:)==1);
        temp = zeros(d,1);
        for i = 1:length(idx) 
            temp = temp + X(:,idx(i));
        end    
        O(:,j) = temp/length(idx);
        O(isnan(O)) = 0;
    end
end



