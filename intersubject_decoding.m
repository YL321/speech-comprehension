% Fore more detail, please check our manuscirpt: Neural correlates of individual differences in predicting ambiguous sounds comprehension level.


clear all
close all

% defaults
n=500 ;  % how many iteration times you want to try
J=20;    % how may times you want to try  
VGsubject={'subject15','subject6','subject4','subject14','subject23','subject17','subject18','subject21','subject26','subject13','subject20','subject19','subject3', 'subject8','subject27','subject12','subject11','subject22','subject7','subject16'};
VBsubject={'subject1','subject10','subject2','subject9','subject5','subject25'};
List=[VGsubject VBsubject];

VGlabel=string('VG'); 
VGlabel1=repmat(VGlabel,1,5);
VGlabel2=repmat(VGlabel,1,1);
VBlabel=string('VB'); 
VBlabel1=repmat(VBlabel,1,5);
VBlabel2=repmat(VBlabel,1,1);

%decide which contrastyou want 
contrast1 = input('contrast:(1.vocoded_inverted 2.vocoded_clear 3.clear_inverted)  ')' ;
if contrast1==1
  contrast='vocoded_inverted'; 
elseif  contrast1==2 
    contrast='vocoded_clear';
elseif  contrast1==3
    contrast='clear_inverted';  
end
study_path=fullfile(sprintf('%s%s','THE DATA PATH',contrast));


for m=1:12
roi1=m;
if       roi1==1
      roi='L_AnG';
elseif   roi1==2 
     roi='L_OpIFG';
elseif   roi1==3 
      roi='L_OrIFG';
elseif   roi1==4 
      roi='L_TrIFG';   
elseif   roi1==5 
     roi='L_STG';
elseif   roi1==6 
     roi='L_SMG';
elseif   roi1==7 
     roi='R_AnG';
elseif   roi1==8 
     roi='R_OpIFG';
elseif   roi1==9 
     roi='R_OrIFG';
elseif   roi1==10 
     roi='R_TrIFG';
elseif   roi1==11 
     roi='R_STG';
elseif   roi1==12 
     roi='R_SMG';
end


HeaderInfo1= spm_vol(sprintf('%s%s%s','ROI PATH',roi,'.nii'));
V1= spm_read_vols(HeaderInfo1);
% renew the variable for the new roi information 
D=[];
ka=[];
DD=[];
KD=[];
KDA=[];
KDB=[];
KDC=[];
KDD=[];

for i=1:length(List)
HeaderInfo2=spm_vol(fullfile(study_path,List{i},'BRAIN DATA'));
V2(:,:,:)= spm_read_vols(HeaderInfo2);

  D=V1.*V2;
  D(isnan(D)==1)= 0;
  ka=find(D);
  DD=D(ka);
  KD(i,:)=mean(DD');
end

KDA=KD(1:6);
KDB=KD(7:12);
KDC=KD(13:20);
KDD=KD(21:26);


for k=1:J % J= 20 
 A=(1:6);

  for i3=1:n 
rand('seed',sum(100*clock));
ListA= randperm(6);
ListB= randperm(6);
ListC= randperm(8);
ListD= randperm(6);


     
% renew for evertime
A1=A;


huge_chuck=[KDA(ListA(1:2));KDB(ListB(1:2));KDC(ListC(1:2))]; 
 
 
% select the test datasets
if mod(i3,6)==1
    testframe.stimuli(i3,1)= huge_chuck(1);
     A1(A(1))=[];
    trainingframe.stimuli(i3,1:5)=[huge_chuck(A1')]'; 
    poor=KDD(ListD);
    testframe.stimuli(i3,2)= poor(1);
    trainingframe.stimuli(i3,6:10)=poor(2:6)'; 
   
elseif mod(i3,6)==2
    testframe.stimuli(i3,1)= huge_chuck(2);
    A1(A(2))=[];
    trainingframe.stimuli(i3,1:5)=[huge_chuck(A1')]'; 
    poor=KDD(ListD);
    testframe.stimuli(i3,2)= poor(1);
    trainingframe.stimuli(i3,6:10)=poor(2:6)'; 
    
 elseif mod(i3,6)==3
    testframe.stimuli(i3,1)= huge_chuck(3);
    A1(A(3))=[];
    trainingframe.stimuli(i3,1:5)=[huge_chuck(A1')]'; 
        poor=KDD(ListD);
    testframe.stimuli(i3,2)= poor(1);
    trainingframe.stimuli(i3,6:10)=poor(2:6)'; 
 
  elseif mod(i3,6)==4
    testframe.stimuli(i3,1)= huge_chuck(4);
    A1(A(4))=[];
    trainingframe.stimuli(i3,1:5)=[huge_chuck(A1')]';    
        poor=KDD(ListD);
    testframe.stimuli(i3,2)= poor(1);
    trainingframe.stimuli(i3,6:10)=poor(2:6)'; 
    
   elseif mod(i3,6)==5
    testframe.stimuli(i3,1)= huge_chuck(5);
    A1(A(5))=[];
    trainingframe.stimuli(i3,1:5)=[huge_chuck(A1')]';   
        poor=KDD(ListD);
    testframe.stimuli(i3,2)= poor(1);
    trainingframe.stimuli(i3,6:10)=poor(2:6)'; 
    
    
     elseif mod(i3,6)==0
    testframe.stimuli(i3,1)= huge_chuck(6);
    A1(A(6))=[];
    trainingframe.stimuli(i3,1:5)=[huge_chuck(A1')]'; 
    poor=KDD(ListD);
    testframe.stimuli(i3,2)= poor(1);
    trainingframe.stimuli(i3,6:10)=poor(2:6)'; 
    
end


trainingframe.label(i3,:)=[VGlabel1 VBlabel1];

testframe.label(i3,:)= [VGlabel2 VBlabel2];




end

for i4=1:n 
    % Train the model first
    Mdl = fitcecoc(trainingframe.stimuli(i4,:)',trainingframe.label(i4,:));
    
    % Test the model 
    result(i4,:) = predict(Mdl,testframe.stimuli(i4,:)')';
    
    % Caculate the acc rate (for four group)
    acc(i4)= sum(result(i4,:)==testframe.label(i4,:))/2;
    
end  
% save the result
fname=sprintf('%s_%d_result',roi,k);
save(fname,'result');
fname2=sprintf('%s_%d_acc',roi,k);
save(fname2,'acc');


Finally_acc=sum(acc)/n;
sd      = std(acc);
CI_upp(k)  = (sum(acc)/n+(1.96*std(acc))/sqrt(n) );
CI_bot(k)  = (sum(acc)/n-(1.96*std(acc))/sqrt(n)) ; 

% based on the value, plot the result (all ROIs in one figure)
figure(1)
% vertical line
xlim([0 12])
ylim([0 1])

line([1+0.8*(m-1) 1+0.8*(m-1)], [CI_bot(k) CI_upp(k)],'color','k');
hold on
%horizontal line;
line([0.8+0.8*(m-1) 1.2+0.8*(m-1)], [CI_upp(k) CI_upp(k)],'color','k');
hold on
line([0.8+0.8*(m-1) 1.2+0.8*(m-1)], [CI_bot(k) CI_bot(k)],'color','k');
hold on 


end

end


% draw the reference line
figure(1)
line([0 12], [0.5 0.5],'color','red','linestyle','--','LineWidth',3);
