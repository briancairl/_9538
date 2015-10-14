clear
clc
n_retrieved     = 5;
result_names    = ...
{...
    'models',...
    'low_noise_models',...
    'med_noise_models',...
    'high_noise_models',...
    'low_incomplete_models',...
    'med_incomplete_models',...
    'high_incomplete_models'...
};

results = cell(numel(result_names),1);

for idx = 1:numel(result_names)
    truth           = [];
    pred            = [];
    results{idx}    = load(sprintf('match_results/%s_results.mat',result_names{idx}));
    N_trials        = size(results{idx}.classification_data,1);
    N_retrievals    = size(results{idx}.classification_data,2)-1;
    
    for jdx = 1:N_trials
        ii  = tosca_index_dict(results{idx}.classification_data{jdx,1});
        for kdx = 1:N_retrievals
            jj  = tosca_index_dict(results{idx}.classification_data{jdx,kdx+1});
            truth(end+1) = ii;
            pred(end+1)  = jj;
        end
    end
    
    [Xpr,Ypr,Tpr,AUCpr] = perfcurve(pred, truth, 1, 'xCrit', 'reca', 'yCrit', 'prec');
    plot(Xpr,Ypr)
    input('')
end