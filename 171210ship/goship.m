pkg load signal
save_picts=0;             % set to 1 to save output images
% f=fopen('ship4char_mountain.bin','rb');
f1=fopen('171210ship_ch1.sigmf-data','rb');
f2=fopen('171210ship_ch2.sigmf-data','rb');
p=1;
fs=2.048e6;               % sampling frequency
N=fs;                     % 1 second worth of data
tim=[0:1/fs:(N/2-1)/fs]'; % discretized time
freq=[-200:4:200];        % Doppler shift
dsi_suppression=0         % option to activate Direct Signal Interference removal

t=fread(f1,[2, N/2],'char');
v=t(1,:)+t(2,:)*i;
[r,c]=size(v);
ref=reshape(v,c,r);

t=fread(f2,[2, N/2],'char');
v=t(1,:)+t(2,:)*i;
[r,c]=size(v);
mes=reshape(v,c,r);

xc=abs(xcorr(ref,mes));
[val,pos]=max(xc);
pos=length(ref)-pos

if (pos>0)                % which channel is reference and which is measurement?
    mes=mes(pos:end);
    ref=ref(1:end-pos);
    xc=abs(xcorr(ref,mes));
    [val,posn]=max(xc);
    length(ref)-posn
    tim=tim(1:end-pos+1);
else
    ref=ref(-pos:end);
    mes=mes(1:end+pos);
    xc=abs(xcorr(ref,mes));
    [val,posn]=max(xc);
    length(ref)-posn
    tim=tim(1:end+pos+1);
end

for k=1:1008
  t=fread(f1,[2, N/2],'char');
  t=fread(f2,[2, N/2],'char');
  p=p+1
end

for k=1:N:19227738112/4
  p
  t=fread(f1,[2, N/2],'char');
  v=t(1,:)+t(2,:)*i;
  [r,c]=size(v);
  ref=reshape(v,c,r);

  t=fread(f2,[2, N/2],'char');
  v=t(1,:)+t(2,:)*i;
  [r,c]=size(v);
  mes=reshape(v,c,r);

  if (pos>0)              % align
     mes=mes(pos:end);
     ref=ref(1:end-pos+1);
  else
     ref=ref(-pos:end);
     mes=mes(1:end+pos+1);
  end
  m=1;

  if (dsi_suppression==1)
      nt=length(ref);
      %% DSI suppression -- algorithm implementation provided by W. Feng (X'ian, China)
      % Range shift
      Index1=-9;Index2=+9;  % negative range if doubts about ref v.s meas
      num_range_shift=(Index2-Index1+1);
      X1=zeros(nt,num_range_shift);
      for kk=Index1:Index2
          te=kk+abs(Index1)+1;
          if kk<=0
              X1(:,te)=[ref(0-kk+1:end);zeros(0-kk,1)];
          else
              X1(:,te)=[zeros(kk-1,1);ref(1:end-kk+1)];
          end
      end
      % Least Square optimization
      mes=mes-X1*(pinv(X1)*mes);
      clear X1;
  end

  m=1;
  for fd=freq
     mesdop=mes.*exp(j*2*pi*fd*tim);
     x=abs(xcorr(ref,mesdop,2048));
     rangedop(:,m)=x(2048-20:2048+150-20);
     m=m+1;
  end
  if (dsi_suppression==1)
    imagesc(freq,([-20:+150+20])*3e8/fs/2/1000,fliplr(flipud(rangedop)),[0 0.05*max(max(rangedop))]);
  else
    imagesc(freq,([-20:+150+20])*3e8/fs/2/1000,fliplr(flipud(rangedop)),[0 0.01*max(max(rangedop))]);
  end
  xlabel('Doppler shift (Hz)')
  ylabel('range (km)')
  temps=p/2;
  colorbar
  title([num2str(temps),' s'])     
  if (save_picts==1)
    name=[num2str(p,'%04d'),'_2.png'];
    eval(['print -dpng ',name]);
    name=[num2str(p,'%04d'),'_2.mat'];
    eval(['save ',name,' rangedop']);
  end
  p=p+1;
end
% r=linspace(0,67/2.048*300/2,67)
% xx=x(2048+160:2048+226,:);
r=linspace(0,157/2.048*300/2,157)
xx=x(2048+450:2048+606,:);
