UNIT uModel;
{$MODE objfpc}
{$INLINE ON}
INTERFACE
uses SysUtils,Classes,uVect,Math;


const
  eps=1e-4;
  INF=1e20;
  M_1_PI=1/pi;
  MaxSc=10;
type
  SphereClass=CLASS
    rad:real;       //radius
    p,e,c:VecRecord;// position. emission,color
    refl:RefType;
    constructor Create(rad_:real;p_,e_,c_:VecRecord;refl_:RefType);
    function intersect(const r:RayRecord):real;
  END;

procedure InitScene;
function CopyScene(id:integer):TList;

var
  sph:TList;
  sc:array[0..10] of TList;
  MaxScName:integer;
  ScName:array[0..10] of string;

IMPLEMENTATION

constructor SphereClass.Create(rad_:real;p_,e_,c_:VecRecord;refl_:RefType);
BEGIN
  rad:=rad_;p:=p_;e:=e_;c:=c_;refl:=refl_;
END;
function SphereClass.intersect(const r:RayRecord):real;
var
  op:VecRecord;
  t,b,det:real;
BEGIN
  op:=p-r.o;
  t:=eps;b:=op*r.d;det:=b*b-op*op+rad*rad;
  IF det<0 THEN
    result:=INF
  ELSE BEGIN
    det:=sqrt(det);
    t:=b-det;
    IF t>eps THEN
      result:=t
    ELSE BEGIN
      t:=b+det;
      IF t>eps THEN
        result:=t
      ELSE
        result:=INF;
    END;
  END;
END;

procedure InitScene;
var
  i:integer;
  s:SphereClass;
  Cen,C,TC,SCC:VecRecord;
  R,T,D,Z:real;
BEGIN
  for i:=0 to MaxSC do sc[i]:=TList.Create;

  //----------debug  sc0-----------
ScName[0]:='0-Debug Scene';
  Cen:=CreateVec(50,40.8,-860);

  sc[0].add(SphereClass.Create(1600, CreateVec(1,0,2)*3000, CreateVec(1,0.9,0.8)*1.2e1*1.56*2,ZeroVec, DIFF)); // sun
  sc[0].add(SphereClass.Create(1560, CreateVec(1,0,2)*3500,CreateVec(1,0.5,0.05)*4.8e1*1.56*2, ZeroVec,  DIFF) ); // horizon sun2
  sc[0].add(SphereClass.Create(10000,Cen+CreateVec(0,0,-200), CreateVec(0.00063842, 0.02001478, 0.28923243)*6e-2*8, CreateVec(0.7,0.7,1)*0.25,  DIFF)); // sky

  sc[0].add(SphereClass.Create(100000, CreateVec(50, -100000, 0),ZeroVec,CreateVec(0.3,0.3,0.3),DIFF)); // grnd
  sc[0].add(SphereClass.Create(110000, CreateVec(50, -110048.5, 0),CreateVec(0.9,0.5,0.05)*4,ZeroVec,DIFF));// horizon brightener
  sc[0].add(SphereClass.Create(4e4, CreateVec(50, -4e4-30, -3000),ZeroVec,CreateVec(0.2,0.2,0.2),DIFF));// mountains

  sc[0].add(SphereClass.Create(30,CreateVec(50,30,42),ZeroVec,CreateVec(1,1,1)*0.596, SPEC)); // white Mirr




//----------cornel box sc1-----------
ScName[1]:='1-cornel Box';
  sc[1].add( SphereClass.Create(1e5, CreateVec( 1e5+1,40.8,81.6),  ZeroVec,CreateVec(0.75,0.25,0.25),DIFF) );//Left
  sc[1].add( SphereClass.Create(1e5, CreateVec(-1e5+99,40.8,81.6), ZeroVec,CreateVec(0.25,0.25,0.75),DIFF) );//Right
  sc[1].add( SphereClass.Create(1e5, CreateVec(50,40.8, 1e5),      ZeroVec,CreateVec(0.75,0.75,0.75),DIFF) );//Back
  sc[1].add( SphereClass.Create(1e5, CreateVec(50,40.8,-1e5+170+eps),ZeroVec,CreateVec(0,0,0)       ,DIFF) );//Front
  sc[1].add( SphereClass.Create(1e5, CreateVec(50, 1e5, 81.6),     ZeroVec,CreateVec(0.75,0.75,0.75),DIFF) );//Bottomm
  sc[1].add( SphereClass.Create(1e5, CreateVec(50,-1e5+81.6,81.6), ZeroVec,CreateVec(0.75,0.75,0.75),DIFF) );//Top
  sc[1].add( SphereClass.Create(16.5,CreateVec(27,16.5,47),        ZeroVec,CreateVec(1,1,1)*0.999,   SPEC) );//Mirror
  sc[1].add( SphereClass.Create(16.5,CreateVec(73,16.5,88),        ZeroVec,CreateVec(1,1,1)*0.999,   REFR) );//Glass
  sc[1].add( SphereClass.Create( 1.5,CreateVec(50,81.6-16.5,81.6), CreateVec(4,4,4)*100,   ZeroVec,  DIFF) );//Ligth


