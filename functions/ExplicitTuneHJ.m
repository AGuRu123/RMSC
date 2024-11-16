function tau = ExplicitTuneHJ(Outputs,gt,metricIndex)
%The online thresholding algorithm A
    if nargin < 3
        metricIndex = 3;
    end
    
    %gt(gt==-1)=0;
    TotalNums = 10;
    min_score = 0;
    %min_score = min(min(Outputs));
    max_score = max(max(Outputs));
    step = (max_score - min_score)/TotalNums;
    tau_range = min_score:step:max_score;
    tau = 0;
    currentResult = tau;
    
    for t = 1:length(tau_range)
        threshold = tau_range(t);
        predict_target = single( (Outputs - threshold) >= 0 );
        tempResult = evaluateOneMetric(gt, predict_target, metricIndex);
        if tempResult > currentResult
            currentResult = tempResult;
            tau = threshold;
        end    
    end
end

function f1 = evaluateF1(target, predict)
% label-based f1 bor each label
    TP = target*predict';
    precision = TP/sum(predict~=0);
    recall = TP/sum(target~=0);
    f1 = 2*precision*recall/(precision + recall);
end

function  Result = evaluateOneMetric(target, predict_target, metric)
% predict_target
% target
%   
    Result = 0;
    if metric == 1
        HammingScore = 1 - Hamming_loss(predict_target,target);
        Result = HammingScore;
    elseif metric==2 || metric==3
        [ExampleBasedAccuracy,~,~,ExampleBasedFmeasure] = ExampleBasedMeasure(target,predict_target);
        if metric==2 
            Result = ExampleBasedAccuracy;
        else
            Result = ExampleBasedFmeasure;
        end
    elseif metric == 4 || metric == 5
        [LabelBasedAccuracy,~,~,LabelBasedFmeasure] = LabelBasedMeasure(target,predict_target);
        if metric==4 
            Result = LabelBasedAccuracy;
        else
            Result = LabelBasedFmeasure;
        end
    elseif metric == 6
        SubsetAccuracy = SubsetAccuracyEvaluation(target,predict_target);
        Result = SubsetAccuracy;
    end
end