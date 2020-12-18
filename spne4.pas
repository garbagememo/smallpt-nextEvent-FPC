program smallpt;
{$MODE objfpc}
{$INLINE ON}

uses SysUtils,Classes,uVect,WriteBMP,Math,uModel;



var
  DF:boolean;//debug
  DebugInt:integer;
  Debugx,DebugY,StartY:integer;

function intersect(const r:RayRecord;var t:real; var id:integer):boolean;
var
  n,d:real;
  i:integer;
BEGIN
  t:=INF;
  for i:=0 to sph.count-1 do BEGIN
    d:=SphereClass(sph[i]).intersect(r);
    IF d<t THEN BEGIN
      t:=d;
      id:=i;
    END;
  END;
  result:=(t<inf);
END;


function radiance(const r:RayRecord;depth:integer;E:integer):VecRecord;
var
  id,i,tid:integer;
  obj,s:SphereClass;
  x,n,f,nl,u,v,w,d:VecRecord;
  p,r1,r2,r2s,t:real;
  into:boolean;
  RefRay:RayRecord;
  nc,nt,nnt,ddn,cos2t,q,a,b,c,R0,Re,RP,Tr,TP:real;
  tDir:VecRecord;
  EL,sw,su,sv,l:VecRecord;
  cos_a_max,eps1,eps2,eps2s,cos_a,sin_a,phi,omega:real;
BEGIN
  id:=0;depth:=depth+1;
  IF intersect(r,t,id)=FALSE THEN BEGIN
    result:=ZeroVec;exit;
  END;
  obj:=SphereClass(sph[id]);
  x:=r.o+r.d*t; n:=VecNorm(x-obj.p); f:=obj.c;
  IF n*r.d<0 THEN nl:=n ELSE nl:=n*-1;

  IF (f.x>f.y)and(f.x>f.z) THEN
    p:=f.x
  ELSE IF f.y>f.z THEN
    p:=f.y
  ELSE
    p:=f.z;
  IF (depth>5) THEN BEGIN
    IF random<p THEN
      f:=f/p
    ELSE BEGIN
      result:=obj.e*E;
      exit;
    END;
  END;
  CASE obj.refl OF
    DIFF:BEGIN
      x:=x+nl*eps;(*ad hoc 突き抜け防止*)
      r1:=2*PI*random;r2:=random;r2s:=sqrt(r2);
      w:=nl;
      IF abs(w.x)>0.1 THEN
        u:=VecNorm(CreateVec(0,1,0)/w)
      ELSE BEGIN
        u:=VecNorm(CreateVec(1,0,0)/w );
      END;
      v:=w/u;
      d := VecNorm(u*cos(r1)*r2s + v*sin(r1)*r2s + w*sqrt(1-r2));

    // Loop over any lights
      EL:=ZeroVec;
      tid:=id;
      for i:=0 to sph.count-1 do BEGIN
        s:=SphereClass(sph[i]);
        IF (i=tid) THEN BEGIN
          continue;
        END;
        IF (s.e.x<=0) and  (s.e.y<=0) and (s.e.z<=0)  THEN continue; // skip non-lights
        sw:=s.p-x;
        IF abs(sw.x)>0.1 THEN su:=VecNorm(CreateVec(0,1,0)/sw) ELSE su:=VecNorm(CreateVec(1,0,0)/sw);
        sv:=sw/su;
        tr:=(x-s.p)*(x-s.p);  tr:=s.rad*s.rad/tr;
        IF tr>1 THEN BEGIN
          (*半球の内外=cos_aがマイナスとsin_aが＋、－で場合分け*)
          (*半球内部なら乱反射した寄与全てを取ればよい・・はず*)
          eps1:=2*pi*random;eps2:=random;eps2s:=sqrt(eps2);
          l:=VecNorm(u*cos(eps1)*eps2s + v*sin(eps1)*eps2s + w*sqrt(1-eps2));
          IF intersect(CreateRay(x,l),t,id) THEN BEGIN
            IF id=i THEN BEGIN
              tr:=l*nl;
              EL:=EL+VecMul(f,s.e*tr);
            END;
          END;
          CONTINUE;
        END;
        cos_a_max := sqrt(1-tr );
        eps1 := random; eps2:=random;
        cos_a := 1-eps1+eps1*cos_a_max;
        sin_a := sqrt(1-cos_a*cos_a);
        IF (1-2*random)<0 THEN sin_a:=-sin_a; 
        phi := 2*PI*eps2;
        l := su*cos(phi)*sin_a + sv*sin(phi)*sin_a + sw*cos_a;
        l:=VecNorm(l);
        IF (intersect(CreateRay(x,l), t, id) ) THEN BEGIN 
         IF id=i THEN BEGIN  // shadow ray
           omega := 2*PI*(1-cos_a_max);
           tr:=l*nl;
           IF tr<0 THEN tr:=0;
