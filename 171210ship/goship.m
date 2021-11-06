pkg load signal
save_picts=1;             % set to 1 to save output images
f=fopen('ship7float_beach.bin','rb');
p=1;
fs=2.048e6;               % sampling frequency
N=fs;                     % 1 second worth of data
tim=[0:1/fs:(N/2-1)/fs]'; % discretized time
freq=[-200:4:200];        % Doppler shift
dsi_suppression=1         % option to activate Direct Signal Interference removal

t=fread(f,[2, N],'float');
v=t(1,:)+t(2,:)*i;
[r,c]=size(v);
v=reshape(v,c,r);
mes=v(1:2:end);
ref=v(2:2:end);
xc=abs(xcorr(ref,mes));   % search for correlation peak delay induced by USB communication
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

%for k=1:906              % get rid of beginning of file (if needed)
%  t=fread(f,[2, N],'float');
%  p=p+1
%end

for k=1:N:1e9             % read the whole file way beyond the end
  p
  t=fread(f,[2, N],'float');
  v=t(1,:)+t(2,:)*i;
  [r,c]=size(v);
  v=reshape(v,c,r);
  mes=v(1:2:end);
  ref=v(2:2:end);
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

  for fd=freq
     mesdop=mes.*exp(j*2*pi*fd*tim);
     x=abs(xcorr(ref,mesdop,2048));
     rangedop(:,m)=x(2048-20-150:2048+20);
     %rangedop(:,m)=x(2048-150-20:2048-20);
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
    name=[num2str(p,'%04d'),'_dsi_2.png'];
    eval(['print -dpng ',name]);
%    name=[num2str(p,'%04d'),'_2.mat'];
%    eval(['save ',name,' rangedop']);
  end
  pause(0.1)
  p=p+1;
end
% r=linspace(0,67/2.048*300/2,67)
% xx=x(2048+160:2048+226,:);
r=linspace(0,157/2.048*300/2,157)
xx=x(2048+450:2048+606,:);
