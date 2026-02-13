fs=2e6;
datatype='int16';          % can be int8, int16, int32 or float
eval(["tmp=",datatype,"(3);"]);
datasize=sizeof(tmp);
ref=randn(4*fs,1);
tim=[0:length(ref)-1]'/fs;
lo=exp(j*2*pi*50*tim);
sur=ref+[ref(101:end) ; ref(1:100)].*lo;
if (strcmp(datatype,'float')==0)  % round to integer values
  sur=round(sur/max(abs(sur))*(2^datasize-1));
  ref=round(ref/max(abs(ref))*(2^datasize-1));
end
f=fopen('simulation_ref.bin','wb');fwrite(f,ref,datatype);fclose(f);
f=fopen('simulation_sur.bin','wb');fwrite(f,sur,datatype);fclose(f);