//       e = e + f.mult(s.e*tr*omega)*M_1_PI;  // 1/pi for brdf
            EL := EL + VecMul(f,s.e*tr*omega)*M_1_PI;  // 1/pi for brdf
          END;
        END;
      END;(*for*)
      result:= obj.e*E+EL+VecMul(f,radiance(CreateRay(x,d),depth,0));
    END;(*DIFF*)
    SPEC:BEGIN
      result:=obj.e+VecMul(f,(radiance(CreateRay(x,r.d-n*2*(n*r.d) ),depth,1)));
    END;(*SPEC*)
    REFR:BEGIN
      RefRay:=CreateRay(x,r.d-n*2*(n*r.d) );
      into:= (n*nl>0);
      nc:=1;nt:=1.5; IF into THEN nnt:=nc/nt ELSE nnt:=nt/nc; ddn:=r.d*nl;
      cos2t:=1-nnt*nnt*(1-ddn*ddn);
      IF cos2t<0 THEN BEGIN   // Total internal reflection
        result:=obj.e + VecMul(f,radiance(RefRay,depth,1));
        exit;
      END;
      IF into THEN q:=1 ELSE q:=-1;
      tdir := VecNorm(r.d*nnt - n*(q*(ddn*nnt+sqrt(cos2t))));
      IF into THEN Q:=-ddn ELSE Q:=tdir*n;
      a:=nt-nc; b:=nt+nc; R0:=a*a/(b*b); c := 1-Q;
      Re:=R0+(1-R0)*c*c*c*c*c;Tr:=1-Re;P:=0.25+0.5*Re;RP:=Re/P;TP:=Tr/(1-P);
      IF depth>2 THEN BEGIN
        IF random<p THEN // 反射
          result:=obj.e+VecMul(f,radiance(RefRay,depth,1)*RP)
        ELSE //屈折
          result:=obj.e+VecMul(f,radiance(CreateRay(x,tdir),depth,1)*TP);
      END
      ELSE BEGIN// 屈折と反射の両方を追跡
        result:=obj.e+VecMul(f,radiance(RefRay,depth,1)*Re+radiance(CreateRay(x,tdir),depth,1)*Tr);
      END;
    END;(*REFR*)
  END;(*CASE*)
END;


VAR
  x,y,sx,sy,i,s: INTEGER;
  w,h,samps,height    : INTEGER;
  temp,d       : VecRecord;
  r1,r2,dx,dy  : real;
  cam,tempRay  : RayRecord;
  cx,cy: VecRecord;
  tColor,r,camPosition,camDirection : VecRecord;

  BMPClass:BMPIOClass;
  ScrWidth,ScrHeight:integer;
  vColor:rgbColor;
  FN:string;
  T1,T2:TDateTime;
  HH,MM,SS,MS:WORD;
BEGIN
//DEBUG
  DF:=FALSE;
  DebugInt:=0;

  FN:=ExtractFileName(paramStr(0));
  Delete(FN,Length(FN)-3,4);
  FN:=FN+'.bmp';

  randomize;
  w:=320 ;h:=240;  samps := 16;
  height:=h;
  BMPClass:=BMPIOClass.Create(w,h);

//----Scene Setup----
  InitScene;
  sph:=CopyScene(1);

  camPosition:=CreateVec(50, 52, 295.6);  camDirection:=VecNorm(CreateVec(0,-0.042612,-1) );
  cam:=CreateRay(camPosition, camDirection);
  cx:=CreateVec(w * 0.5135 / h, 0, 0);
  cy:= cx/ cam.d;
  cy:=VecNorm(cy);
  cy:= cy* 0.5135;

  ScrWidth:=0;
  ScrHeight:=0;
  T1:=Time;
  Writeln ('The time is : ',TimeToStr(Time));

StartY:=60;
  FOR y := 0 to h-1 DO BEGIN
DebugY:=y;
    IF y mod 10 =0 THEN writeln('y=',y);
    FOR x := 0 TO w - 1 DO BEGIN
DebugX:=X;
      r:=CreateVec(0, 0, 0);
      tColor:=ZeroVec;
      FOR sy := 0 TO 1 DO BEGIN
        FOR sx := 0 TO 1 DO BEGIN
          FOR s := 0 TO samps - 1 DO BEGIN
            r1 := 2 * random;
            IF (r1 < 1) THEN
              dx := sqrt(r1) - 1
            ELSE
              dx := 1 - sqrt(2 - r1);

            r2 := 2 * random;
            IF (r2 < 1) THEN
              dy := sqrt(r2) - 1
            ELSE
              dy := 1 - sqrt(2 - r2);
            temp:= cx* (((sx + 0.5 + dx) / 2 + x) / w - 0.5);
            d:= cy* (((sy + 0.5 + dy) / 2 + (h - y - 1)) / h - 0.5);
            d:= d +temp;
            d:= d +cam.d;

            d:=VecNorm(d);
            tempRay.o:= d* 140;
            tempRay.o:= tempRay.o+ cam.o;
            tempRay.d := d;

            temp:=Radiance(tempRay, 0 ,1);
            temp:= temp/ samps;
            r:= r+temp;
          END;(*samps*)
          temp:= r* 0.24;
          tColor:=tColor+ temp;
          r:=CreateVec(0, 0, 0);
        END;(*sx*)
      END;(*sy*)
      vColor:=ColToRGB(tColor);
      BMPClass.SetPixel(x,height-y,vColor);
    END;(* for x *)
  END;(*for y*)
  T2:=Time-T1;
  DecodeTime(T2,HH,MM,SS,MS);
  Writeln ('The time is : ',HH,'h:',MM,'min:',SS,'sec');
  BMPClass.WriteBMPFile(FN);
  writeln('DebugInt=',DebugInt);
END.
