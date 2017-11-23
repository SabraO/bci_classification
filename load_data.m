function[data] = load_data(name, ratio)
    filename = strcat(name,'.mat');
    rawData = load(filename);
    s=rawData.s;
    HDR=rawData.HDR;

    TRIG=HDR.TRIG;
    Classlabel=HDR.Classlabel;
    SampleRate=HDR.SampleRate;
    data=preProcessData(s, TRIG, Classlabel,SampleRate);
    XTrain=data.XTrain;
    YTrain=data.YTrain;
    %XTest=data.XTest; This doesnt have labels, so accuracy comparison is not possible

    data = seperateData(XTrain, YTrain, ratio);
    Xte=data.Xte;
    Xtr=data.Xtr;
    Yte=data.Yte;
    Ytr=data.Ytr;

    function data = preProcessData(s, TRIG, Classlabel,SampleRate)

        %taking only c3=28, cz=31 and c4=34 channels
        relatedS=[s(:,28),s(:,31),s(:,34)];
        [m,n] = size(relatedS);
        [p,q] = size(TRIG);

        %seperating train and test data
        testDataCount=sum(isnan(Classlabel));
        trainDataCount=p-testDataCount;

        XTest=zeros(SampleRate*4,n,testDataCount);
        XTrain=zeros(SampleRate*4,n,trainDataCount);
        YTrain=zeros(n,1);
        testCount=1;
        trainCount=1;

        for i=1:p 
           sampleWindowLower= TRIG(i,1)+SampleRate*3 +1;%triger is at t=3secs
           sampleWindowUpper= TRIG(i,1)+SampleRate*7;%trail ends at t=7secs
           singleSample = relatedS(sampleWindowLower:sampleWindowUpper,:);
           y=Classlabel(i,1);
           if isnan(y)
               XTest(:,:,testCount)=singleSample;
               testCount=testCount+1;
           else 
               XTrain(:,:,trainCount)=singleSample;
               YTrain(trainCount,1)=y;
               trainCount=trainCount+1;
           end
        end
        data.XTrain=XTrain;
        data.YTrain=YTrain;
        data.XTest=XTest;
    end
    
    %This function seperate data into two portions:
    function data = seperateData(X, Y, percentage)
        [p,q] = size(Y);
        portion=round(p*percentage);
        %seperating train and test data
        Xte=X(:,:,1:portion);
        Xtr=X(:,:,(portion+1):p);
        Yte=Y(1:portion,1);
        Ytr=Y(portion+1:p,1);
        data.Xte=Xte;
        data.Xtr=Xtr;
        data.Yte=Yte;
        data.Ytr=Ytr;
    end

end