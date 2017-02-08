%dynamisk fokusering

Fs=50e6;
ts=1/Fs;
v= 1540;
ss= v*ts;   %sträcka mellan sampel
deadz=3e-3;
b= 2.45e-4; %elemnt bredd

% total sträcka= ts*v*n(elemtnnummer)+ 3e-3 där 0<n>2047


n=1; %antalet rader, dvs 1-2048
a=1; %antalet kolumner, dvs 1-64
k=1;   %dvs 1-128
%%


for n= 1:2048
    for k= 1:128 
        for a= 1:64
    if a <32
    x1= b*(32-a);
    y1=n*ts*v+deadz;
    z1=sqrt(x1^2+y1^2);
    ds1= z1+y1-2*deadz;
    dt1= (ds1)/v;
    %struct=dt1;
    A2(n,a,k)=ds1;
    A1(n,a,k) = dt1;
    
    else if a > 33
    x2= b*(a-33);
    y2=n*ts*v+deadz;
    z2=sqrt(x2^2+y2^2);
    ds2= z2+y2-2*deadz;
    dt2= ds2/v;
    %struct=dt1;
    A2(n,a,k)=ds2;
    A1(n,a,k) = dt2;
    
    end 
    end 
        end
    end
end



%%
%Dynamisk fokusering försök1
A10= A2./(v*ts);
avrundad= round(A10);




for n= 1:2048
    for k= 1:128 
        for a= 1:64
            if a <32 && 0 ~=avrundad(n,a,k)
           data=preBeamformed.Signal(avrundad(n,a,k),a,k);
            A4(n,a,k) = data;
               
                else if  0 ==avrundad(n,a,k)
                  data=preBeamformed.Signal(n,a,k);
                A4(n,a,k) = data;
                        
                 else if a > 33 && 0 ~=avrundad(n,a,k)
               data=preBeamformed.Signal(avrundad(n,a,k),a,k);
               A4(n,a,k) = data;
                     
                     
                    end
                    
                end
            end
            
        end 
    end
end

%%


[B,A] = butter(10,0.05,'high');

ThreeToTwo1d=squeeze(sum((A4),2));
%tidsf=squeeze(sum(A4),2 )
Bild22d=abs(hilbert(ThreeToTwo1d));
figure(5)
imagesc(Bild22d); colormap(gray)
title('Bild med tidsfördröjning, dvs postBeam')


figure(22)

%Högpassfilter

Y1d  = filtfilt(B,A,double(ThreeToTwo1d)); %högpassfilter" där 10 är ordningen på filtret och 0.05 betyder 5% från nykvistfrekvensen

Y51d=abs(hilbert(Y1d));
imagesc(Y51d)
colormap(gray)
%Efter filtrering kan resultatet undersökas t.ex. genom att skapa en B-mode bild genom att ta absolut
%beloppet på Hilbert Transformen:

figure(29)
Bild20d=abs(hilbert(Y1d)); %där “postbeamformed”-variabeln redan är filtrerad
imagesc(Bild20d)
colormap(gray)
title('postBeam filtrerad')


%%



%apodisering fungerande
figure(988)
 normal=normpdf(Bild22d,32,128);

 imagesc((1-normal).*Bild22d)
 colormap(gray)
 title('postBeam med apodisering')
 
%%

%aperatur
 %vill att alla element ska vara aktiva efter 10 mm och vill att antalet
 %element ska öka med djupet linjärt innan dessa 10 mm --> dvs till och med
 %rad 325
 elements=1;
 
 for n= 1:2048
    for k= 1:128 
        for a= 1:64
            if n<325
                elelemtns= round((n/2048)*64);
                Az(n,a,k)= A2(n,elements,k);
                
            else if n>325
                     Az(n,a,k)= A2(n,a,k);
                end
            end
        end
    end
 end
 
 %%
 
 %Dynamisk fokusering försök1
A100= (Az)./(v*ts);
avrundad1= (round(A100));



for n= 1:2048
    for k= 1:128 
        for a= 1:64
            if a <32 && 0 ~=avrundad1(n,a,k)
           data=preBeamformed.Signal(avrundad1(n,a,k),a,k);
            A44(n,a,k) = data;
               
                else if  0 ==avrundad1(n,a,k)
                  data=preBeamformed.Signal(n,a,k);
                A44(n,a,k) = data;
                        
                 else if a > 33 && 0 ~=avrundad1(n,a,k)
               data=preBeamformed.Signal(avrundad1(n,a,k),a,k);
               A44(n,a,k) = data;
                     
                     
                    end
                    
                end
            end
            
        end 
    end
end

%%

ThreeToTwo1d1=squeeze(sum((A44),2));
%tidsf=squeeze(sum(A4),2 )




Bild22d1=abs(hilbert(ThreeToTwo1d1));
figure(51)
imagesc(Bild22d1); colormap(gray)
title('Bild med tidsfördröjning, dvs postBeam')




figure(221)

%Högpassfilter
[B,A] = butter(10,0.05,'high');

Y1d1  = filtfilt(B,A,double(ThreeToTwo1d)); %högpassfilter" där 10 är ordningen på filtret och 0.05 betyder 5% från nykvistfrekvensen

Y51d1=abs(hilbert(Y1d1));
imagesc(Y51d1)
colormap(gray)
%Efter filtrering kan resultatet undersökas t.ex. genom att skapa en B-mode bild genom att ta absolut
%beloppet på Hilbert Transformen:

figure(291)
Bild20d1=abs(hilbert(Y1d1)); %där “postbeamformed”-variabeln redan är filtrerad
imagesc(Bild20d1)
colormap(gray)
title('postBeam filtrerad')


%apodisering fungerande
figure(988)
 normal=normpdf(Bild20d1,32,128);

 imagesc((1-normal).*Bild20d1)
 colormap(gray)
 title('postBeam med apodisering och aperatur')
 