//-----------sky sc2--------------
ScName[2]:='2-Sky';
  Cen:=CreateVec(50,40.8,-860);

  sc[2].add(SphereClass.Create(1600, CreateVec(1,0,2)*3000, CreateVec(1,0.9,0.8)*1.2e1*1.56*2,ZeroVec, DIFF)); // sun
  sc[2].add(SphereClass.Create(1560, CreateVec(1,0,2)*3500,CreateVec(1,0.5,0.05)*4.8e1*1.56*2, ZeroVec,  DIFF) ); // horizon sun2
  sc[2].add(SphereClass.Create(10000,Cen+CreateVec(0,0,-200), CreateVec(0.00063842, 0.02001478, 0.28923243)*6e-2*8, CreateVec(0.7,0.7,1)*0.25,  DIFF)); // sky

  sc[2].add(SphereClass.Create(100000, CreateVec(50, -100000, 0),ZeroVec,CreateVec(0.3,0.3,0.3),DIFF)); // grnd
  sc[2].add(SphereClass.Create(110000, CreateVec(50, -110048.5, 0),CreateVec(0.9,0.5,0.05)*4,ZeroVec,DIFF));// horizon brightener
  sc[2].add(SphereClass.Create(4e4, CreateVec(50, -4e4-30, -3000),ZeroVec,CreateVec(0.2,0.2,0.2),DIFF));// mountains

  sc[2].add(SphereClass.Create(26.5,CreateVec(22,26.5,42),ZeroVec,CreateVec(1,1,1)*0.596, SPEC)); // white Mirr
  sc[2].add(SphereClass.Create(13,CreateVec(75,13,82),ZeroVec,CreateVec(0.96,0.96,0.96)*0.96, REFR));// Glas
  sc[2].add(SphereClass.Create(22,CreateVec(87,22,24),ZeroVec,CreateVec(0.6,0.6,0.6)*0.696, REFR));    // Glas2

//------------nightsky sc3----
ScName[3]:='3-nightsky';
  sc[3].add(SphereClass.Create(2.5e3,CreateVec(0.82,0.92,0-2)*1e4,    CreateVec(1,1,1)*0.8e2,     ZeroVec, DIFF)); // moon
  sc[3].add(SphereClass.Create(2.5e4,CreateVec(50, 0, 0),  CreateVec(0.114, 0.133, 0.212)*1e-2,  CreateVec(0.216,0.384,1)*0.003, DIFF)); // sky
  sc[3].add(SphereClass.Create(5e0,  CreateVec(-0.2,0.16,-1)*1e4, CreateVec(1.00, 0.843, 0.698)*1e2,   ZeroVec, DIFF));  // star
  sc[3].add(SphereClass.Create(5e0,  CreateVec(0,  0.18,-1)*1e4,  CreateVec(1.00, 0.851, 0.710)*1e2,  ZeroVec, DIFF));  // star
  sc[3].add(SphereClass.Create(5e0,  CreateVec(0.3, 0.15,-1)*1e4, CreateVec(0.671, 0.780, 1.00)*1e2,   ZeroVec, DIFF));  // star
  sc[3].add(SphereClass.Create(3.5e4,CreateVec(600,-3.5e4+1, 300), ZeroVec,   CreateVec(0.6,0.8,1)*0.01,  REFR));   //pool
  sc[3].add(SphereClass.Create(5e4,  CreateVec(-500,-5e4+0, 0),    ZeroVec,   CreateVec(1,1,1)*0.35,  DIFF));    //hill
  sc[3].add(SphereClass.Create(16.5, CreateVec(27,0,47),           ZeroVec,   CreateVec(1,1,1)*0.33, DIFF)); //hut
  sc[3].add(SphereClass.Create(7,    CreateVec(27+8*sqrt(2),0,47+8*sqrt(2)),ZeroVec,  CreateVec(1,1,1)*0.33,  DIFF)); //door
  sc[3].add(SphereClass.Create(500,  CreateVec(-1e3,-300,-3e3), ZeroVec,  CreateVec(1,1,1)*0.351,    DIFF));  //mnt
  sc[3].add(SphereClass.Create(830,  CreateVec(0,   -500,-3e3), ZeroVec,  CreateVec(1,1,1)*0.354,    DIFF));  //mnt
  sc[3].add(SphereClass.Create(490,  CreateVec(1e3, -300,-3e3), ZeroVec,  CreateVec(1,1,1)*0.352,    DIFF));  //mnt

