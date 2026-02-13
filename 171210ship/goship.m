pkg load signal
save_picts=1;             % set to 1 to save output images
% f=fopen('ship4char_mountain.bin','rb');
% simulation=1;
if exist('simulation')
  f1=fopen('simulation_ref.bin','rb');
  f2=fopen('simulation_sur.bin','rb');
else
  f1=fopen('171210ship_ch1.sigmf-data','rb');
  f2=fopen('171210ship_ch2.sigmf-data','rb');
end
datatype='int8';          % can be int8, int16, int32 or float
p=1;
fs=2.048e6;               % sampling frequency
dN=512;                   % correlation range search
N=fs;                     % 0.5 second worth of data
tim=[0:(N/2-1)]'/fs;      % discretized time
freq=[-200:4:200];        % Doppler shift
dsi_suppression=0         % option to activate Direct Signal Interference removal

if (dsi_suppression==1)
  scf=0.05;               % colormap scale factor
else
  scf=0.01;
end

t=fread(f1,N,datatype);
ref=t(1:2:end)+j*t(2:2:end);

t=fread(f2,N,datatype);
mes=t(1:2:end)+j*t(2:2:end);

xc=abs(xcorr(ref,mes));   % measure time offsets between RTL-SDR receivers (USB bus delay)
[val,pos]=max(xc);
pos=length(ref)-pos       % position max wrt cross-correlation origin

if (pos>0)                % which channel is reference and which is measurement?
    mes=mes(pos:end);
    ref=ref(1:end-pos);
    xc=abs(xcorr(ref,mes));
    [val,posn]=max(xc);
    length(ref)-posn      % chech that xcorr max position is @ 0
    tim=tim(1:end-pos+1);
else
    ref=ref(-pos+1:end);  % +1 in case pos==0 (for B210)
    mes=mes(1:end+pos);
    xc=abs(xcorr(ref,mes));
    [val,posn]=max(xc);
    length(ref)-posn      % chech that xcorr max position is @ 0
    tim=tim(1:end+pos);
end

fseek(f1,1008*N);         % skip beginning lacking interesting targets
fseek(f2,1008*N);
%for k=1:1008
%  t=fread(f1,[2, N/2],'char');
%  t=fread(f2,[2, N/2],'char');
%  p=p+1
%end

%if (pos>0)               % align by reading from the appropriate file
%   fread(f2,abs(pos)*2,datatype);
%else
%   fread(f1,abs(pos)*2,datatype);
%end

filesize=stat(f1).size;
eval(["tmp=",datatype,"(3)"]);
datasize=sizeof(tmp);
for k=1:N:filesize/datasize/2 % 19227738112/4
  p
  t=fread(f1,N,datatype);
  ref=t(1:2:end)+j*t(2:2:end);

  t=fread(f2,N,datatype);
  mes=t(1:2:end)+j*t(2:2:end);

  if (pos>0)              % align
     mes=mes(pos:end);
     ref=ref(1:end-pos+1);
  else
     ref=ref(-pos+1:end);
     mes=mes(1:end+pos);
  end
  if (p==1)
    figure
    plot(([-length(ref)+1:length(ref)-1])*3E8/fs/1000,abs(xcorr(ref,mes)))
    xlim([-20 20]);xlabel('range (km)');ylabel('xcorr (a.u.)');text(10,6e8,'future');text(-10,6e8,'past');
    figure
  end

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
      mes=mes-X1*(pinv(X1)*mes); % Least Square optimization
      clear X1;
  end

  m=1;
  for fd=freq
     mesdop=mes.*exp(j*2*pi*fd*tim);
     x=abs(xcorr(ref,mesdop,dN));
     rangedop(:,m)=x(dN-15:dN+150);
     m=m+1;
  end          % vvv flipud => reverse Y axis wrt rangedop
  imagesc(freq,([-150:+15]+1)*3e8/fs/2/1000,fliplr(flipud(rangedop)),[0 scf*max(max(rangedop))]);
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
