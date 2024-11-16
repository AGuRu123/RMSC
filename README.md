# RMSC
Weak Multi-Label Data Stream Classification Under Distribution Changes in Labels

# Abstract
  Multi-label stream classification aims to address the challenge of dynamically assigning multiple labels to sequentially-arrived instances. In real situations, only partial labels of instances can be observed due to the expensive human annotations, and the problem of label distribution changes arises from multiple labels in a streaming mode, but few existing works jointly consider such challenges. Motivated by this, we propose the problem of weak multi-label stream classification (WMSC) and an online classification algorithm robust to weak labels. Specifically, we incrementally update the margin-based model using information from both the past model and the current incoming instance with partially observed labels. To increase the robustness to weak labels, we first adjust the classification margin of negative labels using the label causality matrix, which is constructed by the conditional probability of label pairs. Secondly, we introduce the label prototype matrix to regulate the margin by controlling the weighting parameter of the slack term. Additionally, to handle the potential distribution changes in labels, we utilize the instance-specific threshold via online thresholding to perform binary classification, which is formulated as a regression problem. Finally, theoretical analysis and empirical experimental results are presented to demonstrate the effectiveness of WMSC in classifying unobserved streaming instances.

# Main contributions
1. We present a novel WMSC scenario as a practical yet challenging task. In response, we propose the RMSC method, a large-margin-based approach that establishes robustness by dynamically adjusting the margin for negative example-label pairs through label causality and label prototype.     

2. We propose online thresholding to assign instance-specifc thresholds to all streaming data instances, hence RMSC also presents relatively superior performance on the DCL cases.

3. Rigorous theoretical analysis is provided by deriving loss bounds for RMSC, ensuring its generalization performance in the context of WMSC. Empirically, we conduct diverse experiments on several benchmark data sets from different domains, confrming the superiority of RMSC over other baselines in WMSC scenarios.
 
# Reference
 Y. Zou, X. Hu, P. Li, and J. Hu, “Weak multi-label data stream classification under distribution changes in labels,” IEEE Transactions on Big Data, pp. 1–12, 2024.