//-----------island sc4-------
ScName[4]:='4-island';
  Cen:=CreateVec(50,-20,-860);

  sc[4].add(SphereClass.Create(160, Cen+CreateVec(0, 600, -500),CreateVec(1,1,1)*2e2, ZeroVec,  DIFF)); // sun
  sc[4].add(SphereClass.Create(800, Cen+CreateVec(0,-880,-9120),CreateVec(1,1,1)*2e1, ZeroVec,  DIFF)); // horizon
  sc[4].add(SphereClass.Create(10000,Cen+CreateVec(0,0,-200), CreateVec(0.0627, 0.188, 0.569)*1e0, CreateVec(1,1,1)*0.4,  DIFF)); // sky
  sc[4].add(SphereClass.Create(800, Cen+CreateVec(0,-720,-200),ZeroVec,  CreateVec(0.110, 0.898, 1.00)*0.996,  REFR)); // water
  sc[4].add(SphereClass.Create(790, Cen+CreateVec(0,-720,-200),ZeroVec,  CreateVec(0.4,0.3,0.04)*0.6, DIFF)); // earth
  sc[4].add(SphereClass.Create(325, Cen+CreateVec(0,-255,-50), ZeroVec,  CreateVec(0.4,0.3,0.04)*0.8, DIFF)); // island
  sc[4].add(SphereClass.Create(275, Cen+CreateVec(0,-205,-33), ZeroVec,  CreateVec(0.02,0.3,0.02)*0.75,DIFF)); // grass

//-------------Vista sc5------------
ScName[5]:='5-Vista';
  Cen:=CreateVec(50,-20,-860);

  sc[5].add(SphereClass.Create(8000, Cen+CreateVec(0,-8000,-900),CreateVec(1,0.4,0.1)*5e-1, ZeroVec,  DIFF)); // sun
  sc[5].add(SphereClass.Create(1e4,  Cen+ZeroVec, CreateVec(0.631, 0.753, 1.00)*3e-1, CreateVec(1,1,1)*0.5,  DIFF)); // sky

  sc[5].add(SphereClass.Create(150,  Cen+CreateVec(-350,0, -100),ZeroVec,  CreateVec(1,1,1)*0.3,  DIFF)); // mnt
  sc[5].add(SphereClass.Create(200,  Cen+CreateVec(-210,0,-100), ZeroVec,  CreateVec(1,1,1)*0.3,  DIFF)); // mnt
  sc[5].add(SphereClass.Create(145,  Cen+CreateVec(-210,85,-100),ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF)); // snow
  sc[5].add(SphereClass.Create(150,  Cen+CreateVec(-50,0,-100),  ZeroVec,  CreateVec(1,1,1)*0.3,  DIFF)); // mnt
  sc[5].add(SphereClass.Create(150,  Cen+CreateVec(100,0,-100),  ZeroVec,  CreateVec(1,1,1)*0.3,  DIFF)); // mnt
  sc[5].add(SphereClass.Create(125,  Cen+CreateVec(250,0,-100),  ZeroVec,  CreateVec(1,1,1)*0.3,  DIFF)); // mnt
  sc[5].add(SphereClass.Create(150,  Cen+CreateVec(375,0,-100),  ZeroVec,  CreateVec(1,1,1)*0.3,  DIFF)); // mnt

  sc[5].add(SphereClass.Create(2500, Cen+CreateVec(0,-2400,-500),ZeroVec,  CreateVec(1,1,1)*0.1,  DIFF)); // mnt base

  sc[5].add(SphereClass.Create(8000, Cen+CreateVec(0,-8000,200), ZeroVec,  CreateVec(0.2,0.2,1),    REFR)); // water
  sc[5].add(SphereClass.Create(8000, Cen+CreateVec(0,-8000,1100),ZeroVec,  CreateVec(0,0.3,0),     DIFF)); // grass
  sc[5].add(SphereClass.Create(8   , Cen+CreateVec(-75, -5, 850),ZeroVec,  CreateVec(0,0.3,0),     DIFF)); // bush
  sc[5].add(SphereClass.Create(30,   Cen+CreateVec(0,   23, 825),ZeroVec,  CreateVec(1,1,1)*0.996, REFR)); // ball

  sc[5].add(SphereClass.Create(30,  Cen+CreateVec(200,280,-400),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));   // clouds
  sc[5].add(SphereClass.Create(37,  Cen+CreateVec(237,280,-400),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));   // clouds
  sc[5].add(SphereClass.Create(28,  Cen+CreateVec(267,280,-400),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));   // clouds

  sc[5].add(SphereClass.Create(40,  Cen+CreateVec(150,280,-1000),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));  // clouds
  sc[5].add(SphereClass.Create(37,  Cen+CreateVec(187,280,-1000),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));  // clouds

  sc[5].add(SphereClass.Create(40,  Cen+CreateVec(600,280,-1100),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));  // clouds
  sc[5].add(SphereClass.Create(37,  Cen+CreateVec(637,280,-1100),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));  // clouds

  sc[5].add(SphereClass.Create(37,  Cen+CreateVec(-800,280,-1400),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF)); // clouds
  sc[5].add(SphereClass.Create(37,  Cen+CreateVec(0,280,-1600),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));    // clouds
  sc[5].add(SphereClass.Create(37,  Cen+CreateVec(537,280,-1800),  ZeroVec,  CreateVec(1,1,1)*0.8,  DIFF));  // clouds

