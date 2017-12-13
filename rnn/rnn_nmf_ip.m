rng(1); % For reproducability

lowerFr=2;
upperFr=30;
iterations_1=500;
iterations_2=500;
basis_vecs=70;

data = load_data('k3b',0.4, 1, 0);
xtr = data.Xtr;
ytr = data.Ytr;
yc = categorical(ytr);

xte = data.Xte;
yte = data.Yte;

%Mu = 3-7, lowerFr=6Hz upperFr=14Hz,  Mu+Beta = 3-15,lowerFr=6Hz upperFr=30Hz
%Only set numbers which are divisible by 2
%str = abs(dostft(xtr, 128, 64, 'hann', lowerFr, upperFr));
%ste = abs(dostft(xte, 128, 64, 'hann', lowerFr, upperFr));

[h_tr, h_te] = nmf(xtr, xte, basis_vecs, iterations_1, iterations_2, lowerFr, upperFr);

tr_trails = size(xtr,3);
sTr = h_tr';
xc = cell(tr_trails,1); % Cell vector of 3 channels each with 1000 frames
for i = 1:tr_trails
    xc(i) = {reshape(sTr(i,:),[70, 1])};
end

inputSize = 70;
outputSize = 150;
outputMode = 'last';
numClasses = 4;
miniBatchSize = 10;

layers = [ ...
    sequenceInputLayer(inputSize)
    lstmLayer(outputSize,'OutputMode',outputMode)
    lstmLayer(outputSize,'OutputMode',outputMode)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer];

maxEpochs = 1500;
shuffle = 'never';

options = trainingOptions('sgdm', ...
    'MaxEpochs',maxEpochs, ...
    'Shuffle', shuffle, ...
    'MiniBatchSize',miniBatchSize, ...
    'Plots','training-progress');

net = trainNetwork(xc,yc,layers,options);

te_trails = size(xte,3);
sTe = h_te';
xtec = cell(te_trails,1);
for i = 1:te_trails
    xtec(i) = {reshape(sTe(i,:),[70, 1])};
end

Ytec = categorical(yte);
YPred = classify(net,xtec);

acc = (nnz(YPred == Ytec)/numel(Ytec))*100;
disp(acc);