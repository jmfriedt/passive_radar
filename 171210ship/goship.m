pkg load signal
save_picts=0;             % set to 1 to save output images
f=fopen('ship8.bin','rb');
p=1;
fs=2.048e6;               % sampling frequency
N=fs;                     % 1 second worth of data
tim=[0:1/fs:(N/2-1)/fs]'; % discretized time
freq=[-200:4:200];        % Doppler shift

t=fread(f,[2, N],'float');
v=t(1,:)+t(2,:)*i;
[r,c]=size(v);
v=reshape(v,c,r);
ref=v(1:2:end);
mes=v(2:2:end);
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

%for k=1:906              % get rid of beginning of file (if needed)
%  t=fread(f,[2, N],'float');
%  p=p+1
%end

for k=1:N:23035117568/4
  p
  t=fread(f,[2, N],'float');
  v=t(1,:)+t(2,:)*i;
  [r,c]=size(v);
  v=reshape(v,c,r);
  ref=v(1:2:end);
  mes=v(2:2:end);
  %t=fread(f,[4, N],'float')';
  %ref=t(:,3);
  %mes=t(:,4);
  if (pos>0)
     mes=mes(pos:end);
     ref=ref(1:end-pos+1);
  else
     ref=ref(-pos:end);
     mes=mes(1:end+pos+1);
  end
  m=1;
  for fd=freq
     mesdop=mes.*exp(j*2*pi*fd*tim);
     x=abs(xcorr(ref,mesdop,2048));
     rangedop(:,m)=x(2048-20:2048+150-20);
     m=m+1;
  end
  imagesc(freq,([-20:+150-20])*3e8/fs/2/1000,rangedop,[0 0.01*max(max(rangedop))]);
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
  pause(0.1)
  p=p+1;
end
% r=linspace(0,67/2.048*300/2,67)
% xx=x(2048+160:2048+226,:);
r=linspace(0,157/2.048*300/2,157)
xx=x(2048+450:2048+606,:);