//----------------Overlap  sc6-----------------
ScName[6]:='6-Overlap';

D:=50;
R:=40;
  sc[6].add(SphereClass.Create(150, CreateVec(50+75,28,62), CreateVec(1,1,1)*0e-3, CreateVec(1,0.9,0.8)*0.93, REFR));
  sc[6].add(SphereClass.Create(28,  CreateVec(50+5,-28,62), CreateVec(1,1,1)*1e1, ZeroVec, DIFF));
  sc[6].add(SphereClass.Create(300, CreateVec(50,28,62), CreateVec(1,1,1)*0e-3, CreateVec(1,1,1)*0.93, SPEC));

//----------------wada  sc7-------------
ScName[7]:='7-wada';

R:=60;
//double R=120;
T:=30*PI/180.;
D:=R/cos(T);
Z:=60;

  sc[7].add(SphereClass.Create(1e5, CreateVec(50, 100, 0),      CreateVec(1,1,1)*3e0, ZeroVec, DIFF)); // sky
  sc[7].add(SphereClass.Create(1e5, CreateVec(50, -1e5-D-R, 0), ZeroVec,     CreateVec(0.1,0.1,0.1),DIFF));           //grnd

  sc[7].add(SphereClass.Create(R, CreateVec(50,40.8,62)+CreateVec( cos(T),sin(T),0)*D, ZeroVec, CreateVec(1,0.3,0.3)*0.999, SPEC)); //red
  sc[7].add(SphereClass.Create(R, CreateVec(50,40.8,62)+CreateVec(-cos(T),sin(T),0)*D, ZeroVec, CreateVec(0.3,1,0.3)*0.999, SPEC)); //grn
  sc[7].add(SphereClass.Create(R, CreateVec(50,40.8,62)+CreateVec(0,-1,0)*D,         ZeroVec, CreateVec(0.3,0.3,1)*0.999, SPEC)); //blue
  sc[7].add(SphereClass.Create(R, CreateVec(50,40.8,62)+CreateVec(0,0,-1)*D,       ZeroVec, CreateVec(0.53,0.53,0.53)*0.999, SPEC)); //back
  sc[7].add(SphereClass.Create(R, CreateVec(50,40.8,62)+CreateVec(0,0,1)*D,      ZeroVec, CreateVec(1,1,1)*0.999, REFR)); //front

//-----------------wada2 sc8----------
ScName[8]:='8-wada2';

