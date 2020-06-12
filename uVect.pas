UNIT uVect;
{$MODE objfpc}
{$INLINE ON}

INTERFACE

USES
    sysutils,WriteBMP,math;
TYPE
    RefType=(DIFF,SPEC,REFR);// material types, used in radiance()
{
	DIFFUSE,    // 完全拡散面。いわゆるLambertian面。
	SPECULAR,   // 理想的な鏡面。
	REFRACTION, // 理想的なガラス的物質。
}
    VecRecord=Record
        x,y,z:real;
    end;
    RayRecord=Record
       o, d:VecRecord;
     end;
   function CreateRay(o_,d_:VecRecord):RayRecord;

   function ClampVector(v:VecRecord):VecRecord;
   function ColToRGB(v:VecRecord):rgbColor;
const
   BackGroundColor:VecRecord = (x:0;y:0;z:0);
   ZeroVec:VecRecord = (x:0;y:0;z:0);
   
function CreateVec(x_,y_,z_:real):VecRecord;
FUNCTION VecMul(const V1,V2:VecRecord):VecRecord;inline;
FUNCTION VecNeg(V:VecRecord):VecRecord;
FUNCTION Veclen(V:VecRecord):real;inline;
FUNCTION VecNorm(V:VecRecord):VecRecord;inline;
FUNCTION VecDot(const V1,V2 :VecRecord):real;//内積
FUNCTION VecCross(const V1,V2 :VecRecord):VecRecord;//外積
FUNCTION VecAdd3(V1,V2,V3:VecRecord):VecRecord;
procedure VecWriteln(V:VecRecord);
function FtoSF(r:real):string;

operator * (const v1:VecRecord;const r:real)v:VecRecord;inline;
operator / (const v1:VecRecord;const r:real)v:VecRecord;inline;
operator * (const v1,v2:VecRecord)r:real;inline;//内積
operator / (const v1,v2:VecRecord)v:VecRecord;inline;//外積

operator + (const v1,v2:VecRecord)v:VecRecord;inline;
operator - (const v1,v2:VecRecord)v:VecRecord;inline;
operator + (const v1:VecRecord;const r:real)v:VecRecord;inline;
operator - (const v1:VecRecord;const r:real)v:VecRecord;inline;

IMPLEMENTATION

function CreateVec(x_,y_,z_:real):VecRecord;
BEGIN
    result.x:=x_;result.y:=y_;result.z:=z_;
END;
function CreateRay(o_,d_:VecRecord):RayRecord;
begin
    result.o:=o_;
    result.d:=d_;
end;

FUNCTION VecMul(const V1,V2:VecRecord):VecRecord;inline;
BEGIN
    result.x:=V1.x*V2.x;
    result.y:=V1.y*V2.y;
    result.z:=V1.z*V2.z;
END;

FUNCTION VecNeg(V:VecRecord):VecRecord;
BEGIN
    result.x:=-V.x;
    result.y:=-V.y;
    result.z:=-V.z;
END;
FUNCTION Veclen(V:VecRecord):real;inline;
BEGIN
   result:=sqrt(V.x*V.x+V.y*V.y+V.z*V.z);
END;

FUNCTION VecNorm(V:VecRecord):VecRecord;inline;
BEGIN
    result:=V/VecLen(V) ;
END;
FUNCTION VecDot(const V1,V2 :VecRecord):real;//内積
BEGIN
    result:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;
END;
FUNCTION VecCross(const V1,V2 :VecRecord):VecRecord;//外積
BEGIN
    result.x:=V1.y * v2.z - v2.y * V1.z;
    result.y:=V1.z * v2.x - v2.z * V1.x;
    result.z:=V1.x * v2.y - v2.x * V1.y;
END;
FUNCTION VecAdd3(V1,V2,V3:VecRecord):VecRecord;
BEGIN
    result.x:=V1.x+V2.x+V3.x;
    result.y:=V1.y+V2.y+V3.y;
    result.z:=V1.z+V2.z+V3.z;
    
END;

function FtoSF(r:real):string;
var
  i,j:LongInt;
begin
  i:=5;j:=5;
  result:=FloatToStrf(r,ffFixed,I,J);
end;

procedure VecWriteln(V:VecRecord);
begin
    Writeln(FtoSF(v.x),' : ',FtoSF(v.y),' : ',FtoSF(v.z));
end;


operator * (const v1:VecRecord;const r:real)v:VecRecord;inline;
begin
   v.x:=v1.x*r;
   v.y:=v1.y*r;
   v.z:=v1.z*r;
end;

operator / (const v1:VecRecord;const r:real)v:VecRecord;inline;
begin
   v.x:=v1.x/r;
   v.y:=v1.y/r;
   v.z:=v1.z/r;
end;

operator * (const v1,v2:VecRecord)r:real;inline;//内積
begin
   r:=v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;
end;

operator / (const v1,v2:VecRecord)v:VecRecord;inline; //外積
begin
    v.x:=V1.y * v2.z - v2.y * V1.z;
    v.y:=V1.z * v2.x - v2.z * V1.x;
    v.z:=V1.x * v2.y - v2.x * V1.y;
end;

operator + (const v1,v2:VecRecord)v:VecRecord;inline;
begin
   v.x:=v1.x+v2.x;
   v.y:=v1.y+v2.y;
   v.z:=v1.z+v2.z;
end;

operator - (const v1,v2:VecRecord)v:VecRecord;inline;
begin
    v.x:=v1.x-v2.x;
    v.y:=v1.y-v2.y;
    v.z:=v1.z-v2.z;
end;

operator + (const v1:VecRecord;const r:real)v:VecRecord;inline;
begin
   v.x:=v1.x+r;
   v.y:=v1.y+r;
   v.z:=v1.z+r;
end;
operator - (const v1:VecRecord;const r:real)v:VecRecord;inline;
begin
    v.x:=v1.x-r;
    v.y:=v1.y-r;
    v.z:=v1.z-r;
end;


function Clamp(x:real):real;inline;
begin
   IF x<0 then exit(0);
   IF x>1 then exit(1);
   exit(x);
end;

function ClampVector(v:VecRecord):VecRecord;
begin
  result.x:=clamp(v.x);
  result.y:=clamp(v.y);
  result.z:=clamp(v.z);
end;
function ColToByte(x:real):byte;inline;
begin
    result:=trunc(power(clamp(x),1/2.2)*255+0.5);
end;
function ColToRGB(v:VecRecord):rgbColor;
begin
    result.r:=ColToByte(v.x);
    result.g:=ColToByte(v.y);
    result.b:=ColToByte(v.z);
end;

BEGIN
END.
/*/$Log: rpdef.pas,v $
/*/Revision 2.2  2017/08/29 13:06:30  average
/*/とりあえず、徐々にBDPTの導入を始める
/*/
/*/Revision 2.1  2017/08/28 16:10:54  average
/*/設定ファイルの読み書き導入
/*/
/*/Revision 1.1  2017/08/28 13:05:49  average
/*/Initial revision
/*/
/*/Revision 1.5  2017/08/27 06:30:43  average
/*/Operator Inlineを導入
/*/
/*/Revision 1.4  2016/11/28 13:53:54  average
/*/変えた
/*/
//Revision 1.3  2016/11/23 13:04:34  average
//デバッグスタを入れる
//
//Revision 1.2  2016/11/22 16:02:48  average
//テストでんがな
////