R:=120;     // radius
T:=30*PI/180.;
D:=R/cos(T);     //distance
Z:=62;
C:=CreateVec(0.275, 0.612, 0.949);

  sc[8].add(SphereClass.Create(R, CreateVec(50,28,Z)+CreateVec( cos(T),sin(T),0)*D,    C*6e-2,CreateVec(1,1,1)*0.996, SPEC)); //red
  sc[8].add(SphereClass.Create(R, CreateVec(50,28,Z)+CreateVec(-cos(T),sin(T),0)*D,    C*6e-2,CreateVec(1,1,1)*0.996, SPEC)); //grn
  sc[8].add(SphereClass.Create(R, CreateVec(50,28,Z)+CreateVec(0,-1,0)*D,              C*6e-2,CreateVec(1,1,1)*0.996, SPEC)); //blue
  sc[8].add(SphereClass.Create(R, CreateVec(50,28,Z)+CreateVec(0,0,-1)*R*2*sqrt(2/3),C*0e-2,CreateVec(1,1,1)*0.996, SPEC)); //back
  sc[8].add(SphereClass.Create(2*2*R*2*sqrt(2/3)-R*2*sqrt(2/3)/3, CreateVec(50,28,Z)+CreateVec(0,0,-R*2*sqrt(2/3)/3),   CreateVec(1,1,1)*0,CreateVec(1,1,1)*0.5, SPEC)); //front

//---------------forest sc9-----------
ScName[9]:='9-forest';

tc:=CreateVec(0.0588, 0.361, 0.0941);
scc:=CreateVec(1,1,1)*0.7;
  sc[9].add(SphereClass.Create(1e5, CreateVec(50, 1e5+130, 0),  CreateVec(1,1,1)*1.3,ZeroVec,DIFF)); //lite
  sc[9].add(SphereClass.Create(1e2, CreateVec(50, -1e2+2, 47),  ZeroVec,CreateVec(1,1,1)*0.7,DIFF)); //grnd

  sc[9].add(SphereClass.Create(1e4, CreateVec(50, -30, 300)+CreateVec(-sin(50*PI/180),0,cos(50*PI/180))*1e4, ZeroVec, CreateVec(1,1,1)*0.99,SPEC));// mirr L
  sc[9].add(SphereClass.Create(1e4, CreateVec(50, -30, 300)+CreateVec(sin(50*PI/180),0,cos(50*PI/180))*1e4,  ZeroVec, CreateVec(1,1,1)*0.99,SPEC));// mirr R
  sc[9].add(SphereClass.Create(1e4, CreateVec(50, -30, -50)+CreateVec(-sin(30*PI/180),0,-cos(30*PI/180))*1e4,ZeroVec, CreateVec(1,1,1)*0.99,SPEC));// mirr FL
  sc[9].add(SphereClass.Create(1e4, CreateVec(50, -30, -50)+CreateVec(sin(30*PI/180),0,-cos(30*PI/180))*1e4, ZeroVec, CreateVec(1,1,1)*0.99,SPEC));// mirr


  sc[9].add(SphereClass.Create(4, CreateVec(50,6*0.6,47),   ZeroVec,CreateVec(0.13,0.066,0.033), DIFF));//"tree"
  sc[9].add(SphereClass.Create(16,CreateVec(50,6*2+16*0.6,47),   ZeroVec, tc,  DIFF));//"tree"
  sc[9].add(SphereClass.Create(11,CreateVec(50,6*2+16*0.6*2+11*0.6,47),   ZeroVec, tc,  DIFF));//"tree"
  sc[9].add(SphereClass.Create(7, CreateVec(50,6*2+16*0.6*2+11*0.6*2+7*0.6,47),   ZeroVec, tc,  DIFF));//"tree"

  sc[9].add(SphereClass.Create(15.5,CreateVec(50,1.8+6*2+16*0.6,47),   ZeroVec, scc,  DIFF));//"tree"
  sc[9].add(SphereClass.Create(10.5,CreateVec(50,1.8+6*2+16*0.6*2+11*0.6,47),   ZeroVec, scc,  DIFF));//"tree"
  sc[9].add(SphereClass.Create(6.5, CreateVec(50,1.8+6*2+16*0.6*2+11*0.6*2+7*0.6,47),   ZeroVec, scc,  DIFF));//"tree"


  MaxScName:=9;


END;

function CopyScene(id:integer):TList;
var
  i,j:integer;
  rc,w:TList;
  s:SphereClass;
begin
  IF (id>MaxScName) OR (id<0) THEN BEGIN
    result:=NIL;
    EXIT;
  END;
  rc:=TList.Create;
  w:=sc[id];
  FOR i:=0 TO w.count-1 DO BEGIN
    s:=SphereClass(w[i]);
    rc.add(SphereClass.Create(s.rad,s.p,s.e,s.c,s.refl) );
  END;
  result:=rc;
end;

BEGIN
END.



